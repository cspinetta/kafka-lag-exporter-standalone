# Kafka Lag Exporter Standalone

A docker compose with [Kafka Lag Exporter] + [Prometheus] + [Grafana] + a properly [Dashboard](https://github.com/lightbend/kafka-lag-exporter/tree/master/grafana) to view the latency of your Apache Kafka consumer groups. Useful tool for monitoring and troubleshooting a Kafka deployment.

[Kafka Lag Exporter] has a simple and easy installation based on `Helm`.
But a lot of people don't use k8s, which means they have to prepare a custom installation with a docker compose or something else. This repo has the all necessary to install and start up a [Kafka Lag Exporter] in standalone fashion, on few steps.

### Getting started

1. Download your desired version and unpack it:

```bash
curl -fsSL -o kafka-lag-exporter-standalone.tar.gz [url to release]
tar -xf kafka-lag-exporter-standalone.tar.gz
```

2. Specify kafka nodes on [kafka-exporter-standalone/kafka-lag-exporter/application.conf].
3. Run with docker compose: `docker-compose up -f kafka-exporter-standalone/docker-compose.yaml`.

Then you can open the Grafana webapp exposed at port `3000` and navigate to the dashboard **Kafka Lag Exporter**.

On the first time you enter Grafana ask you to login. Type `admin` for the username and password. Then Grafana will ask you to choose a new password.

[Kafka Lag Exporter]: https://github.com/lightbend/kafka-lag-exporter
[Prometheus]: https://prometheus.io/
[Grafana]: https://grafana.com/
[kafka-exporter-standalone/kafka-lag-exporter/application.conf]: kafka-exporter-standalone/kafka-lag-exporter/application.conf
[kafka-exporter-standalone/docker-compose.yaml]: kafka-exporter-standalone/docker-compose.yaml
