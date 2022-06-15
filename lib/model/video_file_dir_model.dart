
import 'dart:io';

class VideoFileDirModel {

  VideoFileDirModel({required this.path, this.fullName, this.name, this.itemsNumber, this.danmakuUrl, this.subtitleUrl});

  final String path;
  final String? fullName;
  final String? name;
  //如果是文件夹才有该属性，表示它包含的项目数
  final int? itemsNumber;
  final String? danmakuUrl;
  final String? subtitleUrl;

  File get file => File(path);

  bool get isExist => file.existsSync();

  bool get isFile => FileSystemEntity.isFileSync(path);

  String get dir => file.parent.path;

  FileStat get stat => file.statSync();

  String get getPath => path;
  String get getFullName => fullName ?? path.split(Platform.pathSeparator).last;
  String get getName => name ?? (getFullName.contains(".") ? getFullName.substring(0, getFullName.lastIndexOf(".")) : getFullName);

  //文件创建日期
  DateTime get createTime => stat.accessed;
  //文件修改日期
  DateTime get modTime => stat.modified;

  // 文件的大小，isFile为true才赋值该属性
  int get size => isFile ? stat.size : -1;

  @override
  String toString() {
    return 'VideoFileDirModel{path: $path, fullName: $fullName, name: $name, itemsNumber: $itemsNumber}';
  }
}