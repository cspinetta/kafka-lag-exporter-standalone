#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MAIN_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "🚀 Starting Kafka Lag Exporter test setup..."
echo ""

# Set project name to ensure both compose files share the same network
PROJECT_NAME="kafka-lag-exporter-test"

# Create a temporary docker-compose override with absolute paths
TEMP_OVERRIDE=$(mktemp)
cat > "$TEMP_OVERRIDE" <<EOF
# Override configuration for testing
services:
  kafka-lag-exporter:
    volumes:
      - '$SCRIPT_DIR/application.local.conf:/opt/docker/conf/application.conf:ro'
      - '$MAIN_DIR/kafka-exporter-standalone/kafka-lag-exporter/logback.xml:/opt/docker/conf/logback.xml:ro'
EOF

# Trap to cleanup temp file on exit
trap "rm -f '$TEMP_OVERRIDE'" EXIT INT TERM

# Start Kafka and Zookeeper for testing
echo "Starting Kafka and Zookeeper..."
docker compose -p "$PROJECT_NAME" -f "$SCRIPT_DIR/docker-compose.local.yaml" up -d

# Start the main application (Kafka Lag Exporter, Prometheus, Grafana)
# Using both compose files to override configuration for testing
echo "Starting Kafka Lag Exporter, Prometheus, and Grafana..."
docker compose -p "$PROJECT_NAME" -f "$MAIN_DIR/kafka-exporter-standalone/docker-compose.yaml" -f "$TEMP_OVERRIDE" up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 15

echo ""
echo "📊 Creating test topic and generating consumer lag..."

# Create a test topic
docker compose -p "$PROJECT_NAME" -f "$SCRIPT_DIR/docker-compose.local.yaml" exec -T kafka kafka-topics \
  --bootstrap-server localhost:9092 \
  --create \
  --topic test-lag-topic \
  --partitions 3 \
  --replication-factor 1 || echo "Topic already exists or not ready yet"

# Produce some messages
echo "Producing messages..."
docker compose -p "$PROJECT_NAME" -f "$SCRIPT_DIR/docker-compose.local.yaml" exec -T kafka kafka-producer-perf-test \
  --topic test-lag-topic \
  --num-records 100 \
  --record-size 1000 \
  --throughput -1 \
  --producer-props bootstrap.servers=localhost:9092

# Create a consumer group and consume some messages to create lag
echo "Creating consumer lag..."
docker compose -p "$PROJECT_NAME" -f "$SCRIPT_DIR/docker-compose.local.yaml" exec -T kafka kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic test-lag-topic \
  --group test-consumer-group \
  --max-messages 20 &

echo ""
echo "✅ Test setup complete!"
echo ""
echo "📈 Access the following services:"
echo "   - Grafana: http://localhost:3000 (admin/admin)"
echo "   - Prometheus: http://localhost:9090"
echo "   - Kafka Metrics: http://localhost:8000/metrics"
echo ""
echo "📋 To view Kafka Lag Exporter dashboard:"
echo "   1. Open http://localhost:3000"
echo "   2. Login with admin/admin"
echo "   3. Navigate to the 'Kafka Lag Exporter' dashboard"
echo ""
echo "🛑 To stop all services:"
echo "   $SCRIPT_DIR/cleanup-test.sh"
echo ""
echo "💡 To generate more lag for testing:"
echo "   docker compose -p $PROJECT_NAME -f $SCRIPT_DIR/docker-compose.local.yaml exec -T kafka kafka-producer-perf-test \\"
echo "     --topic test-lag-topic --num-records 100 --record-size 1000 --throughput -1 \\"
echo "     --producer-props bootstrap.servers=localhost:9092"
echo ""
echo "ℹ️  This test uses the main kafka-exporter-standalone/docker-compose.yaml"
echo "   to test the actual configuration offered by this repository."

