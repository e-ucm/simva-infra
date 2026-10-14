## Local development connect to simva server


```
ssh  -L0.0.0.0:9092:localhost:9092 -o UserKnownHostsFile=/dev/null -N vagrant@192.168.253.2

docker run \
    --name tunnel-kafka1 \
    --publish 9092:9092 \
    --network kafka_services \
    -d \
    alpine/socat \
    tcp-listen:9092,fork,reuseaddr tcp-connect:kafka1.internal.test:9092


docker run \
    --name tunnel-traefik-http \
    --network host \
    -d \
    alpine/socat \
    tcp-listen:80,fork,bind=172.29.0.1 tcp-connect:192.168.253.2:80

docker run \
    --name tunnel-traefik-https \
    --network host \
    -d \
    alpine/socat \
    tcp-listen:443,fork,bind=172.29.0.1 tcp-connect:192.168.253.2:443
```