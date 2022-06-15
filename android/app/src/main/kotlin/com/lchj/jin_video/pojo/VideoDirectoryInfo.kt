package com.lchj.jin_video.pojo

class VideoDirectoryInfo {
    var path: String = "";
    var name: String = "";
    var itemsNumber: Int = 0;

    constructor(path: String, name: String, itemsNumber: Int) {
        this.path = path
        this.name = name
        this.itemsNumber = itemsNumber
    }

    override fun toString(): String {
        return "VideoDirectoryInfo(path='$path', name='$name', itemsNumber=$itemsNumber)"
    }

}