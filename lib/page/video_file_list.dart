import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jin_video/page/binding_danmaku.dart';

import '../model/video_file_dir_model.dart';
import '../utils/alert_dialog_utils.dart';
import '../utils/file_directory_utils.dart';
import '../utils/my_icons_utils.dart';

class VideoFileList extends StatefulWidget {
  const VideoFileList({Key? key, required this.dir}) : super(key: key);
  final String dir;

  @override
  State<VideoFileList> createState() => _VideoFileListState();
}

class _VideoFileListState extends State<VideoFileList> {
  List<VideoFileDirModel> _videoFileList = <VideoFileDirModel>[];
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    getVideoFileList();
  }

  /// 获取目录下的视频列表
  Future<void> getVideoFileList() async {
    List<VideoFileDirModel> fileListByPath =
        await FileDirectoryUtils.getFileListByPath(
            path: widget.dir, fileFormat: FileFormat.video);
    setState(() {
      _videoFileList = fileListByPath;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("视频列表build");
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dir.isEmpty ? "" : widget.dir.split("/").last),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: Text("加载中"),
            )
          : _videoFileList.isEmpty
              ? const Center(
                  child: Text("没有视频"),
                )
              : _buildVideoFileList(),
    );
  }

  /// 构建视频列表
  _buildVideoFileList() {
    return Scrollbar(
        child: ListView.builder(
            itemExtent: 78,
            itemCount: _videoFileList.length,
            itemBuilder: (context, index) {
              VideoFileDirModel videoInfo = _videoFileList[index];
              String path = videoInfo.path;
              return InkWell(
                onTap: () {},
                child: ListTile(
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
                    videoInfo.getFullName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: 8,
                            child: Text("弹", style: TextStyle(fontSize: 10))),
                        Text("${videoInfo.modTime}"),
                      ],
                    ),
                  ),
                  trailing: _buildRightOperateIcon(videoInfo, index),
                ),
              );
            }));
  }

  /// 视频右边操作图标
  IconButton _buildRightOperateIcon(VideoFileDirModel videoInfo, int index) {
    return IconButton(
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
        onPressed: () {
          print("onPressed,parentPath:${videoInfo.dir},${videoInfo.path}");
          /*Get.bottomSheet(_buildOperateListWidget(videoInfo: videoInfo, index: index), backgroundColor: Colors.white, shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadiusDirectional.only(
                                    topStart: Radius.circular(10), topEnd: Radius.circular(10))));*/
          showModalBottomSheet(
              // isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(10),
                      topEnd: Radius.circular(10))),
              context: context,
              builder: (BuildContext context) {
                return _buildOperateListWidget(
                    videoInfo: videoInfo, index: index);
              });
        },
        icon: const Icon(Icons.more_vert_rounded));
  }

  /// 视频操作弹窗
  Widget _buildOperateListWidget(
      {required VideoFileDirModel videoInfo, required int index}) {
    // name 重命名 字幕 弹幕 添加到播放列表 删除
    final ButtonStyle buttonStyle = ButtonStyle(
        alignment: Alignment.centerLeft,
        foregroundColor: MaterialStateProperty.all(Colors.black87));
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 16, top: 6, right: 16, bottom: 0),
              child: Text(
                videoInfo.getFullName,
                textAlign: TextAlign.left,
              ),
            ),
            ListView(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              shrinkWrap: true,
              children: <Widget>[
                TextButton.icon(
                  style: buttonStyle,
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text("重命名"),
                  onPressed: () async {
                    String oldName = videoInfo.getFullName;
                    Navigator.of(context).pop(); //关闭对话框
                    //定义一个controller
                    TextEditingController nameController =
                        TextEditingController.fromValue(TextEditingValue(
                      text: oldName,

                      /// 设置光标在最后
                      /*selection: TextSelection.fromPosition(TextPosition(
                              affinity: TextAffinity.downstream,
                              offset: oldName.length)),*/
                    ));

                    bool? flag = await AlertDialogUtils.modalConfirmAlertDialog(
                      buildContext: context,
                      title: "重命名",
                      content: TextField(
                        controller: nameController, //设置cont
                        inputFormatters: [
                          //FilteringTextInputFormatter.deny(RegExp(r"^[a-zA-Z]:[\\]((?! )(?![^\\/]*\s+[\\/])[w -]+[\\/])*(?! )(?![^.]*\s+\.)[w -]+$")),
                        ], // roller
                      ),
                      cancelText: "取消",
                      confirmText: "确定",
                    );
                    if (flag == null) {
                      print("取消，${nameController.text}");
                    } else {
                      var newName = nameController.text;
                      print("确认变更，${nameController.text}");
                      if (newName != oldName) {
                        File file = videoInfo.file;
                        File renameSync = file.renameSync(
                            "${videoInfo.dir}${Platform.pathSeparator}$newName");
                        print(
                            "重命名成功,$renameSync,${renameSync.path},${FileSystemEntity.isFileSync(renameSync.path)}");
                        setState(() {
                          _videoFileList.fillRange(index, index + 1,
                              VideoFileDirModel(path: renameSync.path));
                          _videoFileList
                              .sort((VideoFileDirModel a, VideoFileDirModel b) {
                            return a.getFullName
                                .toLowerCase()
                                .compareTo(b.getFullName.toLowerCase());
                          });
                        });
                      }
                    }
                  },
                ),
                TextButton.icon(
                  style: buttonStyle,
                  icon: const Icon(Icons.subtitles_rounded),
                  label: const Text("搜索字幕"),
                  onPressed: () {},
                ),
                TextButton.icon(
                  style: buttonStyle,
                  icon: const Icon(Icons.subject_rounded),
                  label: const Text("绑定弹幕"),
                  onPressed: () {
                    Get.to(BindingDanmaku(videoInfo: videoInfo,));
                  },
                ),
                TextButton.icon(
                  style: buttonStyle,
                  icon: const Icon(Icons.playlist_play_rounded),
                  label: const Text("添加到播放列表"),
                  onPressed: () async {
                    Navigator.of(context).pop(); //关闭对话框
                    // bool? flag = await showDeleteConfirmDialog2();
                    Get.bottomSheet(_buildAddToPlayList(),
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadiusDirectional.only(
                                topStart: Radius.circular(10),
                                topEnd: Radius.circular(10))));
                    print("after");
                  },
                ),
                TextButton.icon(
                  style: buttonStyle,
                  icon: const Icon(Icons.delete_rounded),
                  label: const Text("删除"),
                  onPressed: () async {
                    Navigator.of(context).pop(); //关闭对话框
                    print("删除ddd内容");
                    bool? flag = await AlertDialogUtils.modalConfirmAlertDialog(
                      title: "下列文件会被永久删除",
                      buildContext: context,
                      content: Text(
                        videoInfo.getFullName,
                        textAlign: TextAlign.left,
                      ),
                      cancelText: "取消",
                      confirmText: "删除",
                    );
                    if (flag == null) {
                      print("取消");
                    } else {
                      print("确认删除");
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// 添加视频到播放列表
  _buildAddToPlayList() {
    List<VideoFileDirModel> videoPlayDirList = <VideoFileDirModel>[];
    TextStyle defaultTextStyle = DefaultTextStyle.of(context).style;
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text(
              "将视频添加至播放列表",
              textAlign: TextAlign.left,
            ),
          ),
          OutlinedButton(
              onPressed: () {
                Get.back();
                Get.bottomSheet(_buildNewPlayList(),
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadiusDirectional.only(
                            topStart: Radius.circular(10),
                            topEnd: Radius.circular(10))));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add),
                  Text("创建新播放列表"),
                ],
              )),
          Expanded(
            child: videoPlayDirList.isEmpty
                ? const Center(child: Text("没有播放列表"))
                : FileDirectoryUtils.buildDirList(dirList: videoPlayDirList),
          )
        ],
      ),
    );
  }

  /// 创建新的播放列表
  Widget _buildNewPlayList() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.playlist_play_rounded),
                Text("创建新的播放列表")
              ],
            ),
            Row(
              children: [
                const Expanded(child: TextField()),
                ElevatedButton(onPressed: (){
                  print("");
                }, child: const Text("创建"))
              ],
            ),
          ],
        ),
      ),
    );
  }



}
