# 妙传IM

这是一个基于Flutter的IM客户端项目，服务端依托webchat，需要将webchat服务部署后即可打包使用，是一个局域网测试调试传输的工具。当然也可以将服务部署到公网。只需在设置中将连接改为相应地址。

## 部署：
#### 获取 webchat -> https://github.com/xiaour/webchat.git
- 1.webchat 需要java环境支持，在打包后部署jar即可
- 2.flutter-im 需要根据想要打包的客户端进行安装，flutter 安装步骤请参考官方文档。
- 3.在环境配置完成后，选择相应设备进行安装客户端。打开客户端配置好webchat的连接地址，即可使用。

## 使用：
- 1.浏览器打开部署的webchat地址，默认端口8080。
![image](https://oscimg.oschina.net/oscnet/6ea943d0a08edf9d0f6b7677ad2bbdcde33.jpg)
- 2.在移动端设置中填写webchat的IP和端口，保存后刷新设备列表。这时，就可以跨设备使用我们的IM啦！
![image](https://oscimg.oschina.net/oscnet/3dd0bb2e21cda20a175f0fc0ec656b73fd7.jpg)


## Flutter Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.io/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.io/docs/cookbook)

For help getting started with Flutter, view our 
[online documentation](https://flutter.io/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
