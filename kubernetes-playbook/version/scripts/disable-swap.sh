#!/bin/bash
swapoff -a
sysctl -w vm.swappiness=0
