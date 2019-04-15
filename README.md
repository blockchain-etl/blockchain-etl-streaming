# Ethereum ETL Streaming

Streams blocks and transactions to a Pub/Sub topic.

1. Create a cluster:

```bash
gcloud container clusters create ethereum-etl-streaming \
--zone us-central1-a \
--num-nodes 1 \
--disk-size 10GB \
--machine-type custom-2-4096 \
--network default \
--subnetwork default \
--scopes pubsub,storage-rw,logging-write,monitoring-write,service-management,service-control,trace
```

2. Get `kubectl` credentials:

```bash
gcloud container clusters get-credentials ethereum-etl-streaming \
--zone us-central1-a
```

3. Create Pub/Sub topics 
  - "crypto_ethereum.blocks" 
  - "crypto_ethereum.transactions" 
  - "crypto_ethereum.token_transfers" 
  - "crypto_ethereum.logs" 
  - "crypto_ethereum.traces" 
  - "crypto_ethereum.contracts" 
  - "crypto_ethereum.tokens" 

Put the prefix to `overlays/ethereum/configMap.yaml`, `PUB_SUB_TOPIC_PREFIX` property.

4. Create GCS bucket. Upload a text file with block number you want to start streaming from to 
`gs:/<your-bucket>/ethereum-etl/streaming/last_synced_block.txt`.
Put your GCS path to `base/configMap.yaml`, `GCS_PREFIX` property, e.g. `gs:/<your-bucket>/ethereum-etl-streaming`.

5. Update `overlays/ethereum/configMap.yaml`, `PROVIDER_URI` property to point to your Ethereum node.

5. Create "ethereum-etl-app" service account with roles:
    - Pub/Sub Editor
    - Storage Object Creator

Download the key. Create a Kubernetes secret:

```bash
kubectl create secret generic streaming-app-key --from-file=key.json=$HOME/Downloads/key.json
```

6. Install kustomize https://github.com/kubernetes-sigs/kustomize/blob/master/docs/INSTALL.md. 

```bash
brew install kustomize
```

Create the application:

```bash
kustomize build overlays/ethereum/block_data | kubectl apply -f -
```

7. To troubleshoot:

```bash
kubectl describe pods
kubectl describe node [NODE_NAME]
```