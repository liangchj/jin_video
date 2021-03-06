import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'db/mmkv_cache.dart';
import 'model/video_file_dir_model.dart';
import 'page/video_directory_list.dart';
import 'utils/file_directory_utils.dart';
import 'utils/media_store_utils.dart';
import 'utils/permission_utils.dart';

void main() {
  runApp(const GetMaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: MMKVCacheInit.preInit(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: const MyHomePage(title: 'Flutter Demo Home Page'),
            );
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
    );
    /*return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );*/
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String? _dir;
  /// 是否已经申请权限
  bool _requestPermission = false;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  getMediaStoreVideoDirList() async {
    List<VideoFileDirModel> mediaStoreVideoList = await MediaStoreUtils.getMediaStoreVideoDirList();
    print("get end: $mediaStoreVideoList");
  }

  @override
  Widget build(BuildContext context) {
    if (!_requestPermission) {
      // List<Permission> permissionList = [Permission.storage, Permission.manageExternalStorage];
      List<Permission> permissionList = [Permission.storage];
      PermissionUtils.checkPermission(permissionList: permissionList, onPermissionCallback: (flag) {
        print("flag: $flag");
        setState((){
          _requestPermission = flag;
        });
      });
    } else {
      //getMediaStoreVideoDirList();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            TextButton(onPressed: () async {
              String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
              print("selectedDirectory:$selectedDirectory");
              if (selectedDirectory != null) {
                setState((){
                  _dir = selectedDirectory;
                });
              }
            }, child: const Text("获取目录")),
            TextButton(onPressed: () async {
              print("dir:$_dir");
              var dirListByPath = await FileDirectoryUtils.getNotEmptyDirListByPathAndFormatSync(path: _dir!, recursive: true);
              print("dirListByPath:$dirListByPath");
            }, child: const Text("打印获取目录")),
            TextButton(onPressed: () {
              Get.to(VideoDirectoryList(dir: _dir,));
            }, child: const Text("进入目录")),
            TextButton(onPressed: () {
              print("DefaultMMKVCache.getInstance():${DefaultMMKVCache.getInstance()}");
              DefaultMMKVCache.getInstance().setString("mmkv_str", "mmkv 存入字符串");
            }, child: const Text("存入字符串")),
            TextButton(onPressed: () {
              var string = DefaultMMKVCache.getInstance().getString("mmkv_str");
              print("mmkv 读取字符串 mmkv_str：$string");
            }, child: const Text("读取字符串")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
