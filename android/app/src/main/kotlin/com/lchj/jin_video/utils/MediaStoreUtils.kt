package com.lchj.jin_video.utils

import android.content.ContentResolver
import android.database.Cursor
import android.provider.MediaStore
import com.lchj.jin_video.pojo.VideoDirectoryInfo
import com.lchj.jin_video.pojo.VideoFileInfo
import io.flutter.Log
import java.io.File

object MediaStoreUtils {

    /**
     * 获取视频文件列表
     */
    fun getVideoList(contentResolver : ContentResolver) : List<VideoFileInfo> {
        var list : List<VideoFileInfo> = ArrayList<VideoFileInfo>();
        var cursor : Cursor? = contentResolver.query(
            MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
            null, null,null, MediaStore.Video.Media.DEFAULT_SORT_ORDER);
        if (cursor != null) {
            while (cursor!!.moveToNext()) {
                var path: String = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATA))
                var id: Int = cursor.getInt(cursor.getColumnIndexOrThrow(MediaStore.Video.Media._ID));
                var mimType: String = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.MIME_TYPE));
                var name: String = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.TITLE));
                var fullName: String = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DISPLAY_NAME));
                var dir: String = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.BUCKET_DISPLAY_NAME));
                var createTime: Long = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATE_ADDED));
                var modifiedTime: Long = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATE_MODIFIED));
                var size: Long = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.SIZE));
                var duration: Long = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DURATION));
                var suffix: String = fullName.split(".").last();
                var videoFileIndo: VideoFileInfo = VideoFileInfo(id, name, fullName, mimType, suffix, path, dir, createTime, modifiedTime, size, duration);
                list.plus(videoFileIndo);
            }
            cursor.close()
        }
        return list;
    }
    /**
     * 获取视频文件目录集合
     */
    fun getMediaStoreVideoDirList(contentResolver : ContentResolver) : List<HashMap<String, Any>> {
        var list: List<HashMap<String, Any>> = mutableListOf();
        var dirMap: LinkedHashMap<String, HashMap<String, Any>> = linkedMapOf()
        if (contentResolver != null) {
            // 获取视频
            var cursor : Cursor? = contentResolver.query(MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                null, null,null, MediaStore.Video.Media.DEFAULT_SORT_ORDER);
            if (cursor != null) {
                while (cursor.moveToNext()) {
                    // 获取路径
                    var path: String = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATA))
                    // 获取父级目录
                    var parentFile: File = File(path).parentFile
                    // 父级目录是否存在
                    if (parentFile.exists()) {
                        // 父级目录绝对路径
                        val absolutePath: String = parentFile.absolutePath
                        var map: HashMap<String, Any> = if (dirMap[absolutePath] == null)  hashMapOf() else dirMap[absolutePath]!!;
                        if (map == null) {
                            map = hashMapOf();
                        }
                        var itemsNumber: Int = 0
                        if (map.containsKey("itemsNumber")) {
                            try {
                                //Log.e("getMediaStoreVideoDirList", "map[itemsNumber]：${map["itemsNumber"]}")
                                itemsNumber += map["itemsNumber"] as Int
                            } catch (e: Exception){
                                Log.e("getMediaStoreVideoDirList", "get itemsNumber error：$e")
                            }
                        }
                        ++itemsNumber
                        map["path"] = absolutePath
                        map["name"] = absolutePath.split(File.separator).last()
                        map["itemsNumber"] = itemsNumber
                        dirMap[absolutePath] = map
                    }
                }
                list = ArrayList(dirMap.values);
            }
        }
        return list;
    }

    /**
     * 获取视频文件目录集合
     */
    fun getVideoDirList(contentResolver : ContentResolver) : List<VideoDirectoryInfo> {
        var list: MutableList<VideoDirectoryInfo> = mutableListOf<VideoDirectoryInfo>();
        var dirMap: HashMap<String, Int> = hashMapOf();
        var cursor : Cursor? = contentResolver.query(MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
            null, null,null, MediaStore.Video.Media.DEFAULT_SORT_ORDER);
        Log.e("getVideoDirList", "entry getVideoDirList :$contentResolver, $cursor")
        if (cursor != null) {
            while (cursor.moveToNext()) {
                var path: String = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATA))
                Log.e("getVideoDirList", "while path :$path")
                var parentFile: File = File(path).parentFile;
                Log.e("getVideoDirList", "while parentFile :$parentFile")
                if (parentFile.exists()) {
                    Log.e("getVideoDirList", "while parentFile.exists")
                    val absolutePath: String = parentFile.absolutePath;
                    var index: Int? = dirMap[absolutePath];
                    var dirInfo: VideoDirectoryInfo;
                    dirInfo = VideoDirectoryInfo(absolutePath, absolutePath.split("/").last(), 1)
                    list.add(dirInfo);
//                    list.plus(dirInfo)
                    Log.e("getVideoDirList", "while dirInfo :$dirInfo")
                    /*if (index == null || list.size < index + 1) {
                        dirInfo = VideoDirectoryInfo(absolutePath, absolutePath.split("/").last(), 1)
                        list.plus(dirInfo)
                        dirMap[absolutePath] = list.size - 1
                    } else {
                        list[index!!].itemsNumber += 1
                    }*/
                }
            }
            cursor.close()
        }
        Log.e("getVideoDirList", "list :$list")
        return list;
    }
}