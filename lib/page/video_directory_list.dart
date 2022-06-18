import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jin_video/page/video_file_list.dart';

import '../model/video_file_dir_model.dart';
import '../utils/file_directory_utils.dart';
import '../utils/media_store_utils.dart';
import '../utils/my_icons_utils.dart';

class VideoDirectoryList extends StatefulWidget {
  const VideoDirectoryList({Key? key, this.dir}) : super(key: key);
  final String? dir;

  @override
  State<VideoDirectoryList> createState() => _VideoDirectoryListState();
}

class _VideoDirectoryListState extends State<VideoDirectoryList> {
  List<VideoFileDirModel> _dirList = <VideoFileDirModel>[];
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    getVideoDirectoryList();
  }
  /// 扫描获取有视频的目录
  getVideoDirectoryList() async {
    print("getVideoDirectoryList entry，${widget.dir}");
    List<VideoFileDirModel> list = [];
    List<VideoFileDirModel> mediaStoreVideoList =
        await MediaStoreUtils.getMediaStoreVideoDirList();
    if (mediaStoreVideoList.isNotEmpty) {
      list.addAll(mediaStoreVideoList);
    }
    if (widget.dir != null) {
      print("getVideoDirectoryList get file dir");
      List<VideoFileDirModel> fileList =
          await FileDirectoryUtils.getNotEmptyDirListByPathAndFormatSync(
              path: widget.dir!, recursive: true, fileFormat: FileFormat.video);
      print("getVideoDirectoryList list: $fileList");
      if (fileList.isNotEmpty) {
        list.addAll(fileList);
      }
    }
    list.sort((VideoFileDirModel a, VideoFileDirModel b) {
      return a.getFullName.toLowerCase().compareTo(b.getFullName.toLowerCase());
    });
    print("getVideoDirectoryList end: $list");
    setState(() {
      _dirList = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("dir list build");
    return Scaffold(
      appBar: AppBar(
        title: const Text("本地视频列表"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: () {
              if (_loading) {
                print("正在搜索中，请稍等");
              }
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _dirList.isEmpty
          ? const Center(
              child: Text("没有视频"),
            )
          : _buildDirList(),
    );
  }

  _buildDirList() {
    return Scrollbar(
        child: ListView.builder(
            itemExtent: 66,
            itemCount: _dirList.length,
            itemBuilder: (context, index) {
              VideoFileDirModel dirInfo = _dirList[index];
              String path = dirInfo.path;
              return InkWell(
                onTap: () {
                  print("directory path: $path");
                  Get.to(VideoFileList(dir: path));
                },
                child: ListTile(
                  horizontalTitleGap: 0,
                  leading: const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(
                      MyIconsUtils.folderFullBackground,
                      size: 60,
                      color: Colors.black26,
                    ),
                  ),
                  title: Text(
                    dirInfo.getFullName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    "${dirInfo.itemsNumber}个视频",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            }));
  }
}
