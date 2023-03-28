#!/bin/bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

# Check if buildah is present in host os
if [ -z "$(command -v podman)" ]; then
  echo "ERR: podman is not installed"
  echo "RUN: sudo apt install podman"
  exit 1
fi

NET_NAME="dc"

# Creating net network
podman network create $NET_NAME

# Creating first datacenter
podman run --network=$NET_NAME --name NodeX -v ./scylla/scylla.yaml:/etc/scylla/scylla.yaml -v ./scylla/cassandra-rackdc.properties.dc1:/etc/scylla/cassandra-rackdc.properties -d scylladb/scylla --smp 1 --memory 256M --overprovisioned 1 --api-address 0.0.0.0

podman run --network=$NET_NAME --name NodeY -v ./scylla/scylla.yaml:/etc/scylla/scylla.yaml -v ./scylla/cassandra-rackdc.properties.dc1:/etc/scylla/cassandra-rackdc.properties -d scylladb/scylla --seeds=NodeX,NodeY --smp 1 --memory 256M --overprovisioned 1 --api-address 0.0.0.0

podman run --network=$NET_NAME --name NodeZ -v ./scylla/scylla.yaml:/etc/scylla/scylla.yaml -v ./scylla/cassandra-rackdc.properties.dc1:/etc/scylla/cassandra-rackdc.properties -d scylladb/scylla --seeds=NodeX,NodeY --smp 1 --memory 256M --overprovisioned 1 --api-address 0.0.0.0

# Creating second datacenter
podman run --network=$NET_NAME --name NodeA -v ./scylla/scylla.yaml:/etc/scylla/scylla.yaml -v ./scylla/cassandra-rackdc.properties.dc2:/etc/scylla/cassandra-rackdc.properties -d scylladb/scylla --seed=NodeX --smp 1 --memory 256M --overprovisioned 1 --api-address 0.0.0.0

podman run --network=$NET_NAME --name NodeB -v ./scylla/scylla.yaml:/etc/scylla/scylla.yaml -v ./scylla/cassandra-rackdc.properties.dc2:/etc/scylla/cassandra-rackdc.properties -d scylladb/scylla --seeds=NodeX,NodeA --smp 1 --memory 256M --overprovisioned 1 --api-address 0.0.0.0

podman run --network=$NET_NAME --name NodeC -v ./scylla/scylla.yaml:/etc/scylla/scylla.yaml -v ./scylla/cassandra-rackdc.properties.dc2:/etc/scylla/cassandra-rackdc.properties -d scylladb/scylla --seeds=NodeX,NodeA --smp 1 --memory 256M --overprovisioned 1 --api-address 0.0.0.0
