# DevOps_Containerization_2019

Simple poll web application.
Poll is a Python Flask web application that gathers the votes to push them into a Redis queue.
The JavaWorker consumes the votes stored in the Redis queue, then pushes it into a PostgreSQL database.
Finally, the Node.js Result web application fetches the votes from the DB and displays the result.

A container orchestrator, integrated part between the system and application, application service, functioning on the different nodes (Load balancer)

You are to define 1 load balancer, 2 databases and 3 services, two of which will be routed using Traefik.

1. redis:
    - Based on redis:5.0.
    - Namespace: default.
    - Not replicated.
    - Always restarts.
    - Exposes port 6379.
    - Isn’t enabled on Traefik.

2. postgres:
    - Based on postgres:12.
    - Namespace: default.
    - Not replicated.
    - Always restarts.
    - Exposes port 5432.
    - Isn’t enabled on Traefik.
    - Has a persistant volume: /var/lib/postgresql/data.
    - Environment variables:
        - POSTGRES_HOST
        - POSTGRES_PORT
        - POSTGRES_DB
        - POSTGRES_USER
        - POSTGRES_PASSWORD

3. poll:
    - Based on epitechcontent/t-dop-600-poll:k8s.
    - Namespace: default.
    - Replicated: once (== 2 instances).
    - Always restarts.
    - No more than 128M of memory
    - Exposes port 80.
    - Has a Traefik rule matching poll.dop.io host and proxying to poll service.
    - Environment variables:
    - REDIS_HOST

4. worker:
    - Based on epitechcontent/t-dop-600-worker:k8s.
Namespace: default.
    - Not replicated.
    - No more than 256M of memory
    - Always restarts.
    - Isn’t enabled on traefik.
    - Environment variables:
        - REDIS_HOST
        - POSTGRES_HOST
        - POSTGRES_PORT
        - POSTGRES_DB
        - POSTGRES_USER
        - POSTGRES_PASSWORD

5. result:
    - Based on epitechcontent/t-dop-600-result:k8s.
    - Namespace: default.
    - Replicated: once (== 2 instances).
    - No more than 128M of memory
    - Always restarts.
    - Exposes port 80.
    - Has a Traefik rule matching result.dop.io host and proxying to result service.
    - Environment variables:
        - POSTGRES_HOST
        - POSTGRES_PORT
        - POSTGRES_DB
        - POSTGRES_USER
        - POSTGRES_PASSWORD

6. traefik:
    - Based on traefik:1.7.
    - Namespace: kube-public.
    - Replicated: once (== 2 instances).
    - Always restarts.
    - Traefik needs authorization to access Kubernetes internal API.
    - Exposes port 80 (http proxy) and 8080 (admin dashboard) into k8s cluster.
    - Exposes port 30021 (http proxy) and 30042 (admin dashboard) on host.

7. cadvisor:
    - Based on google/cadvisor:latest.
    - Namespace: kube-system.
    - Scheduled on all nodes.
    - Always restarts.
    - Exposes port 8080.

open the poll application into your browser:
    - result: result.dop.io:30021
    - poll: poll.dop.io:30021
    - Traefik dashboard: localhost:30042

tested with:
kubectl apply -f cadvisor . daemonset . yaml
kubectl apply -f postgres . secret . yaml \
                -f postgres . configmap . yaml \
                -f postgres . volume . yaml \
                -f postgres . deployment . yaml \
                -f postgres . service . yaml
kubectl apply -f redis . configmap . yaml \
                -f redis . deployment . yaml \
                -f redis . service . yaml
kubectl apply -f poll . deployment . yaml \
                -f worker . deployment . yaml \
                -f result . deployment . yaml \
                -f poll . service . yaml \
                -f result . service . yaml \
                -f poll . ingress . yaml \
                -f result . ingress . yaml
kubectl apply -f traefik . rbac . yaml \
                -f traefik . deployment . yaml \
                -f traefik . service . yaml

## Create database manually after first deploy

```echo 'CREATE TABLE votes (id text PRIMARY KEY , vote text NOT NULL );' \
| kubectl exec -i postgres - deployment -id  -c postgres - container -id  -- psql -U username
```

## Adds 2 fake DNS to /etc/ hosts

```echo "$( kubectl get nodes -o jsonpath ='{ $. items [*]. status . addresses [?( @. type =="
ExternalIP ") ]. address }') poll .dop .io result .dop .io" \
| sudo tee -a /etc/ hosts
```

![alt text](https://github.com/saylaan/DevOps_Containerization_2019/blob/master/T-DOP-600_docker.jpg?raw=true)