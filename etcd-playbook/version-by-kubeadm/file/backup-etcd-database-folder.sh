#!/bin/bash
cp -pr {{ etcd_data_path }} {{ etcd_data_path }}-backup-`date +%F-%H-%M-%S`
