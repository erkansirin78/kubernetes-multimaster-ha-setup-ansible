#!/bin/bash

kubeadm init --control-plane-endpoint="192.168.206.36:6443" --upload-certs --apiserver-advertise-address=192.168.206.31 --pod-network-cidr=192.168.0.0/16
