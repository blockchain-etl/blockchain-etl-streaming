# Blockchain ETL Streaming

Streams the following Ethereum entities to Pub/Sub using 
[ethereum-etl stream](https://github.com/blockchain-etl/ethereum-etl#stream):

- blocks
- transactions
- logs
- token_transfers 
- traces
- contracts
- tokens

Streams blocks and transactions to Pub/Sub using 
[bitcoin-etl stream](https://github.com/blockchain-etl/bitcoin-etl#stream). Supported chains:

- bitcoin
- bitcoin_cash
- dogecoin
- litecoin
- dash
- zcash

## Deployment Instructions

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

3. Create Pub/Sub topics (use `create_pubsub_topics_ethereum.sh`)
  - "crypto_ethereum.blocks" 
  - "crypto_ethereum.transactions" 
  - "crypto_ethereum.token_transfers" 
  - "crypto_ethereum.logs" 
  - "crypto_ethereum.traces" 
  - "crypto_ethereum.contracts" 
  - "crypto_ethereum.tokens" 

Put the prefix to `ethereum_base/configMap.yaml`, `PUB_SUB_TOPIC_PREFIX` property.

4. Create GCS bucket. Upload a text file with block number you want to start streaming from to 
`gs:/<YOUR_BUCKET_HERE>/ethereum-etl/streaming/last_synced_block.txt`.
Put your GCS path to `overlays/ethereum/block_data/configMap.yaml`, `GCS_PREFIX` property, 
e.g. `gs:/<YOUR_BUCKET_HERE>/ethereum-etl/streaming`.

5. Update `ethereum_base/configMap.yaml`, `PROVIDER_URI` property to point to your Ethereum node.

5. Create "ethereum-etl-app" service account with roles:
    - Pub/Sub Editor
    - Storage Object Admin

Download the key. Create a Kubernetes secret:

```bash
kubectl create secret generic streaming-app-key --from-file=key.json=$HOME/Downloads/key.json
```

6. Install [helm] (https://github.com/helm/helm#install) 

```bash
brew install helm
helm init
```
7. Copy [example values](example_values) directory to `values` dir and adjust all the files at least with your bucket and project ID.
8. Install ETL apps via helm using chart from this repo and values we adjust on previous step, for example:
```bash
helm install --name btc --namespace btc charts/blockchain-etl-streaming --values values/bitcoin/bitcoin/values.yaml
helm install --name bch --namespace btc charts/blockchain-etl-streaming --values values/bitcoin/bitcoin_cash/values.yaml
helm install --name dash --namespace btc charts/blockchain-etl-streaming --values values/bitcoin/dash/values.yaml
helm install --name dogecoin --namespace btc charts/blockchain-etl-streaming --values values/bitcoin/dogecoin/values.yaml
helm install --name litecoin --namespace btc charts/blockchain-etl-streaming --values values/bitcoin/litecoin/values.yaml
helm install --name zcash --namespace btc charts/blockchain-etl-streaming --values values/bitcoin/zcash/values.yaml

helm install --name eth-blocks --namespace eth charts/blockchain-etl-streaming \ 
--values values/ethereum/values.yaml --values values/ethereum/block_data/values.yaml
helm install --name eth-traces --namespace eth charts/blockchain-etl-streaming \ 
--values values/ethereum/values.yaml --values values/ethereum/trace_data/values.yaml 

helm install --name eos-blocks --namespace eos charts/blockchain-etl-streaming --values values/eos/block_data/values.yaml
``` 
Ethereum block and trace data streaming are decoupled for higher reliability. 

9. Use `describe` command to troubleshoot, f.e. :

```bash
kubectl describe pods -n btc
kubectl describe node [NODE_NAME]
```

Refer to [blockchain-etl-dataflow](https://github.com/blockchain-etl/blockchain-etl-dataflow)
for connecting Pub/Sub to BigQuery.
