import 'dart:io';

import 'package:flutter/material.dart';

import '../model/video_file_dir_model.dart';
import 'my_icons_utils.dart';

class FileDirectoryUtils {
  /// 根据父级路径获取目录下指定文件格式类型的所有非空目录
  /// [path] 父级目录
  /// [fileFormat] 文件格式
  /// [recursive] 递归获取
  static Future<List<VideoFileDirModel>> getNotEmptyDirListByPathAndFormatSync({required String path, bool recursive = false, FileFormat? fileFormat}) async {
    List<VideoFileDirModel> dirList = [];
    print("getNotEmptyDirListByPathAndFormatSync start, $path");
    /// 父级目录是否为空
    if (path.isNotEmpty) {
      Directory directory = Directory(path);
      if (directory.existsSync()) {
        FileStat statSync = directory.statSync();
        if (statSync.type == FileSystemEntityType.directory) {
          // 先获取当前目录（Directory直接是获取目录下，没有包含自己）
          List<VideoFileDirModel> fileList = getFileListByPathSync(path: path, fileFormat: fileFormat);
          print("getNotEmptyDirListByPathAndFormatSync type： fileList: $fileList");
          /// 目录下对的文件不为空的才放入list
          if (fileList.isNotEmpty) {
            dirList.add(VideoFileDirModel(path: path, itemsNumber: fileList.length));
          }

          Stream<FileSystemEntity> list = directory.list(recursive: recursive);
          await list.forEach((entity) async {
            FileSystemEntityType type = await FileSystemEntity.type(entity.path);
            print("getNotEmptyDirListByPathAndFormatSync type： $type");
            if (type == FileSystemEntityType.directory) {
              List<VideoFileDirModel> fileList = getFileListByPathSync(path: entity.path, fileFormat: fileFormat);
              print("getNotEmptyDirListByPathAndFormatSync type： fileList: $fileList");
              /// 目录下对的文件不为空的才放入list
              if (fileList.isNotEmpty) {
                dirList.add(VideoFileDirModel(path: entity.path, itemsNumber: fileList.length));
              }
            }
          });
          dirList.sort((VideoFileDirModel a, VideoFileDirModel b) {
            return a.getFullName.toLowerCase().compareTo(b.getFullName.toLowerCase());
          });
        }
      }
    }
    print("getNotEmptyDirListByPathAndFormatSync end dirList: $dirList");
    return dirList;
  }

  /// 获取指定目录下所有的文件
  static List<VideoFileDirModel> getFileListByPathSync({required String path, FileFormat? fileFormat}) {
    List<VideoFileDirModel> fileList = [];
    if (path.isNotEmpty) {
      Directory directory = Directory(path);
      if (directory.existsSync()) {
        List<FileSystemEntity> listSync = directory.listSync(recursive: false);
        for (FileSystemEntity entity in listSync) {
          FileSystemEntityType type = FileSystemEntity.typeSync(entity.path);
          if (type == FileSystemEntityType.file) {
            bool isAdd = false;
            /// 只获取指定格式
            if (fileFormat != null) {
              String format = entity.path.split(".").last;
              List<String> formatList = fileFormat.formatList;
              if (formatList.contains(format.toLowerCase())) {
                isAdd = true;
              } else {
                isAdd = false;
              }
            } else {
              isAdd = true;
            }
            if (isAdd) {
              fileList.add(VideoFileDirModel(path: entity.path));
            }
          }
        }
        fileList.sort((VideoFileDirModel a, VideoFileDirModel b) {
          return a.getFullName.toLowerCase().compareTo(b.getFullName.toLowerCase());
        });
      }
    }
    return fileList;
  }

  /// 获取指定目录下所有的文件 (仅一层)
  static Future<List<VideoFileDirModel>> getFileListByPath({required String path, FileFormat? fileFormat}) async {
    List<VideoFileDirModel> fileList = [];
    if (path.isNotEmpty) {
      Directory directory = Directory(path);
      if (directory.existsSync()) {
        Stream<FileSystemEntity> list = directory.list(recursive: false);
        await list.forEach((entity) async {
          FileSystemEntityType type = await FileSystemEntity.type(entity.path);
          if (type == FileSystemEntityType.file) {
            bool isAdd = false;
            /// 只获取指定格式
            if (fileFormat != null) {
              String format = entity.path.split(".").last;
              List<String> formatList = fileFormat.formatList;
              if (formatList.contains(format.toLowerCase())) {
                isAdd = true;
              } else {
                isAdd = false;
              }
            } else {
              isAdd = true;
            }
            if (isAdd) {
              fileList.add(VideoFileDirModel(path: entity.path));
            }
          }
        });
        fileList.sort((VideoFileDirModel a, VideoFileDirModel b) {
          return a.getFullName.toLowerCase().compareTo(b.getFullName.toLowerCase());
        });
      }
    }
    return fileList;
  }

  /// 创建目录列表
  static Widget buildDirList({required List<VideoFileDirModel> dirList, Function? onTap}) {
    return Scrollbar(
        child: ListView.builder(
            itemExtent: 66,
            itemCount: dirList.length,
            itemBuilder: (context, index) {
              VideoFileDirModel dirInfo = dirList[index];
              String path = dirInfo.path;
              return InkWell(
                onTap: () {
                  print("directory path: $path");
                  if (onTap != null) {
                    onTap();
                  }
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
//微软视频 ：wmv、asf、asx
//
//　　Real Player ：rm、 rmvb
//
//　　MPEG视频 ：mpg、mpeg、mpe
//
//　　手机视频 ：3gp
//
//　　Apple视频 ：mov
//
//　　Sony视频 ：mp4、m4v
//
//　　其他常见视频：avi、dat、mkv、flv、vob、f4v
enum FileFormat {
  video("视频文件", ["wmv", "asf", "asx", "rm", "rmvb", "mpg", "mpeg", "mpe", "3gp", "mov", "mp4", "m4v", "avi", "dat", "mkv", "flv", "vob", "f4v"]);
  final String name;
  final List<String> formatList;
  const FileFormat(this.name, this.formatList);
}



