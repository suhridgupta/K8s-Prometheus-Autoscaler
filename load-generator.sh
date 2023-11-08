#!/bin/bash

for i in {1..1000}; do
	curl http://$(kubectl get service sample-app -o jsonpath='{ .spec.clusterIP }')/metrics
done
