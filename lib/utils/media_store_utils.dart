
import 'dart:io';

import 'package:flutter/services.dart';

import '../model/video_file_dir_model.dart';

class MediaStoreUtils {
  //1.创建Flutter端的MethodChannel
  static const MethodChannel _methodChannel = MethodChannel('getMediaStoreListChannel');

  static Future<List<VideoFileDirModel>> getMediaStoreVideoDirList() async {
    List<VideoFileDirModel> videoDirList = [];
    //2.通过invokeMethod调用Native方法，拿到返回值
    var dirList = await _methodChannel.invokeMethod("getMediaStoreVideoDirList");
    if (dirList != null && dirList is List) {
      try {
        for (var element in dirList) {
          Map<String, dynamic> map = Map<String, dynamic>.from(element);
          if (!map.containsKey("path")) {
            continue;
          }
          String path = map.containsKey("path") ? map["path"] : "";
          String name = map.containsKey("name") ? map["name"] : "";
          int? itemsNumber = map.containsKey("itemsNumber") && map["itemsNumber"] is int ? map["itemsNumber"] : null;
          videoDirList.add(VideoFileDirModel(path: path, name: name, itemsNumber: itemsNumber));
        }
      } catch (e) {
        print("文件目录转换出错：$e");
      }
    }
    return videoDirList;
  }
}