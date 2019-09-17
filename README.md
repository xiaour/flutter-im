# 妙传IM

这是一个基于Flutter的IM客户端项目，服务端依托webchat，需要将webchat服务部署后即可打包使用，是一个局域网测试调试传输的工具。当然也可以将服务部署到公网。只需在设置中将连接改为相应地址。

## 部署：
#### 获取 webchat -> https://github.com/xiaour/webchat.git
- 1.webchat（妙传服务端） 需要java环境支持，在打包后部署jar即可
- 2.flutter-im（妙传客户端） 需要根据想要打包的客户端进行安装，flutter 安装步骤请参考官方文档。
- 3.在环境配置完成后，选择相应设备进行安装客户端。打开客户端配置好webchat的连接地址，如果不修改端口和项目名称webchat地址是"http://your.ip/8099/webchat"。
- 4.flutter-im（妙传客户端） 在手机上安装后，需要在设置中输入"ws://your.ip/8099/webchat"，之后重新打开客户端或者点击首页刷新按钮，即可连接到服务器。

## 使用：
- 1.浏览器打开部署的webchat（妙传服务端）地址，默认端口8099.
![image](https://oscimg.oschina.net/oscnet/6ea943d0a08edf9d0f6b7677ad2bbdcde33.jpg)
- 2.在移动端设置中填写webchat的IP和端口，保存后刷新设备列表。这时，就可以跨设备使用我们的IM啦！
![image](https://oscimg.oschina.net/oscnet/afed443ce11b8a756b01e0d20232c770838.jpg)

