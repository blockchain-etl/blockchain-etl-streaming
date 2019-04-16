#!/usr/bin/env bash

gcloud deployment-manager deployments create bitcoin-etl-pubsub-0 --template deployment_manager_pubsub_bitcoin.py