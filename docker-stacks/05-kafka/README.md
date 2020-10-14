
# Setup

**Make sure that keycloak and minio are already configured**
```
# Launch kafka stack (now in development mode including all UIs)
./kafka-stack.sh up -d
```
Install kafka-connect S3 sink defined in `simva.json`.

Using curl (not tested):
```
curl -XPOST -H Content-Type:application/json -d@simva.json http://connect.${SIMVA_INTERNAL_DOMAIN:-internal.test}/connectors
```

Trough the ui-connect. Make sure to just copy the value of the `config` property:
```
{
  "name": "simva-sink",
  "config": {
    ...
  }
}
```

Important URLs:
- [Schema Registry UI](https://schema-registry-ui.external.test)
- [Kafka connect UI](https://connect-ui.external.test)
- [Topics UI](https://topics-ui.external.test)
- [Zoonavigator UI](https://zoonavigator.external.test)

## Command utilities
```
# Note that "traces" topic is automatically created once the sink is installed
./kafka-stack.sh exec kafka1 kafka-topics --create --bootstrap-server localhost:19092 --replication-factor 1 --partitions 1 --topic traces

# This will read each line of "test.json" and send to the kafka broker
# Note: kafkacat it is a bash alias
kafkacat -b kafka1.${SIMVA_INTERNAL_DOMAIN:-internal.test} -t traces -P -l test.json
```

# References
- https://github.com/confluentinc/cp-demo/blob/5.5.0-post/docker-compose.yml
- https://github.com/simplesteph/kafka-stack-docker-compose
- https://github.com/confluentinc/kafka-connect-storage-common/pull/67/files
- https://docs.lenses.io/3.2/install_setup/deployment-options/docker-deployment.html
- https://github.com/yahoo/CMAK