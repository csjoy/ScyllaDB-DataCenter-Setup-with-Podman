# ScyllaDB-DataCenter-with-Podman
Tutorial on how to setup multiple ScyllaDB datacenters using Podman

# 🚀 Manual:

### Step 1
Create network for you ScyllaDB datacenters
```
podman network create dc
```

### Step 2
Clone this repo and cd into it. Then run the following commands to create all the nodes of datacenter1.
```
podman run --network=dc --name NodeX -v ./scylla/scylla.yaml:/etc/scylla/scylla.yaml -v ./scylla/cassandra-rackdc.properties.dc1:/etc/scylla/cassandra-rackdc.properties -d scylladb/scylla --smp 1 --memory 256M --overprovisioned 1 --api-address 0.0.0.0

podman run --network=dc --name NodeY -v ./scylla/scylla.yaml:/etc/scylla/scylla.yaml -v ./scylla/cassandra-rackdc.properties.dc1:/etc/scylla/cassandra-rackdc.properties -d scylladb/scylla --seeds=NodeX,NodeY --smp 1 --memory 256M --overprovisioned 1 --api-address 0.0.0.0

podman run --network=dc --name NodeZ -v ./scylla/scylla.yaml:/etc/scylla/scylla.yaml -v ./scylla/cassandra-rackdc.properties.dc1:/etc/scylla/cassandra-rackdc.properties -d scylladb/scylla --seeds=NodeX,NodeY --smp 1 --memory 256M --overprovisioned 1 --api-address 0.0.0.0
```

### Step 3
Similar to the datacenter1 now run the following commands to create all the nodes of datacenter2.
```
podman run --network=dc --name NodeA -v ./scylla/scylla.yaml:/etc/scylla/scylla.yaml -v ./scylla/cassandra-rackdc.properties.dc2:/etc/scylla/cassandra-rackdc.properties -d scylladb/scylla --seed=NodeX --smp 1 --memory 256M --overprovisioned 1 --api-address 0.0.0.0

podman run --network=dc --name NodeB -v ./scylla/scylla.yaml:/etc/scylla/scylla.yaml -v ./scylla/cassandra-rackdc.properties.dc2:/etc/scylla/cassandra-rackdc.properties -d scylladb/scylla --seeds=NodeX,NodeA --smp 1 --memory 256M --overprovisioned 1 --api-address 0.0.0.0

podman run --network=dc --name NodeC -v ./scylla/scylla.yaml:/etc/scylla/scylla.yaml -v ./scylla/cassandra-rackdc.properties.dc2:/etc/scylla/cassandra-rackdc.properties -d scylladb/scylla --seeds=NodeX,NodeA --smp 1 --memory 256M --overprovisioned 1 --api-address 0.0.0.0
```
### Step 4
Finally, you can view your nodes in each datacenter by running the following command on any node. Note, it can take several minutes to show up all the nodes in the results.
```
podman exec -it NodeA nodetool status
```
output is similar to this one
```
Datacenter: DC1
===============
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address     Load       Tokens       Owns    Host ID                               Rack
UN  10.89.0.3   640 KB     256          ?       e211fdc4-670b-4645-a583-4ba0ef3b4a16  Rack1
UN  10.89.0.2   556 KB     256          ?       c9c3d494-fe26-4dc4-b930-1941ad18692a  Rack1
UN  10.89.0.4  752 KB     256          ?       a24d5f40-79e2-4683-bb12-85a991950bf8  Rack1
Datacenter: DC2
===============
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address     Load       Tokens       Owns    Host ID                               Rack
UN  10.89.0.6   772 KB     256          ?       c3f78088-0eea-47a2-92c1-06f46bf49761  Rack1
UN  10.89.0.5   788 KB     256          ?       28f83659-d835-47bc-aba2-3dde9aab09cd  Rack1
UN  10.89.0.7   844 KB     256          ?       4513b9d2-7081-4af0-8004-e68a38abd188  Rack1

Note: Non-system keyspaces don't have the same replication settings, effective ownership information is meaningless
```

# 🧞 Automatic
Or clone this repo and cd into it. Then run the following commands and you are done.
```
chmod +x ./create-datacenter.sh
./create-datacenter.sh
```
<img src="https://university.scylladb.com/wp-content/uploads/2019/01/Screenshot-from-2019-01-22-17-24-32.png" />
