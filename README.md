# Open Conference Systems

OCS Docker version 

https://pkp.sfu.ca/ocs/

## Basic install

```
wget https://raw.githubusercontent.com/TiagoDGomes/docker-ocs/main/Dockerfile -O Dockerfile

docker build -t tiagodgomes/docker-ocs .

docker container run --name ocs -p 12345:80 tiagodgomes/docker-ocs
```
