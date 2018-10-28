# 常见故障排错方法
1. 前端Web UI的日志如果还不能判断出具体问题所在，可以在部署机上输入命令 docker logs -f deploy-main 来获取更详细的日志
2. docker、registry、etcd、k8s这四个角色是缺一不可的，不能缺少组件。
3. 节点主机内存不能太低，建议最少4G配置，否则kubeadm部署过程中master节点可能会卡死在等待kubelet服务启动的过程中而导致最终部署失败。
4. Breeze部署工具底层是调用ansible执行playbook脚本，所以对宿主机环境而言，python的版本兼容性是相关联的，如果在部署中看见了Failed to import docker-py - No module named 'requests.packages.urllib3'. Try pip install docker-py这样的信息，请修正您宿主机的python依赖问题后再进行部署。
5. Breeze暂不支持非root账号的环境部署，因此请确保您部署机到各个服务器节点是直接root ssh免密的。
6. 部署好之后，dashboard的端口是30300，但是谷歌浏览器是不可以访问的，火狐可以，这个是浏览器安全设置问题，和部署没有关系。
