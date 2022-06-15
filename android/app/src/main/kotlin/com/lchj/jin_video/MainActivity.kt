package com.lchj.jin_video

import android.content.ContentResolver
import android.os.Bundle
import com.lchj.jin_video.utils.MediaStoreUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private var _contentResolver: ContentResolver? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        _contentResolver = this.contentResolver
    }
    private val Method_Channel = "getMediaStoreListChannel"
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        //1.创建android端的MethodChannel
        val methodChannel = MethodChannel(flutterEngine.dartExecutor, Method_Channel)
        //2.通过setMethodCallHandler响应Flutter端的方法调用
        methodChannel.setMethodCallHandler { call, result ->
            //判断调用的方法名
            if(call.method.equals("getMediaStoreVideoDirList")){
                //获取传递的参数
                //Log.e("test", "Have received Test Method Call :${call.arguments}")
                //var list: List<VideoDirectoryInfo> = MediaStoreUtils.getVideoDirList(_contentResolver!!)
                var list: List<HashMap<String, Any>> = MediaStoreUtils.getMediaStoreVideoDirList(contentResolver!!)
                //Log.e("test", "Have received Test Method Call :$list")
                //返回结果给Flutter端
                result.success(list)
            }
        }
    }
}
