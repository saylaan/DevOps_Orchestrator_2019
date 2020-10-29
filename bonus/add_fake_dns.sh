/#!/bin/sh

# #Adds 2 fake DNS to /etc/hosts
echo " $(kubectl get nodes -o jsonpath='{ $.items[*].status.addresses[?(@.type =="ExternalIP")].address }') poll.dop.io result.dop.io" \
| sudo tee -a /etc/hosts
