# 常见故障排错方法
1. 前端Web UI的日志如果还不能判断出具体问题所在，可以在部署机上输入命令 docker logs -f deploy-main 来获取更详细的日志
2. docker、registry、etcd、k8s这四个角色是缺一不可的，不能缺少组件。
3. 节点主机内存不能太低，建议最少4G配置，否则kubeadm部署过程中master节点可能会卡死在等待kubelet服务启动的过程中而导致最终部署失败。
4. Breeze部署工具底层是调用ansible执行playbook脚本，所以对宿主机环境而言，python的版本兼容性是相关联的，如果在部署中看见了Failed to import docker-py - No module named 'requests.packages.urllib3'. Try pip install docker-py这样的信息，请修正您宿主机的python依赖问题后再进行部署。
5. Breeze暂不支持非root账号的环境部署，因此请确保您部署机到各个服务器节点是直接root ssh免密的。
6. 部署好之后，dashboard的端口是30300，但是谷歌浏览器是不可以访问的，火狐可以，这个是浏览器安全设置问题，和部署没有关系。
7. 由于CentOS的特性，部署之后内核并未启动ipvs，因此kube-proxy服务中会看见警告日志，退回iptables方式，这个只需要将所有节点重启一次即可解决。
8. 在部署机上，一定不要忘记执行“（1）对部署机取消SELINUX设定及放开防火墙”，否则会导致selinux的限制而无法创建数据库文件cluster.db，页面提示“unable to open database file”。
9. 不要这样去关闭防火墙 systemctl stop firewalld 或 systemctl disable firewalld，我们的部署过程中已经做了正确的防火墙规则设定，服务是必须开启的，只是设定为可信任模式，也就是放开所有访问策略，如果你需要设定严格的防火墙规则，请自行学习研究清楚firewall-cmd的用法。

详细注解：
iptables与firewalld都不是真正的防火墙，它们都只是用来定义防火墙策略的防火墙管理工具而已，或者说，它们只是一种服务。iptables服务会把配置好的防火墙策略交由内核层面的netfilter网络过滤器来处理，而firewalld服务则是把配置好的防火墙策略交由内核层面的nftables包过滤框架来处理。对于RHEL/CentOS 7系列，我们推荐的做法就是删掉iptables服务启用firewalld服务，注意不是删掉iptables命令。然后用命令firewall-cmd --set-default-zone=trusted来“关闭”防火墙。这样docker和kubernetes运行时才不会出故障。
docker最终还是要调用iptables命令的，它不在乎你的系统底层究竟是iptables服务还是firewalld服务，总之要么转换成netfilter模块执行要么转换成nftables模块执行。我们的部署程序，在安装docker的环节中，已经为您的主机做了这样的设置。也就是防火墙服务是active的，但是policy是trusted，这样是最佳方法。当然如果您实际生产环境不允许过于宽松的防火墙，可以手动再去使用firewall-cmd命令控制严格的具体ACL条目。

10. 所有被部署的服务器在部署工作开始之前请使用命令：
    ```
    hostnamectl set-hostname 主机名 
    ```
    确保环境合规。

10. 所有被部署的服务器在部署工作开始之前请使用命令：
    ```
    hostnamectl set-hostname 主机名 
    ```
    确保环境合规。

11. 如何在已经部署好的K8S集群内添加新的Node节点

##v1.12.1及之前版本的breeze

（1）做好部署机到新加节点的ssh免密登录工作。

（2）在主机页面添加新的主机。

（3）在服务组件页面，编辑kubernetes组件，在“Kubernetes node hosts”项中，把新添加的主机选择进来，点确定。

（4）在服务组件页面，选择docker和Kubernetes服务，去掉registry和etcd前面的对勾，然后点击开始安装。

（5）安装完毕后，通过kubectl get nodes确认新节点已经添加进来。

##v1.12.2及之后版本的breeze

（1）做好部署机到新加节点的ssh免密登录工作。

（2）在主机页面添加新的主机。

（3）在服务组件页面，编辑kubernetes组件，在“Kubernetes node hosts”项中，把新添加的主机选择进来，点确定。

（4）在服务组件页面，选择docker，去掉**Kubernetes**、registry和etcd前面的对勾，然后点击开始安装。部署程序会在新添加的主机上安装docker。**注意：一定不要选择Kubernetes项，因为新版的breeze在Kubernetes步骤会创建新的证书，重启节点后由于证书的变动会导致集群不可用。**

（5）在每个新添加节点执行如下命令：
```
kubeadm join --token 904250.ab14566918c0703b {{ endpoint }} --discovery-token-unsafe-skip-ca-verification --ignore-preflight-errors=cri {{ endpoint }}。
sed -i "s/.*server:.*/ server: https:\/\/{{ endpoint }}/g" /etc/kubernetes/kubelet.conf
```
其中，endpoint为breeze的web页面上Kubernetes组件所填的“Kubernetes entry point”。
（6）安装完毕后，通过kubectl get nodes确认新节点已经添加进来。
