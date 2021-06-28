---
title: flutter阿里云实人认证&&真人认证(重点)
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



==安卓如果发布release进入人脸认证闪退则关闭混淆==

配置 build.gradle 手动关闭混淆开关

```
android {
        buildTypes {
            release {
                // Enables code shrinking, obfuscation, and optimization for only
                // your project's release build type.
                minifyEnabled false

                // Enables resource shrinking, which is performed by the
                // Android Gradle plugin.
                shrinkResources false
            }
        }
        ...
    }
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

因为每次`pod install`都会重置`bundle id`，所以每次install后都要设置插件的`bundle id`，**如果不设置，则无法唤起阿里云的认证界面， 返回-1**

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



#### ios 返回-1

- 情况1：你的插件的build id没有改，或者你阿里云上传的包bundle id 和你现在的应用bundle id不一致

如果上述还不能解决，则打开xcode，直接运行。看下更详细的日志

![image-20210527123542886](http://alimd.haloit.top/img/image-20210527123542886.png)



如果xcode报以下报错说明。你的bundle id还是和导入的不一致

```
2021-05-27 11:18:47.739858+0800 Runner[445:53013] 实人认证结果：
state: -1
errorCode: -2
  message: 请确认 RPSDK.bundle 正确导入到 Copy Bundle Resources 下
2021-05-27 11:18:47.740858+0800 Runner[445:53428] flutter: onRealPersonResult: -1
2021-05-27 11:18:47.741373+0800 Runner[445:53428] flutter: the realPerson result is :-1
2021-05-27 11:18:48.256073+0800 Runner[445:53410] SG ERROR: 1411
2021-05-27 11:18:48.258464+0800 Runner[445:53013] SG ERROR: 202
, There is a mismatch between application's bundle identifier and SecurityGuardSDK's jpg file (yw_1222).
2021-05-27 11:18:48.258701+0800 Runner[445:53013] SG ERROR: 601
2021-05-27 11:19:21.190231+0800 Runner[445:53431] [VERBOSE-2:profiler_metrics_ios.mm(184)] Error retrieving thread information: (ipc/send) invalid destination port

```

#### 再次掉-1坑

时隔几个月, 因为客户要换证书，换报名，所以真人认证要重新去阿里云生成再次掉进坑内，按照笔记都检查了一遍，还是返回-1， 打开xcode看到以下报错，很迷了。 我研究了很久。发现是阿里云返回的SKD是4.10版本比我之前能跑通的版本`4.6.2`要高。难道是因为版本兼容？

![image-20210527003503003](http://alimd.haloit.top/img/image-20210527003503003-20210527124842642.png)

或报以下错误

![image-20210628151332357](http://alimd.haloit.top/img/image-20210628151332357-20210628160501597.png)

然后回想一下。我确实只替换了加密图片`yw_1222_0769.jpg`sdk的运行文件，我并没有退换，虽然中文信息提示你的budle id和上传的额ipa不一致！ 其实不然，请使用最新的替换即可

![image-20210628151639294](http://alimd.haloit.top/img/image-20210628151639294.png)

具体的替换图解步骤如下

![image-20210628151813229](http://alimd.haloit.top/img/image-20210628151813229.png)



#### budle id没错，却一直提示项目的 Bundle ID 与上传的 ipa 文件 Bundle ID不一致

问题描述： 确定工程的bundle id和加密的一致，却一直提示。 很可能是因为你换了budle id 后,你的证书 和profile 没有绑定新的budle id

```
2021-06-28 14:30:59.906856+0800 Runner[1032:166167] [DYMTLInitPlatform] platform initialization successful
2021-06-28 14:31:00.536386+0800 Runner[1032:165932] Metal GPU Frame Capture Enabled
2021-06-28 14:31:00.539697+0800 Runner[1032:165932] Metal API Validation Enabled
2021-06-28 14:31:01.233967+0800 Runner[1032:166198] flutter: Observatory listening on http://127.0.0.1:49288/Z6k-yho7UoY=/
2021-06-28 14:31:05.602951+0800 Runner[1032:165932] SG ERROR: 204
2021-06-28 14:31:05.603328+0800 Runner[1032:165932] SG ERROR: 601
2021-06-28 14:31:05.604081+0800 Runner[1032:165932] 实人认证结果：
state: -1
errorCode: -2222
message: 1. 请确认当前项目的 Bundle ID 与上传的 ipa 文件 Bundle ID 一致。
2. 如果项目的 Bundle ID 有更新，需要重新下载 SDK 并替换 yw_1222_0769.jpg 文件。
3. 请确认在 Build Settings - Other Linker Flags 添加了 -ObjC，注意大小写。
4. 请确认项目正确导入了 SGMain.framework，并且为实人认证依赖的版本。
5. 请确认 yw_1222_0769.jpg 文件在传输过程中没有被通讯工具压缩。
6. 如果您使用私有 pod 方式接入，请使用主工程的 Bundle ID 作为 pod 工程 Bundle ID 的前缀。
2021-06-28 14:31:05.656316+0800 Runner[1032:166191] flutter: onRealPersonResult: -1
2021-06-28 14:31:05.657259+0800 Runner[1032:166191] flutter: the realPerson result is :-1
2021-06-28 14:31:08.186411+0800 Runner[1032:166183] SG ERROR: 1413
2021-06-28 14:31:08.188198+0800 Runner[1032:165932] SG ERROR: 204
2021-06-28 14:31:08.188382+0800 Runner[1032:165932] SG ERROR: 601
2021-06-28 14:32:42.775111+0800 Runner[1032:166267] [BoringSSL] nw_protocol_boringssl_error(1584) [C1.1:2][0x1053ab330] Lower protocol stack error: 54
2021-06-28 14:32:42.784071+0800 Runner[1032:166267] TIC Read Status [1:0x282084900]: 1:54
2021-06-28 14:32:42.784308+0800 Runner[1032:166267] TIC Read Status [1:0x282084900]: 1:54

```

##### 解决步骤1， 进入开发者后题啊，绑定新的budle id和证书

![image-20210628160849408](http://alimd.haloit.top/img/image-20210628160849408.png)

选择发布和开发证书

![image-20210628160749865](http://alimd.haloit.top/img/image-20210628160749865.png)

选择新的bundle id

![image-20210628160820081](http://alimd.haloit.top/img/image-20210628160820081.png)

选择request文件，这里用以前的即可。



![image-20210628161027557](http://alimd.haloit.top/img/image-20210628161027557.png)



生成证书后，双击运行安装，并到处p12证书文件





##### 解决步骤2，创建新的Budlle id和profile 文件

![image-20210628161201759](http://alimd.haloit.top/img/image-20210628161201759.png)

选择开发包， 

![image-20210628161251837](http://alimd.haloit.top/img/image-20210628161251837.png)



选择新的bundle id

![image-20210628161346193](http://alimd.haloit.top/img/image-20210628161346193.png)

生成新的证书，`comgsdfsdhsdgapp.mobileprovision`双击运行。(然后再打包新的ipad上传到阿里云生成新的sdk，替换加密图片, 有可能不需要，下次再测试看看)， 接下来真机调试看看吧



### 问题联系

最近很多人都邮箱问我问题。但是那个邮箱我已废弃使用了。有什么问题可以加我vx ymxz34787409



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
        // ios 返回-1 则说明你的插件的build id没有改，或者你阿里云上传的包bundle id 和你现在的应用bundle id不一致
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














