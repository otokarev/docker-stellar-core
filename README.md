# Stellar Core Docker Image

[![Docker Stars](https://img.shields.io/docker/stars/otokarev/stellar-core.svg)](https://hub.docker.com/r/otokarev/stellar-core/)
[![Docker Pulls](https://img.shields.io/docker/pulls/otokarev/stellar-core.svg)](https://hub.docker.com/r/otokarev/stellar-core/)
[![Build Status](https://travis-ci.org/otokarev/docker-stellar-core.svg?branch=bare)](https://travis-ci.org/otokarev/docker-stellar-core/)
[![ImageLayers](https://images.microbadger.com/badges/image/otokarev/stellar-core.svg)](https://microbadger.com/#/images/otokarev/stellar-core)

Alpine-based image with `stellar-core` binary inside

**NOTE:**
- Images tagged with **extra** like **v0.10.0-extra** contain `curl` and `gcloud` executables also.

## Base usage example

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: "core1"
  labels:
    app: "core1"
    core_config_version: "core-v10"
spec:
  selector:
    matchLabels:
      app: "core1"
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 0
      maxUnavailable: 1
  template:
    metadata:
      labels:
        app: "core1"
        role: "core"
    spec:
      nodeSelector:
        failure-domain.beta.kubernetes.io/zone: "europe-west1-b"
      containers:
        - name: core
          image: "otokarev/stellar-core:v10.0.0-extra"
          ports:
          - name: core-peer
            containerPort: 11625
          - name: core-http
            containerPort: 11626
          command:
            - "sh"
            - "-c"
            - |
              cp ./configs/stellar-core.cfg ./
              [[ -n $NODE_SEED ]] && sed -i 's/^\s*NODE_SEED.*$/NODE_SEED="'$NODE_SEED'"/' /stellar-core.cfg || true;
              if [ -d /data/buckets ];
              then
              echo "/data/buckets exists, so skip DB schema creation";
              else
              echo "/data/buckets does not exist, initialize DB schema";
              exec /usr/local/bin/stellar-core --newdb
              fi;
              if [ "$(ls -1A /history | grep -v 'lost+found')" ]; then
              echo "History archives have been initialized already"
              else
              echo "History archives have not initialized yet. Initialize it."
              exec /usr/local/bin/stellar-core --newhist local
              fi
              exec /usr/local/bin/stellar-core
          livenessProbe:
            tcpSocket:
              port: 11626
            initialDelaySeconds: 20
            periodSeconds: 3
          readinessProbe:
            exec:
              command:
                - "/bin/bash"
                - "-c"
                - |
                  T=`/usr/local/bin/stellar-core --c info | egrep '[[:blank:]]+"age" : [[:digit:]]+,'` \
                  && [[ $T =~ [[:blank:]]([[:digit:]]+), ]] \
                  && [[ "${BASH_REMATCH[1]}" -lt "10" ]]
            initialDelaySeconds: 20
            periodSeconds: 10
          volumeMounts:
          - name: stellar-core-cfg
            mountPath: /configs
          - name: stellar-data
            mountPath: /data
            subPath: core-data
          - name: stellar-core-history-data
            mountPath: "/history"
          env:
            - name: NODE_SEED
              valueFrom:
                secretKeyRef:
                  name: "stellar-secrets-core1"
                  key: seed

        - name: core-db
          image: postgres
          ports:
          - name: core-pg
            containerPort: 5432
          env:
            - name: POSTGRES_USER
              value: core
            - name: POSTGRES_PASSWORD
              value: 1q2w3e
            - name: PGPORT
              value: "5432"
          volumeMounts:
          - name: stellar-data
            subPath: core-pgdata
            mountPath: /var/lib/postgresql/data
      volumes:
        - name: stellar-core-cfg
          secret:
            secretName: stellar-cfg-core1-core-v10
        - name: stellar-data
          gcePersistentDisk:
            pdName: "stellar-validator-europe-west1-b"
            fsType: ext4
        - name: stellar-core-history-data
          gcePersistentDisk:
            pdName: "stellar-archive-europe-west1-b"
            fsType: "ext4"
```
