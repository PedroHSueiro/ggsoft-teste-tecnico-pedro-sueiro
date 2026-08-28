package utils;

import spine.support.files.FileHandle;

// Classe de implementação do FileHandle
class StringFileHandle implements FileHandle {
    public var path:String;
    private var content:String;

    public function new(path:String, content:String) {
        this.path = path;
        this.content = content;
    }

    public function getPath():String {
        return path;
    }

    public function getContent():String {
        return content;
    }
}