# Local Testing Setup

This directory contains scripts and configuration files for testing the Kafka Lag Exporter setup locally with a complete Kafka environment.

## Quick Start

1. **Start the test environment:**
   ```bash
   ./run-test.sh
   ```

2. **Access the services:**
   - **Grafana**: http://localhost:3000 (admin/admin)
   - **Prometheus**: http://localhost:9090
   - **Kafka Metrics**: http://localhost:8000/metrics

3. **Cleanup when done:**
   ```bash
   ./cleanup-test.sh
   ```

## What's Included

This test setup combines:
- **test/docker-compose.local.yaml**: Local Kafka cluster (Zookeeper + Kafka)
- **kafka-exporter-standalone/docker-compose.yaml**: Main application (Kafka Lag Exporter + Prometheus + Grafana)
- **test/docker-compose.override.yaml**: Overrides Kafka connection to use local cluster

## Test Data

The `run-test.sh` script automatically:
1. Creates a test topic (`test-lag-topic`) with 3 partitions
2. Produces 100 test messages
3. Consumes 20 messages with a consumer group to create lag

## Generate More Lag

To create more observable lag for testing:

```bash
docker compose -f docker-compose.local.yaml exec -T kafka kafka-producer-perf-test \
  --topic test-lag-topic --num-records 100 --record-size 1000 --throughput -1 \
  --producer-props bootstrap.servers=localhost:9092
```

## Verify Metrics

Check that metrics are being collected:

```bash
curl http://localhost:8000/metrics | grep kafka_consumergroup_group_lag
```

## Troubleshooting

### Services won't start
- Ensure Docker has enough resources allocated
- Check if ports 3000, 9090, 9092, or 8000 are already in use

### No lag data in Grafana
- Wait for metrics to be collected (Kafka Lag Exporter polls every 30 seconds)
- Verify the consumer group exists: `docker compose -p kafka-lag-exporter-test -f docker-compose.local.yaml exec kafka kafka-consumer-groups --bootstrap-server localhost:9092 --list`
- Generate more lag using the command above
- Run `./debug.sh` to see debugging commands
- Check container logs: `docker logs kafka-lag-exporter | tail -30`
- Verify metrics at http://localhost:8000/metrics
- Check Prometheus targets at http://localhost:9090/targets

### Cleanup issues
- Force cleanup: `docker compose -f docker-compose.local.yaml down -v --remove-orphans`
- Remove volumes manually if needed

