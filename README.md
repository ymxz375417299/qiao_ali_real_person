---
title: flutter 阿里云实人认证
tags: 
- flutter
categories:
- 项目笔记
---





> 前言
>
> 阿里提供的实人认证还是很多坑的。本插件已爬过大部分的坑。并把ios/android端都打通了

### 阿里云开通实人认证

1. 开通实人认证，并进入控制台

   ![image-20210115180458290](http://alimd.haloit.top/img/20210115180458.png)

2. 如果灰色则点击开通

   ![image-20210115180523132](http://alimd.haloit.top/img/20210117232534.png)

1. 新建场景-活体人脸认证

![image-20210115180602979](http://alimd.haloit.top/img/20210115180616.png)

4. 先打包你的应用，上传apk/ios上传到阿里云

![image-20210115180706657](http://alimd.haloit.top/img/20210115180706.png)

上传后就会得到下载的压缩包，解压后会得到`yw_1222_0670.jpg`图片和一些依赖包。其中只用一部分





### 依赖

#### 复制插件

下载本插件，并复制到您的项目中。本次则复制到`/lib/plugins`为例，进行说明

![image-20210117224204709](http://alimd.haloit.top/img/20210117232641.png)

#### 添加依赖

```
  ali_real_person:
    path: ./lib/plugins/ali_real_person
```



### Android 设置

#### 复制加密图片yw_1222_0670.jpg

放到`/android/app/src/main/res/drawable/yw_1222_0670.jpg`

#### 修改/android/app/build.gradle

- 设置插件的lib文件

```json
android { 
	...省略
	
    repositories {
        flatDir {
            // 导入 阿里云插件的lib目录
            dirs project(':ali_real_person').file('libs')
        }
    }

	...省略
}


```

#### 在AndroidManifest.xml中配置以下内容（若有则忽略）

``/android/app/src/main/AndroidManifest.xml`

1. 在manifest标签新增

   `xmlns:tools="http://schemas.android.com/tools"`

```xml
   <manifest xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:tools="http://schemas.android.com/tools"
    package="com.example.heartBeat">

```

2. 在application头修改 + 配置相机权限

```xml
<!--配置相机权限-->
<uses-permission android:name="android.permission.CAMERA"/>

<application
  android:allowBackup="true"
  android:name="io.flutter.app.FlutterApplication"
  android:label="应用名称"
  android:icon="@mipmap/ic_launcher"
  tools:replace="android:label,android:allowBackup">
  ,,,,,
```



### ios配置

#### 先打包你的应用，ipa上传i到阿里云并获取SDK(已上传则忽略)

- 导入以下资源文件。导入时必须勾选`Copy items if needed`，表示自动复制一份相同的文件到工程中，并引用复制后的文件在工程目录中的位置。

  - yw_1222_0769.jpg
  - RPSDK.bundle
  - 其他依赖文件不用管

直接用鼠标把资源文件拖动到Runner下即可

![image-20210115233550528](http://alimd.haloit.top/img/20210117232814.png)

![image-20210115175120113](http://alimd.haloit.top/img/20210115175120.png)

 导入完成后，您可以在`Build Phases > Copy Bundle Resources`看到资源文件。如果未看到资源文件，则说明导入过程中出现问题，请确认将所有资源文件拷贝到工程项目，并勾选正确应用目标。

![image-20210115233507169](http://alimd.haloit.top/img/20210117232916.png)



#### 设置Podfile文件

```
platform :ios, '9.0'
```

#### info.plist添加相机权限，若有则忽略

	<key>NSCameraUsageDescription</key>
	<string>APP需要您授权才能访问相机</string>
#### 修改插件的bundle id 【重点!】

因为每次`pod install`都会重置`bundle id`，所以每次install后都要设置插件的`bundle id`，**如果不设置，则无法唤起阿里云的认证界面**

例： `org.cocoapods.ali-real-person` 修改为 `you_project_buildid.ali-real-person`

![image-20210117225157065](http://alimd.haloit.top/img/20210117232735.png)



- [IOS 集成常见问题](https://help.aliyun.com/document_detail/142592.html?spm=a2c4g.11186623.2.19.55d81ba8CmNrGP#concept-2333223)

### 错误解决【必须看】

![image-20210115174747835](http://alimd.haloit.top/img/20210115174748.png)

okhttp有可能和其他插件产生依赖冲突 

> 具体原因： 一个是jar包，一个是maven依赖，导致冲突了，所以要把jar包的删掉

 找出插件目录下的lib `/android/libs`删除这两个文件

```
okhttp-3.12.0.jar
okio-1.16.0.jar
```

然后，清除`clean flutter`再运行【必须】

![image-20210116133212690](http://alimd.haloit.top/img/20210117232842.png)









### Example

main.dart

```dart
import 'dart:io';

import 'package:ali_real_person/fl_ali_realperson.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  void initPlatformState() async {
    String platformVersion = "1";
    try {
      String token = 'b510468ab9384f5b99275c8be941309b';
      dynamic param;
      if (Platform.isIOS) {
        param = token;
      } else {
        param = {"token": token};
      }
      await QAliRealperson.startRealPerson(param, (result) {
        print("the realPerson result is :" + result);
      });
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: FlatButton(
              onPressed: () => initPlatformState(), child: Text("点击测试实人认证")),
        ),
      ),
    );
  }
}

```


