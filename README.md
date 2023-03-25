# ScyllaDB-DataCenter-Setup-with-Podman
Tutorial on how to setup multiple ScyllaDB datacenters using Podman


## Inspiration
Podman handles networking of containers a bit differently than Docker. That's why setup instructions written for docker doesn't work out of the box like other docker command. So, anyone wishes to create multiple ScyllaDB datacenters with Podman should follow the instruction given below.

### Step 1
Create separate network for you ScyllaDB datacenters
```
podman network create dc1
podman network create dc2
```

### Step 2
Clone this repo and cd into it. Then run the following command to create the first node of datacenter1.
```
podman run --network=dc1 --name NodeX -v ./scylla/scylla.yaml:/etc/scylla/scylla.yaml -v ./scylla/cassandra-rackdc.properties.dc1:/etc/scylla/cassandra-rackdc.properties -d scylladb/scylla --smp 1 --memory 256M --overprovisioned 1 --api-address 0.0.0.0
```
### Step 3
Now it's time for manual lookup of ip address for the first node of datacenter1. Run the following command then copy the IP address from the result. 
```
podman exec -it NodeX nodetool status
```
output is similar to this one
```
Datacenter: datacenter1
=======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address    Load       Tokens       Owns    Host ID                               Rack
UN  10.89.0.8  204 KB     256          ?       6acc8e6b-3158-4bfb-a829-242ca19b5c53  rack1
```
### Step 4
Create any number of nodes you like for the datacenter1 using the IP we just copied as the seed for the newer one. In my case it was 10.89.0.8. Along with the copied IP, put ip of NodeY (little bit unsure why, but docker command puts it, need to learn more about seeds) if it's for datacenter1
```
podman run --network=dc1 --name NodeY -v ./scylla/scylla.yaml:/etc/scylla/scylla.yaml -v ./scylla/cassandra-rackdc.properties.dc1:/etc/scylla/cassandra-rackdc.properties -d scylladb/scylla --seeds=10.89.0.8,10.89.0.9 --smp 1 --memory 256M --overprovisioned 1 --api-address 0.0.0.0
podman run --network=dc1 --name NodeZ -v ./scylla/scylla.yaml:/etc/scylla/scylla.yaml -v ./scylla/cassandra-rackdc.properties.dc1:/etc/scylla/cassandra-rackdc.properties -d scylladb/scylla --seeds=10.89.0.8,10.89.0.9 --smp 1 --memory 256M --overprovisioned 1 --api-address 0.0.0.0
```

### Step 5
Similar to the datacenter1 now create nodes for datacenter2. Note, for the first node of datacenter1 we link NodeX.
```
podman run --network=dc2 --name NodeA -v ./scylla/scylla.yaml:/etc/scylla/scylla.yaml -v ./scylla/cassandra-rackdc.properties.dc2:/etc/scylla/cassandra-rackdc.properties -d scylladb/scylla --seed=10.89.0.8 --smp 1 --memory 256M --overprovisioned 1 --api-address 0.0.0.0
```

### Step 6
Now it's time for manual lookup of ip address for the first node of datacenter2. Run the following command then copy the IP address from the result. 
```
podman exec -it NodeA nodetool status
```
### Step 7
Then, reate any number of nodes you like for the datacenter2 using the IP we just copied as the seed for the newer one. In my case it was 10.89.1.2. Along with the IP of NodeX, put IP of NodeB if it's for datacenter2 as seeds.
```
podman run --network=dc2 --name NodeB -v ./scylla/scylla.yaml:/etc/scylla/scylla.yaml -v ./scylla/cassandra-rackdc.properties.dc2:/etc/scylla/cassandra-rackdc.properties -d scylladb/scylla --seeds=10.89.0.8,10.89.1.2 --smp 1 --memory 256M --overprovisioned 1 --api-address 0.0.0.0
podman run --network=dc2 --name NodeC -v ./scylla/scylla.yaml:/etc/scylla/scylla.yaml -v ./scylla/cassandra-rackdc.properties.dc2:/etc/scylla/cassandra-rackdc.properties -d scylladb/scylla --seeds=10.89.0.8,10.89.1.2 --smp 1 --memory 256M --overprovisioned 1 --api-address 0.0.0.0
```
### Step 8
Finally, you can view your nodes in each datacenter by running the following command on any node.
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
UN  10.89.0.9   640 KB     256          ?       e211fdc4-670b-4645-a583-4ba0ef3b4a16  Rack1
UN  10.89.0.8   556 KB     256          ?       c9c3d494-fe26-4dc4-b930-1941ad18692a  Rack1
UN  10.89.0.10  752 KB     256          ?       a24d5f40-79e2-4683-bb12-85a991950bf8  Rack1
Datacenter: DC2
===============
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address     Load       Tokens       Owns    Host ID                               Rack
UN  10.89.1.3   772 KB     256          ?       c3f78088-0eea-47a2-92c1-06f46bf49761  Rack1
UN  10.89.1.2   788 KB     256          ?       28f83659-d835-47bc-aba2-3dde9aab09cd  Rack1
UN  10.89.1.4   844 KB     256          ?       4513b9d2-7081-4af0-8004-e68a38abd188  Rack1

Note: Non-system keyspaces don't have the same replication settings, effective ownership information is meaningless
```
<img src="https://university.scylladb.com/wp-content/uploads/2019/01/Screenshot-from-2019-01-22-17-24-32.png" />
