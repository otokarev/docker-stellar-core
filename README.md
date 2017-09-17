# Stellar Core Docker Image

This docker image does:
- upload `stellar-core.cfg` form URL specified at time the container lounch time 
- have no database engine onboard (database credentials must be specified in the `stellar-core.cfg`)
- put history archives to Google Storage

The image uses the following software:

- [stellar-core](https://github.com/stellar/stellar-core)
- Supervisord is used from managing the processes of the services above.

## Usage

TODO

### Configurations files

The default configurations will be copied into the data directory upon launching a persistent mode container for the first time.  Use the diagram below to learn about the various configuration files.

```
  /opt/stellar
  |-- core                  
  |   `-- etc
  |       `-- stellar-core.cfg  # Stellar core config
  `-- supervisor
      `-- etc
  |       `-- supervisord.conf  # Supervisord root configuration
```


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

### Restarting services

Services within the quickstart container are managed using [supervisord](http://supervisord.org/index.html) and we recommend you use supervisor's shell to interact with running services.  To launch the supervisor shell, open an interactive shell to the container and then run `supervisorctl`.  You should then see a command prompt that looks like:

```shell
stellar-core                     RUNNING    pid 125, uptime 0:01:13
supervisor>
```

From this prompt you can execute any of the supervisord commands:  

```shell
# stop stellar-core
supervisor> stop stellar-core  
```

You can learn more about what commands are available by using the `help` command.

### Viewing logs

Logs can be found within the container at the path `/var/log/supervisor/`.  A file is kept for both the stdout and stderr of the processes managed by supervisord.  Additionally, you can use the `tail` command provided by supervisorctl.

## Example launch commands


