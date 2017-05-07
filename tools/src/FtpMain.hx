#if nodejs
import pony.fs.Dir;
import pony.fs.File;
import sys.FileSystem;
import haxe.xml.Fast;
import js.Node;

/**
 * FtpMain
 * @author AxGord <axgord@gmail.com>
 */
class FtpMain {

	static var FTP = Node.require("ftp");
		
	static var path:String = '';
	static var debug:Bool = false;
	static var app:String;
	static var input:Array<String> = [];
	static var output:String = '/';
	static var user:String = 'anonymous';
	static var pass:String = 'anonymous@';
	static var host:String = 'localhost';
	static var port:Int = 21;
	
	static var ftp:Dynamic;
	
	static var inputIterator:Iterator<String>;
	static var fileIterator:Iterator<File>;
	
	static function main() {
		var xml = Utils.getXml().node.ftp;

		
		var cfg = Utils.parseArgs(Sys.args());
		
		app = cfg.app;
		debug = cfg.debug;
		if (xml.has.path)
			path = xml.att.path;
		run(xml);
		
		ftp = Type.createInstance(FTP, []);
		ftp.on('ready', readyHandler);
		ftp.on('error', function(e) trace(e));
		ftp.connect({
			host: host,
			port: port,
			user: user,
			password: pass
		});
	}
	
	static function readyHandler():Void {
		Sys.println('Cwd: ' + output);
		ftp.binary(function() ftp.cwd(output, cwdHandler));
	}
	
	static function cwdHandler(e:Dynamic):Void {
		if (e != null) throw e;
		Sys.println('Delete old files');
		inputIterator = input.iterator();
		deleteNext();
		
		/*
		ftp.list(function(e:Dynamic, a:Array<Dynamic>) {
			trace(a);
		});
		*/
	}
	
	static function deleteNext():Void {
		if (inputIterator.hasNext()) {		
			var unit = inputIterator.next();
			if (FileSystem.isDirectory(path + unit)) {
				ftp.rmdir(unit, true, pauseDeleteNext);
			} else {
				ftp.delete(unit, deleteNext);
			}
		} else {
			Sys.println('Finish delete');
			Sys.println('Upload new files');
			inputIterator = input.iterator();
			uploadNext();
		}
	}
	
	static function pauseDeleteNext():Void {
		Node.setTimeout(deleteNext, 2000);
	}
	
	static function uploadNext():Void {
		if (inputIterator.hasNext()) {
			var unit = inputIterator.next();
			if (FileSystem.isDirectory(path + unit)) {
				fileIterator = new Dir(path + unit).contentRecursiveFiles().iterator();
				uploadNextFile();
			} else {
				trace('Upload file: '+unit);
				ftp.put(path + unit, unit, false, uploadNext);
			}
		} else {
			Sys.println('Finish upload');
			ftp.end();
		}
	}
	
	static function uploadNextFile():Void {
		if (fileIterator.hasNext()) {
			var fullunit:String = fileIterator.next();
			var unit = fullunit.substr(path.length);
			var a = unit.split('/');
			var na = [];
			for (e in a) if (e != '') na.push(e);
			
			var dir = [for (i in 0...na.length - 1) na[i]].join('/'); 
			var _ftp = ftp;
			var file = na.join('/');
			Sys.println('Makedir: ' + dir);
			ftp.mkdir(dir, true, function() {
				Sys.println('Upload file: ' + file);
				_ftp.put(path + file, file, false, uploadNextFile);
			});
		} else {
			uploadNext();
		}
	}
	
	static function run(xml:Fast) {
		for (e in xml.elements) {
			switch e.name {
				case 'user': user = e.innerData;
				case 'pass': pass = e.innerData;
				case 'host': 
					var a = e.innerData.split(':');
					host = a[0];
					if (a.length > 1)
						port = Std.parseInt(a[1]);
				case 'output':
					output = e.innerData;
				case 'input':
					input.push(e.innerData);
				case 'debug': if (debug) run(e);
				case 'release': if (!debug) run(e);
				case 'apps': if (app != null && e.hasNode.resolve(app)) {
					run(e.node.resolve(app));
				}
			}
		}
	}
	
}
#end