package com.lchj.jin_video.pojo

class VideoFileInfo {
    var id: Int = 0; // id
    var name: String? = null; // 名称（不含后缀）
    var fullName: String? = null; // 文件完整名称（带后缀）
    var type: String? = null; // 文件类型（mime_type）
    var suffix: String? = null; // 后缀
    var path: String? = null; // 文件路径
    var dir: String? = null; // 文件目录
    var createTime: Long = 0L; // 文件创建时间
    var modifiedTime: Long? = null; // 文件修改时间
    var size: Long = 0L; // 文件大小
    var duration: Long = 0L; // 时长

    constructor(id: Int, name: String?, fullName: String?, type: String?, suffix: String?, path: String?, dir: String?, createTime: Long, modifiedTime: Long?, size: Long, duration: Long) {
        this.id = id
        this.name = name
        this.fullName = fullName
        this.type = type
        this.suffix = suffix
        this.path = path
        this.dir = dir
        this.createTime = createTime
        this.modifiedTime = modifiedTime
        this.size = size
        this.duration = duration
    }

    override fun toString(): String {
        return "VideoFileInfo(id=$id, name=$name, fullName=$fullName, type=$type, suffix=$suffix, path=$path, dir=$dir, createTime=$createTime, modifiedTime=$modifiedTime, size=$size, duration=$duration)"
    }

}