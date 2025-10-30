# Kafka Lag Exporter Standalone

A docker compose with [Kafka Lag Exporter] + [Prometheus] + [Grafana] + a [Dashboard](https://github.com/lightbend/kafka-lag-exporter/tree/master/grafana) to view the latency of your Apache Kafka consumer groups. Useful tool for monitoring and troubleshooting a Kafka deployment in a few easy steps.

### Why this docker compose?

This repo brings [Kafka Lag Exporter], [Prometheus] and [Grafana] together in one single docker compose, so you can quickly start it up and start analyzing an issue on a Kafka deployment. Otherwise, you would need to start and configure each piece separately, which could be a bit cumbersome.

It aims to provide a quick installation for troubleshooting and not a final installation for permanent monitoring. It's perfect if you are facing an issue in production and need more visibility about what is happening internally in kafka.

### Security Note

**⚠️ This setup is intended for local development and troubleshooting only.** For production use, please:
- Change the default Grafana admin password immediately
- Configure proper authentication and authorization
- Set up network security and firewall rules
- Use environment variables or secrets management for sensitive configuration
- Regularly update all container images for security patches

### Example use cases


#### Consumer group lag in seconds

![Consumer Groups Time Lag](docs/consumer_group_lag_seconds.png)

Here is an example from one of the Grafana dashboards provided. 
In this dashboard we can see the time between last commit and current time, which is also known as lag in seconds, 
and we can see it by consumer group. 
This example was taken from a Kafka-Connect that commits every 30 minutes if everything goes well. 
If we analyze it, we can see that some consumer groups fail on commit for some reason.

#### Consumer group lag in seconds and offsets


![Consumer Group Time and Events Lag](docs/consumer_group_seconds_and_events_lag.png)

In this other example, we can see a particular consumer group's status. 
It shows the consumer group lag in seconds and messages/events (the difference between current message and last committed)

### Getting started

1. Clone the repository or download your desired version and unpack it:

```bash
# Option 1: Clone the repository
git clone https://github.com/cspinetta/kafka-lag-exporter-standalone.git
cd kafka-lag-exporter-standalone

# Option 2: Download release
curl -fsSL -o kafka-lag-exporter-standalone.tar.gz https://github.com/cspinetta/kafka-lag-exporter-standalone/releases/download/0.0.2/kafka-lag-exporter-standalone-0.0.2.tar
tar -xf kafka-lag-exporter-standalone.tar.gz
cd kafka-lag-exporter-standalone
```

2. Configure Kafka connection by editing `kafka-exporter-standalone/kafka-lag-exporter/application.conf` to specify your Kafka bootstrap brokers.

3. Run with docker compose:
```bash
docker compose -f kafka-exporter-standalone/docker-compose.yaml up -d
```

Then you can open the Grafana webapp exposed at port `3000` and navigate to the dashboard **Kafka Lag Exporter**.

When you first enter Grafana, it will ask you to login. Type `admin` for both the username and password. Then Grafana will ask you to choose a new password.

**Note:** Docker Compose v2 is recommended (command: `docker compose`). If you're using older versions, you may need to use `docker-compose` (with hyphen) instead.

### Testing Locally

For developers contributing to this repository, we provide a complete local testing setup with Kafka, Zookeeper, and sample data.

**Quick Start:**

```bash
# Navigate to the test directory
cd test

# Run the test setup (starts Kafka + all services + creates test data)
./run-test.sh

# Access Grafana at http://localhost:3000
# Access Prometheus at http://localhost:9090
# Access Kafka metrics at http://localhost:8000/metrics

# When done testing, cleanup:
./cleanup-test.sh
```

**What the test setup includes:**
- **Kafka cluster**: Single-node Kafka with Zookeeper
- **Test topic**: `test-lag-topic` with 3 partitions
- **Sample data**: 100 messages produced
- **Consumer lag**: 20 messages consumed, creating observable lag
- **All services**: Kafka Lag Exporter, Prometheus, and Grafana

**Generate more lag for testing:**

```bash
docker compose -f test/docker-compose.local.yaml exec -T kafka kafka-producer-perf-test \
  --topic test-lag-topic --num-records 100 --record-size 1000 --throughput -1 \
  --producer-props bootstrap.servers=localhost:9092
```

**Verify metrics are working:**

Check that Kafka Lag Exporter is collecting metrics:
```bash
curl http://localhost:8000/metrics | grep kafka_consumergroup_group_lag
```

[Kafka Lag Exporter]: https://github.com/lightbend/kafka-lag-exporter
[Prometheus]: https://prometheus.io/
[Grafana]: https://grafana.com/
[kafka-exporter-standalone/kafka-lag-exporter/application.conf]: kafka-exporter-standalone/kafka-lag-exporter/application.conf
[kafka-exporter-standalone/docker-compose.yaml]: kafka-exporter-standalone/docker-compose.yaml
