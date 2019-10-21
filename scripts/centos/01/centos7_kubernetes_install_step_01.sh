#!/bin/bash

#iplocal
#ip addr show ens160 | grep -Po 'inet \K[\d.]+'

echo ' ' >> /etc/hosts
cat nodos.txt >> /etc/hosts

#deshabilitar selinux
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

#Enable br_netfilter Kernel Module
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

#deshabilitar swapp
swapoff -a
#deshabilitar permanentemente
sed -e '/centos-swap/ s/^#*/#/' -i /etc/fstab

#instalar librerias necesarios
yum install -y yum-utils device-mapper-persistent-data lvm2

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

yum install -y docker-ce

#Add the kubernetes repository to the centos 7
echo '[kubernetes]' >  /etc/yum.repos.d/kubernetes.repo
echo 'name=Kubernetes' >>  /etc/yum.repos.d/kubernetes.repo
echo 'baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64' >>  /etc/yum.repos.d/kubernetes.repo
echo 'enabled=1' >>  /etc/yum.repos.d/kubernetes.repo
echo 'gpgcheck=1' >>  /etc/yum.repos.d/kubernetes.repo
echo 'repo_gpgcheck=1' >>  /etc/yum.repos.d/kubernetes.repo
echo 'gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg' >>  /etc/yum.repos.d/kubernetes.repo

#install the kubernetes packages kubeadm, kubelet, and kubectl
yum install -y kubelet kubeadm kubectl

#activar servicios
systemctl enable docker && systemctl enable kubelet

#kuberetes cgroup-driver
mkdir -p /etc/systemd/system/kubelet.service.d

echo 'cgroup-driver=systemd' > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

#tambien se puede hacer
#/etc/docker/daemon.json
#{
#"exec-opts": ["native.cgroupdriver=systemd"]
#}

#reiniciar servicios
sudo reboot