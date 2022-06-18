
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../model/video_file_dir_model.dart';
import '../utils/my_icons_utils.dart';

class BindingDanmaku extends StatefulWidget {
  const BindingDanmaku({Key? key, required this.videoInfo}) : super(key: key);
  final VideoFileDirModel videoInfo;

  @override
  State<BindingDanmaku> createState() => _BindingDanmakuState();
}

class _BindingDanmakuState extends State<BindingDanmaku> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(),
        actions: [
          TextButton(onPressed: () {}, child: const Text("搜索", style: TextStyle(color: Colors.black),))
        ],
      ),
      body: Column(
        children: [
          ListTile(
            horizontalTitleGap: 0,
            contentPadding: const EdgeInsets.only(left: 16, right: 0),
            leading: const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                MyIconsUtils.folderFullBackground,
                size: 40,
                color: Colors.black26,
              ),
            ),
            title: Text(
              widget.videoInfo.getFullName,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            trailing: TextButton(onPressed: () {} ,child: Text("弹·移除"),),
          ),
          Divider(),
          Expanded(child: Center(child: Text("暂无数据"),))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles();
          if (result != null) {
            List<String?> paths = result.paths;
            if (paths.isNotEmpty) {
              print(paths[0]);
            }
          }
        },
        tooltip: '选择本地弹幕',
        child: const Icon(Icons.phone_android_rounded),
      ),
    );
  }
}
