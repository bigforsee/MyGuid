#!/bin/bash

images=(
	kube-apiserver:v1.22.2
    kube-proxy:v1.22.2
	kube-controller-manager:v1.22.2
	kube-scheduler:v1.22.2
	coredns:1.8.4
	etcd:3.5.0-0
    pause:3.5
)

for imageName in ${images[@]} ; do
    docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
#   docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName  k8s.gcr.io/$imageName
done
