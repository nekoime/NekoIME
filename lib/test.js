var ffi = require('ffi');
var fs = require('fs');

var trueCnt = 0, falseCnt = 0, totalCnt = 0;
var fileList = fs.readdirSync('C:/Windows/System32/');
var filename = '';


var RTLD_NOW = ffi.DynamicLibrary.FLAGS.RTLD_NOW;
var RTLD_GLOBAL = ffi.DynamicLibrary.FLAGS.RTLD_GLOBAL;
var mode = RTLD_NOW | RTLD_GLOBAL;

for (var i = 0; i < fileList.length; i++) {

    fileName = fileList[i];

    if (/.+\.dll/i.test(fileName)) {
        totalCnt++;
        try {
            //var conn = new ffi.Library(fileName);
            var conn = ffi.DynamicLibrary(fileName, RTLD_GLOBAL);
            trueCnt++;
        }
        catch (err) {
            falseCnt++;
            console.log('Not loaded: ' + fileName);
        }
    }
}

console.log("trueCnt: " + trueCnt + ", falseCnt: " + falseCnt + ", totalCnt: " + totalCnt);