# Ethereum ETL Streaming

Streams blocks, transactions, receipts, logs, token transfers to a PubSub topic.

1. Create a cluster:

```bash
gcloud container clusters create ethereum-etl-streaming \
--zone europe-west1-b \
--num-nodes 1 \
--disk-size 20GB \
--machine-type custom-2-4096 \
--scopes pubsub,storage-rw,logging-write,monitoring-write,service-management,service-control,trace
```

2. Get `kubectl` credentials:

```bash
gcloud container clusters get-credentials ethereum-etl-streaming \
--zone europe-west1-b
```

3. Create PubSub topic "ethereum_blockchain". Put it to `./configMaps/dev.properties`

4. Create GCS bucket. Upload a text file with block number you want to start streaming from to 
`gs:/<your-bucket>/ethereum-etl/streaming/last_synced_block.txt`.

5. Create a config map:

```bash
kubectl create configmap ethereum-etl-config \
--from-env-file=ethereum-etl-streaming/configMaps/dev.properties
```

6. Create "ethereum-etl-app" service account with roles:
    - Pub/Sub Editor
    - Storage Object Creator

Download the key. Create a Kubernetes secret:

```bash
kubectl create secret generic ethereum-etl-app-key --from-file=key.json=$HOME/Downloads/key.json
```

7. Create the application:

```bash
kubectl apply -f ethereum-etl-streaming/kube.yml
```

8. To troubleshoot:

```bash
kubectl describe pods
kubectl describe node [NODE_NAME]
```