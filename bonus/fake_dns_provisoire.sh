#!/bin/sh
# Create dns, for Traefik dashboard, poll and result

echo "$(minikube ip) traefik-ui.minikube poll.dop.io result.dop.io" | sudo tee -a /etc/hosts