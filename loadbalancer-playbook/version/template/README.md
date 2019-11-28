关于HAProxy的相关超时设定介绍(haproxy.cfg文件)：

defaults
	mode	http					# 7层http代理，另有4层tcp代理
	log	global
	option	httplog					# 在日志中记录http请求、session信息等
	option	dontlognull				# 不要在日志中记录空连接
	option	http-server-close			# 后端为动态应用程序建议使用http-server-close，后端为静态建议使用http-keep-alive
	option	forwardfor	except	127.0.0.0/8	# haproxy将在发往后端的请求中加上"X-Forwarded-For"首部字段
	option	redispatch				# 当某后端down掉使得haproxy无法转发携带cookie的请求到该后端时，将其转发到别的后端上
	timeout	http-request	10s			# 此为等待客户端发送完整请求的最大时长，应该设置较短些防止洪水攻击，如设置为2-3秒
							# haproxy总是要求一次请求或响应全部发送完成后才会处理、转发，
	timeout	queue           1m			# 请求在队列中的最大时长，1分钟太长了。设置为10秒都有点长，10秒请求不到资源客户端会失去耐心
	timeout	connect         10s			# haproxy和服务端建立连接的最大时长，设置为1秒就足够了。局域网内建立连接一般都是瞬间的
	timeout	client          1m			# 和客户端保持空闲连接的超时时长，在高并发下可稍微短一点，可设置为10秒以尽快释放连接
	timeout	server          1m			# 和服务端保持空闲连接的超时时长，局域网内建立连接很快，所以尽量设置短一些，特别是并发时，如设置为1-3秒
	timeout	http-keep-alive 10s			# 和客户端保持长连接的最大时长。优先级高于timeout http-request高于timeout client
	timeout	check           10s			# 和后端服务器成功建立连接后到最终完成检查的时长(不包括建立连接的时间，只是读取到检查结果的时长)，
							# 可设置短一点，如1-2秒
	maxconn 3000					# 默认和前段的最大连接数，但不能超过global中的maxconn硬限制数

修改后建议配置为如下：

defaults
  mode                    http
  log                     global
  option                  tcplog
  option                  dontlognull
  option http-server-close
  option                  redispatch
  timeout http-request    2s
  timeout queue           3s
  timeout connect         1s
  timeout client          1h
  timeout server          1h
  timeout http-keep-alive 1h
  timeout check           2s
  maxconn                 18000

这里1小时的设定是为了kubectl命令连接到容器的shell里，比如执行kubectl exec -it centos-xxxx bash后不输入命令的时候能够不被立刻踢出
