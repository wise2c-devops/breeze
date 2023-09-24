# 常见故障排错方法
1. 前端Web UI的日志如果还不能判断出具体问题所在，可以在部署机上输入命令 docker logs -f deploy-main 来获取更详细的日志

2. docker、harbor、etcd、k8s这四个角色是缺一不可的，不能缺少组件，如果需要高可用，则Loadbalance角色必选。

3. 节点主机内存不能太低，建议最少4G配置，否则kubeadm部署过程中master节点可能会卡死在等待kubelet服务启动的过程中而导致最终部署失败。

4. Breeze部署工具底层是调用ansible执行playbook脚本，所以对宿主机环境而言，python的版本兼容性是相关联的，如果在部署中看见了Failed to import docker-py - No module named 'requests.packages.urllib3'. Try pip install docker-py这样的信息，请修正您宿主机的python依赖问题后再进行部署。
参考方法如下：
	```
	yum remove -y python-docker-py
	pip install urllib3==1.21.1
	pip install docker-py
	```
	解决后的验证条件是能正常运行下面命令不出错：
	```
	python
	import docker
	```

5. Breeze暂不支持非root账号的环境部署，因此请确保您部署机到各个服务器节点是直接root ssh免密的。

6. 部署好之后，dashboard的端口是30300，但是谷歌浏览器是不可以访问的，火狐可以，这个是浏览器安全设置问题，和部署没有关系。

7. 如果机器性能不是特别强，建议第一次部署时不勾选Prometheus角色，等k8s集群部署并运行就绪后单独勾选Prometheus角色进行部署以免失败。

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

11. 如果部署机经常用来做不同版本的部署，则需要在部署新版本前做清理，命令如下：

	更新docker-compose.yaml文件之前：
	```
	docker-compose stop
	docker-compose rm -f
	docker volume rm $(docker volume ls |grep playbook |awk '{print $2}')
	```
	下载新的docker-compose.yaml文件并执行：
	```
	docker compose up -d
	```

12. 重置组件相关注意事项：
	（1）重置所有组件不可以一次性勾选所有组件并点击重置，因为重置动作依赖于docker，因此应按照以下顺序进行组件的重置：
		prometheus、kubernetes、etcd、loadbalancer、harbor 可以一并勾选
		docker 上述组件重置完毕后再勾选进行重置
		
	（2）重置开始后，UI并不能动态刷新日志，需要人工手动刷新日志页面，待看见所有的重置都正常完成才表示重置过程结束
	
	（3）重置过程并不能多次执行，例如第一次重置正常，那么组件已经被删除，再做重置就会报错了
	
	（4）在宿主机某些软件设置不规范导致了K8S的安装失败，比如内存配置过低，提高了内存后重新部署，建议只需重置etcd和kubernetes组件再重新部署这两个组件即可。其它组件无需重新部署。

13. 凡是2020年以前发布的Breeze版本，请在部署完集群之后在三台master节点，手动执行以下命令替换/etc/kubernetes/kubelet.conf的内嵌证书：
	```	
	TIME_STRING=`date "+%Y-%m-%d-%H-%M-%S"`	
	cd /etc/kubernetes/	
	cp -p /etc/kubernetes/kubelet.conf /etc/kubernetes/kubelet.conf.$TIME_STRING	
	sed -i 's#client-certificate-data:.*$#client-certificate: /var/lib/kubelet/pki/kubelet-client-current.pem#g' kubelet.conf 	
	sed -i 's#client-key-data:.*$#client-key: /var/lib/kubelet/pki/kubelet-client-current.pem#g' kubelet.conf	
	systemctl restart kubelet	
	```
	另外，三台master主机上，添加一个crontab的脚本文件，脚本每半年执行一次，生成一个新的有效期为1年的配置文件，脚本如下：
	```
	#!/bin/bash
	
	TIME_STRING=`date "+%Y-%m-%d-%H-%M-%S"`
	cd /etc/kubernetes/
	mv admin.conf admin.conf.$TIME_STRING
	mv controller-manager.conf controller-manager.conf.$TIME_STRING 
	mv scheduler.conf scheduler.conf.$TIME_STRING
	
	kubeadm init phase kubeconfig admin
	kubeadm init phase kubeconfig controller-manager
	kubeadm init phase kubeconfig scheduler

	sed -i 's#server: https:.*$#server: https://127.0.0.1:6443#g' admin.conf
	sed -i 's#server: https:.*$#server: https://127.0.0.1:6443#g' controller-manager.conf
	sed -i 's#server: https:.*$#server: https://127.0.0.1:6443#g' scheduler.conf
	
	cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
	chown $(id -u):$(id -g) $HOME/.kube/config

	#restart controller-manager and scheduler
	docker ps|grep kube-controller-manager|awk '{print $1}'|xargs docker stop
	docker ps|grep kube-scheduler|awk '{print $1}'|xargs docker stop
	```

        比如我们将上述脚本保存为/root/renewk8scert.sh，则可以执行命令crontab -e后编辑如下内容保存即可：
	```
	0 0 1 1,7 * /root/renewk8scert.sh
	```
        这样系统每年的1月1日和7月1日的0:00会执行该脚本。

**如何检查系统证书有效期**

```
（1）检查证书有效时间的命令及参数：

openssl x509 -noout -text -in 证书文件全名 |grep Not

例如：

openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet-client-current.pem |grep Not

（2）所需检查的证书列表：

     a) 所有master节点

        /etc/kubernetes/pki/ca.crt
        /etc/kubernetes/pki/apiserver.crt
        /etc/kubernetes/pki/front-proxy-ca.crt
        /etc/kubernetes/pki/front-proxy-client.crt
        /etc/kubernetes/pki/apiserver-kubelet-client.crt

     b) master及worker节点（即：集群内所有节点）

        /var/lib/kubelet/pki/kubelet-client-current.pem

        **注意这个文件有效期每年会自动更新**

     c) 管理员操作kubectl命令的主机

        当前用户的.kube/config文件，例如/root/.kube/config 注意此证书有效性仅仅只影响管理员操作命令，对集群自身功能无影响

        这个证书比较特殊，检查的命令和参数有些不同，需要这样操作：

        cat /root/.kube/config | grep client-certificate-data | awk '{print $2}'|base64 -d | openssl x509 -noout -dates

        注意此文件其实是master节点/etc/kubernetes/admin.conf文件的一份拷贝
```

注意事项：

(1). 用户选了2020年开始的Breeze版本部署集群，长期运行没事，证书都会一直有效，也会自动轮新。

(2). 用户对现有的Breeze部署的K8s集群升级，新版本一定要选用2020年7月后的版本，否则kubeadm就把证书给换坏了，如果是手动升级，也千万要记得加参数kubeadm upgrade node --certificate-renewal=false

14. 自2021年7月开始发布的Breeze版本，Ubuntu16不再被支持，请使用Ubuntu18/Ubuntu20。同时，从2021年7月开始的版本，Docker也被更换为CRI-O（Harbor角色机除外），敬请留意。

    自2023年9月24开始发布的Breeze版本，CentOS 7.x 和 Ubuntu 18不再被支持，请使用 RHEL/AlmaLinux/RockyLinux/OracleLinux 8.x / 9.x 以及 Ubuntu 20 / Ubuntu 22。

15. 对于RHEL8系列，推荐使用RockyLinux8.4及以上版本，也可以使用AlmaLinux或OracleLinux的8.4及以上，但在准备基础最小环境的时候需要注意：

    AlmaLinux 及 OracleLinux 需要执行 yum install policycoreutils-python-utils 命令；AlmaLinux还需执行命令 yum install tar
