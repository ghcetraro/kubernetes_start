#!/bin/bash

#recargar configuraciones
systemctl daemon-reload
systemctl restart kubelet

#bajar las imagenes necesarias
docker pull k8s.gcr.io/kube-apiserver:v1.15.2           
docker pull k8s.gcr.io/kube-scheduler:v1.15.2             
docker pull k8s.gcr.io/kube-controller-manager:v1.15.2            
docker pull k8s.gcr.io/kube-proxy:v1.15.2             
docker pull k8s.gcr.io/coredns:1.3.1               
docker pull k8s.gcr.io/etcd:3.3.10            
docker pull k8s.gcr.io/pause:3.1                

#iniciar ambiente kubernetes/admin
kubeadm init --kubernetes-version=v1.15.2

#kubeadm init --apiserver-advertise-address=10.0.15.10 --pod-network-cidr=10.244.0.0/16

#Create new '.kube' configuration directory
rm -frv $HOME/.kube

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#deploy the flannel 
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f kube-flannel.yml

#verificacion
kubectl get nodes
kubectl get pods --all-namespaces