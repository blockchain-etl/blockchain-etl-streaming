#!/usr/bin/env bash

gcloud deployment-manager deployments create eos-etl-pubsub-0 --template deployment_manager_pubsub_eos.py
