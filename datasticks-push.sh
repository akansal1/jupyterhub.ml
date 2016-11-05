#!/bin/sh

kubectl delete rc prediction                                                            
kubectl create -f /root/prediction-rc.yaml 
