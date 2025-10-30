#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MAIN_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"
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
trap "rm -f '$TEMP_OVERRIDE'" EXIT INT TERM

echo "🧹 Cleaning up test environment..."

# Stop and remove containers from main compose
echo "Stopping Kafka Lag Exporter, Prometheus, and Grafana..."
docker compose -p "$PROJECT_NAME" -f "$MAIN_DIR/kafka-exporter-standalone/docker-compose.yaml" -f "$TEMP_OVERRIDE" down -v

# Stop and remove Kafka and Zookeeper
echo "Stopping Kafka and Zookeeper..."
docker compose -p "$PROJECT_NAME" -f "$SCRIPT_DIR/docker-compose.local.yaml" down -v

echo ""
echo "✅ Cleanup complete!"
echo "All services stopped and volumes removed."

