//移除js、css文件
var removejscssfile = function(filename, filetype) {
	var targetelement = (filetype == "js") ? "script" : (filetype == "css") ? "link" : "none";
	var targetattr = (filetype == "js") ? "src" : (filetype == "css") ? "href" : "none";
	var allsuspects = document.getElementsByTagName(targetelement);
	for (var i = allsuspects.length; i >= 0; i--) {
		if (allsuspects[i] && allsuspects[i].getAttribute(targetattr) !== null && allsuspects[i].getAttribute(targetattr).indexOf(filename) !== -1);
		allsuspects[i].parentNode.removeChild(allsuspects[i]);
	}
};

//创建js、css文件
var createjscssfile = function(filename, filetype) {
	var fileref;
	if (filetype === "js") {
		fileref = document.createElement('script');
		fileref.setAttribute("type", "text/javascript");
		fileref.setAttribute("src", filename);
	} else if (filetype === "css") {
		fileref = document.createElement("link");
		fileref.setAttribute("rel", "stylesheet");
		fileref.setAttribute("type", "text/css");
		fileref.setAttribute("href", filename);
	}
	return fileref;
};


//替换js、css文件
var replacejscssfile = function(oldfilename, newfilename, filetype) {
	var targetelement = (filetype === "js") ? "script" : (filetype === "css") ? "link" : "none";
	var targetattr = (filetype == "js") ? "src" : (filetype == "css") ? "href" : "none";
	var allsuspects = document.getElementsByTagName(targetelement);
	for (var i = allsuspects.length; i >= 0; i--) {
		if (allsuspects[i] && allsuspects[i].getAttribute(targetattr) !== null && allsuspects[i].getAttribute(targetattr).indexOf(oldfilename) !== -1) {
			var newelement = createjscssfile(newfilename, filetype);
			allsuspects[i].parentNode.replaceChild(newelement, allsuspects[i]);
		}
	}
};

//localStorage 操作
var Store = {
	saveObject: function(key, object) {
		window.localStorage[key] = JSON.stringify(object);
	},
	loadObject: function(key) {
		var objectString = window.localStorage[key];
		return objectString === undefined ? null : JSON.parse(objectString);
	},
	deleteObject: function(key) {
		window.localStorage[key] = null;
	},
	clear: function() {
		window.localStorage.clear();
	}
};

//下载文件
var downloadFile = function(sourceUrl, targetUrl, callback) {
	console.log("图片显示地址：" + sourceUrl);
	window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, gotFS, null);

	var fileName = sourceUrl;
	if (fileName.indexOf("?") > -1) {
		fileName = fileName.substring(0, fileName.indexOf("?"));
	}
	if (fileName.indexOf("file://") > -1) {
		var fileEntry = new Object;
		fileEntry.fullPath = sourceUrl;
		showPic(fileEntry);
		return;
	}

	fileName = fileName.substring(fileName.lastIndexOf("/") + 1, fileName.lenght);


	if (fileName.indexOf(".png") > -1) {
		console.log("替换之前：" + filename);
		fileName.replace(/.png/, ".img");
		console.log("替换之后：" + filename);
	}
	console.log("filename2 " + fileName);
	if (fileName == "" || fileName == undefined || fileName == null) {
		fileName = "img/default_icon2.png";
		var fileEntry = new Object;
		fileEntry.fullPath = fileName;
		showPic(fileEntry);
		return;
	}

	function gotFS(fileSystem) {
		fileSystem.root.getDirectory(targetUrl, {
			create: true,
			exclusive: false
		}, writerFile, function(e) {
			console.log("创建文件夹失败");
		});
	}

	function writerFile(newFile) {
		newFile.getFile(
			fileName,
			null,
			showPic,
			function() {
				newFile.getFile(
					fileName, {
						create: true,
						exclusive: false
					},
					gotFileEntry,
					function() {

					});
			});
	}

	function showPic(fileEntry) {
		//文件存在就直接显示  
		console.log("文件存在就直接显示" + fileEntry.fullPath + ">>>");
		callback(fileEntry);
	}

	function gotFileEntry(fileEntry) {
		console.log("进入gotFileEntry方法");
		var fileTransfer = new FileTransfer();
		var uri = encodeURI(sourceUrl);
		fileTransfer.download(
			uri, fileEntry.fullPath, function(entry) {
				callback(entry);
			}, function(error) {
				console.log("下载网络图片出现错误");
			});
	}
};

//把图片转换成base64，存放到localStorage
var getBase64Image = function(img) {
	try {
		if (!/^data:image/.test($(img).attr("src")) && window.localStorage[$(img).attr("src")] === undefined) {
			console.log("开始缓存");
			var pic_real_width, pic_real_height;
			var realimg = $("<img/>").attr("src", img.src).on("load", function() {
				pic_real_width = this.width;
				pic_real_height = this.height;
				var canvas = document.createElement('canvas');
				var ctx = canvas.getContext('2d');
				canvas.width = pic_real_width;
				canvas.height = pic_real_height;
				ctx.drawImage(this, 0, 0, pic_real_width, pic_real_height);
				var mark = $(img).attr("src");
				if (mark.indexOf("?") > -1) {
					mark = mark.substring(0, mark.indexOf("?"));
				}
				// var imgType = img.src.match(/\.(jpg|jpeg|png|gif)$/i);
				// console.info(imgType);
				// if (imgType && imgType.length) {
				// 	imgType = imgType[1].toLowerCase() == 'jpg' ? 'jpeg' : imgType[1].toLowerCase();
				// } else {
				// 	throw 'Invalid image type for canvas encoder: ' + img.src;
				// }
				window.localStorage[mark] = canvas.toDataURL();
				console.log("缓存完成");
			});
		}
	} catch (e) {
		console && console.log(e);
		return 'error';
	}
}

//获取字符串字节数
String.prototype.getBytesLength = function() {
	return this.replace(/[^\x00-\xff]/gi, "--").length;
};

function subStrByCnLen(str, len) {
	var cnlen = len * 2;

	var index = 0;
	var tempStr = "";

	for (i = 0; i < str.length; i++) {
		var s = str.charAt(i);
		if (index >= cnlen) {
			// return tempStr;
		} else {
			if (s.getBytesLength() > 1) {
				index += 2;
			} else {
				index += 1;
			}
			tempStr = tempStr + s;
		}
	}
	if (str.getBytesLength() > cnlen) {
		tempStr = tempStr + "..";
	}
	return tempStr;
};
