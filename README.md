
## Prequisites

## Start Docker Container
```
sudo docker run -itd --name=jupyterhub --net=host -e SPARK_MASTER="--master local[*]" -e SPARK_SUBMIT_ARGS="--packages com.amazonaws:aws-java-sdk:1.10.34,org.apache.hadoop:hadoop-aws:2.6.0 --jars /root/lib/jpmml-sparkml-package-1.0-SNAPSHOT.jar --py-files /root/lib/jpmml.py" fluxcapacitor/jupyterhub
```

## Verify Successful Start through Logs
```
sudo docker logs -f jupyterhub

### EXPECTED OUTPUT ###
...
[I 2016-09-07 16:29:07.389 JupyterHub app:968] Starting proxy @ http://*:8764/
16:29:07.482 - info: [ConfigProxy] Proxying http://*:8764 to http://127.0.0.1:8081
16:29:07.484 - info: [ConfigProxy] Proxy API at http://127.0.0.1:8765/api/routes
[I 2016-09-07 16:29:07.493 JupyterHub app:1254] JupyterHub is now running at http://127.0.0.1:8764/
...
```

## (Optional) Verify Successful Start through Bash
* Bash into the Docker Container 
```
sudo docker exec -it jupyterhub bash
```
* From within the Docker Container
```
ps -aef | grep jupyterhub

*** EXPECTED OUTPUT ***
...
root         1     0  0 16:29 ?        00:00:00 /usr/bin/python3 /usr/local/bin/jupyterhub --config=jupyterhub_config.py
...
```

## (Optional) Build new Docker Image
* From the directory that contains the jupyterhub.ml `Dockerfile`, run the following command:
```
sudo docker build -t fluxcapacitor/jupyterhub .
```



