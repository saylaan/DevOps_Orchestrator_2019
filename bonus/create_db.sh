#!/bin/sh

#Create database manually after first deploy
echo 'CREATE TABLE votes ( id text PRIMARY KEY , vote text NOT NULL );' \
| kubectl exec -i $(kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep postgres) -- psql -U spain -d orchestrator
