#!/usr/bin/env bash

gcloud deployment-manager deployments create ethereum-etl-pubsub-0 --template deployment_manager_pubsub.py