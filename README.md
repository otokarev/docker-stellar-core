# Stellar Core Docker Image

This docker image does:
- and run Stellar core node process
- have no database engine onboard (database credentials must be specified in the `stellar-core.cfg`)
- can put history archives to Google Storage

The image uses the following software:

- [stellar-core](https://github.com/stellar/stellar-core)
- Google Cloud SDK
- Supervisord is used from managing the processes of the services above.

## Build
Run from the root directory of the project:
```text
docker build -t umbrellab/stellar-core-simplified:version0.1 .
```

## Container deployment
```text
docker run --name stellar-core-simplified \
    # required
    --env ARCHIVE_NAME=gcloud \
    # optional
    --env STELLAR_CORE_CFG_URL=<url to file with the config> \
    # optional
    --env STELLAR_CORE_CFG=<path to the config accessible from inside of container> \
    # optional
    --env NONEWDB=1 \
    # optional
    --env NONEWHIST=1 \
    # required if stellar-core.cfg contains __DATABASE_URL__ 
    --env DATABASE_URL="postgres://USER:PASSWORD@HOST:PORT/DBNAME?sslmode=disable" (or "postgresql://dbname=DBNAME user=USER port=PORT password=PASSWORD sslmode=disable")
    # required if stellar-core.cfg contains __GS_BUCKET_ARCHIVES_PATH__ 
    --env GS_BUCKET_ARCHIVES_PATH="gs://BUCKET/PATH"
    # required if NONEWHIST is undefined. 
    # Mount a directory with a service account key file.
    # The account must have access to Google Cloud Storage to store archives there.
    -v <directory with `credentilas.json`>:/secrets/gcloud/storage
    # optional
    # Mount a directory with stellar-core.cfg
    -v <directory with `stellar-core.cfg`>:/configs
    -it umbrellab/stellar-core-simplified:version0.1
```
if you do not want re-initialize a history archive storage pass an environment variable `--env NONEWHIST=1`

## How to 'put' archives to Google Storage

In `stellar-core.cfg` add:
```text
[HISTORY.gcloud]
get="/bin/bash /gsutil cp gs://stellar-history-archives/{0} {1}"
put="/bin/bash /gsutil cp {0} gs://stellar-history-archives/{1}"
```
Change `stellar-history-archives` for something suitable for you. `gcloud` can also be renamed.

Launch a container (`docker run`) with following flags:
```text
--env ARCHIVE_NAME=gcloud \
--env STELLAR_CORE_CFG_URL="https://...../stellar-core.cfg" \
```

## How to set DATABASE configuration parameter thru env parameter
Add in stellar-core.cfg
```
DATABASE="__DATABASE_URL__"
```
Launch container with
```
--env DATABASE_URL="postgres://USER:PASSWORD@HOST:PORT/DBNAME?sslmode=disable"
```
or 
```
--env DATABASE_URL="postgresql://dbname=DBNAME user=USER port=PORT password=PASSWORD sslmode=disable"
```

### Configurations files
* Default config file place is `/configs/stellar-core.cfg`
* This configuration file can be overridden by mounting volume to `/configs` with different one.
* Or `STELLAR_CORE_CFG_URL` variable pointing to the file in the Internet can be set.
* Or `STELLAR_CORE_CFG` variable pointing to the local file residing inside of container can be set.



## Regarding user accounts

Managing UIDs between a docker container and a host volume can be complicated.  At present, this image simply tries to create a UID that does not conflict with the host system by using a preset UID:  10011001.  Currently there is no way to customize this value.  All data produced in the host volume be owned by 10011001.  If this UID value is inappropriate for your infrastructure we recommend you fork this project and do a find/replace operation to change UIDs.  We may improve this story in the future if enough users request it.

## Ports

| Port  | Service      | Description          |
|-------|--------------|----------------------|
| 11625 | stellar-core | peer node port       |
| 11626 | stellar-core | main http port       |


## Accessing and debugging a running container

There will come a time when you want to inspect the running container, either to debug one of the services, to review logs, or perhaps some other administrative tasks.  We do this by starting a new interactive shell inside the running container:

```
$ docker exec -it stellar /bin/bash
```

The command above assumes that you launched your container with the name `stellar`; Replace that name with whatever you chose if different.  When run, it will open an interactive shell running as root within the container.

