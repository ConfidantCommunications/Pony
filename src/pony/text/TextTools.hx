package pony.text;

import pony.math.MathTools;
import pony.SPair;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.Serializer;
#end

@:enum abstract AnsiForeground(UInt) to UInt {
	var Default = 39;
	var Black = 30;
	var Red = 31;
	var Green = 32;
	var Yellow = 33;
	var Blue = 34;
	var Magenta = 35;
	var Cyan = 36;
	var LightGray = 37;
	var DarkGray = 90;
	var LightRed = 91;
	var LightGreen = 92;
	var LightYellow = 93;
	var LightBlue = 94;
	var LightMagenta = 95;
	var LightCyan = 96;
	var White = 97;
}

/**
 * TextTools
 * @author AxGord <axgord@gmail.com>
 */
class TextTools {
	
	public static inline var MODULE:String = 'pony.Tools';
	public static var letters:Map<String, String> = ['ru' => 'АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ'];
	private static inline var firstANSIId:Int = 192;
	
	public static function convertToANSI(s:String, lang:String):String {
		lang = lang.split('_')[0];
		if (!letters.exists(lang)) return s;
		var r = '';
		for (i in 0...s.length) r += getANSILetter(s.charAt(i), lang);
		return r;
	}
	
	private static function getANSILetter(s:String, lang:String):String {
		var l = letters[lang];
		for (i in 0...l.length) if (l.charAt(i) == s)
			return String.fromCharCode(i + firstANSIId);
		l = l.toLowerCase();
		for (i in 0...l.length) if (l.charAt(i) == s)
			return String.fromCharCode(l.length + i + firstANSIId);
		return s;
	}
	
	public static function checkLang(s:String, lang:String):Bool {
		var l = letters[lang];
		for (i in 0...s.length) if (l.indexOf(s.charAt(i).toUpperCase()) != -1) return true;
		return false;
	}
	
	public inline static function exists(s:String, ch:String):Bool return s.indexOf(ch) != -1;
	
	public static function repeat(s:String, count:Int):String {
		var r:String = '';
		while (count-->0) r += s;
		return r;
	}
	
	inline public static function isTrue(s:String):Bool return return s != null && StringTools.trim(s.toLowerCase()) == 'true';
	inline public static function isFalse(s:String):Bool return return s != null && StringTools.trim(s.toLowerCase()) != 'true';
	
	public static function explode(s:String, delimiters:Array<String>):Array<String> {
		var r:Array<String> = [s];
		for (d in delimiters) {
			var sr:Array<String> = [];
			for ( e in r ) for ( se in e.split(d) ) if (se != '') sr.push(se);
			r = sr;
		}
		return r;
	}

	macro public static function includeFile(file:String):Expr {
		Context.registerModuleDependency(MODULE, file);
		var s:String = sys.io.File.getContent(file);
		return macro $v{s};
	}
	
	macro public static function includePath(path:String = '.'):Expr {
		var s:String = sys.FileSystem.absolutePath(path + '/');
		return macro $v{s};
	}

	macro public static function includeFileFromCurrentDir(file:String):Expr {
		var f:String = Context.getPosInfos(Context.currentPos()).file;
		var i = MathTools.cmax(f.lastIndexOf('\\'), f.lastIndexOf('/'));
		f = i != -1 ? f.substr(0, i) + '/' : '';
		Context.registerModuleDependency(MODULE, f + file);
		var s:String = sys.io.File.getContent(f + file);
		return macro $v{s};
	}
	
	macro public static function includePathFromCurrentDir(path:String = '.'):Expr {
		var f:String = Context.getPosInfos(Context.currentPos()).file;
		var i = MathTools.cmax(f.lastIndexOf('\\'), f.lastIndexOf('/'));
		f = i != -1 ? f.substr(0, i) + '/' : '';
		var s:String = sys.FileSystem.absolutePath(f + path + '/');
		return macro $v{s};
	}

	macro public static function includeJson(file:String):Expr {
		Context.registerModuleDependency(MODULE, file);
		var s:String = sys.io.File.getContent(file);
		haxe.Json.parse(s); //check
		return macro haxe.Json.parse($v{s}); //todo: not parse on runtime
	}
	
	macro public static function includeJsonFromCurrentDir(file:String):Expr {
		var f:String = Context.getPosInfos(Context.currentPos()).file;
		var i = MathTools.cmax(f.lastIndexOf('\\'), f.lastIndexOf('/'));
		f = i != -1 ? f.substr(0, i) + '/' : '';
		Context.registerModuleDependency(MODULE, f + file);
		var s:String = sys.io.File.getContent(f + file);
		haxe.Json.parse(s); //check
		return macro haxe.Json.parse($v{s}); //todo: not parse on runtime
	}
	
	public static inline function parsePercent(s:String):Float {
		if (s.indexOf('%') != -1) {
			return Std.parseFloat(s.substr(0, s.length - 1)) / 100;
		} else
			return Std.parseFloat(s);
	}
	
	public static inline function last(s:String):String return s.charAt(s.length - 1);
	
	public static function bigFirst(s:String):String return s.charAt(0).toUpperCase() + s.substr(1);
	
	public static function smallFirst(s:String):String return s.charAt(0).toLowerCase() + s.substr(1);
	
	public static function lines(s:String):Array<String> { 
 		var a:Array<String> = s.split('\r\n'); 
 		if (a.length == 1) { 
 			a = s.split('\r'); 
 			if (a.length == 1) 
 				a = s.split('\n'); 
 		} 
 		return a; 
 	}
	
	public static function tabParser(s:String, ?tab:String):Dynamic {
		var a = s.split('\n');
		//trace('Lines '+a.length);
		var name = StringTools.trim(a.shift());
		if (a.length == 0) return StringTools.trim(name);
		var section:Map<String, Dynamic> = new Map<String, Dynamic>();
		var entry = [];
		var arr = [];
		for (e in a) {
			if (tab == null) tab = detectTab(e);
			if (e.substr(0, tab.length) == tab) {
				entry.push(removeTab(e, tab));
			} else {
				var data:Dynamic = null;
				if (entry.length == 0) {
					data = StringTools.trim(e);
					arr.push(name);
				} else {
					data = tabParser(entry.join('\n'), tab);
					section[name] = data;
					entry = [];
				}
				name = StringTools.trim(e);
			}
		}
		
		if (arr.length > 0) {
			arr.push(name);
			return arr;
		}
		
		if (entry.length > 0) {
			var data = tabParser(entry.join('\n'), tab);
			section[name] = data;
		}
		return section;
	}

	public static function removeTab(s:String, ?tab:String):String {
		if (tab == null) tab = detectTab(s);
		return s.substr(tab.length);
	}
	
	private static function detectTab(s:String):String {
		for (t in ['    ', '		', '	', '  ', ' '])
			if (s.substr(0, t.length) == t)
				return t;
		return null;
	}
	
	public static function removeQuotes(s:String):String {
		var f = s.charAt(0);
		return (f == '"' || f == "'") ? s.substring(1, s.length - 1) : s;
	}

	public static function betweenReplace(text:String, begin:String, end:String, value:String):String {
		var beginIndex = text.indexOf(begin);
		if (beginIndex == -1) return null;
		beginIndex += begin.length;
		var beginData = text.substr(0, beginIndex);
		var endData = text.substr(beginIndex);
		endData = endData.substr(endData.indexOf(end));
		return beginData + value + endData;
	}

	#if (neko || nodejs || php)
	public static function betweenReplaceFile(file:String, begin:String, end:String, value:String):Void {
		if (sys.FileSystem.exists(file)) {
			var text = betweenReplace(sys.io.File.getContent(file), begin, end, value);
			if (text != null) sys.io.File.saveContent(file, text);
		}
	}
	#end
	
	public static function textLineLimit(text:String, len:Int):String {
		if (text.length <= len) {
			return text;
		} else {
			var l:Int = len;
			while (len > 0) {
				if (text.charAt(l) == ' ') {
					return text.substr(0, l) + '\n' + text.substr(l + 1);
				}
				l--;
			}
			return text.substr(0, len) + '\n' + text.substr(len);
		}
	}

	public static function ext(s:String):SPair<String> {
		var i:Int = s.lastIndexOf('.');
		return i == -1 ? new SPair(s, null) : new SPair(s.substr(0, i), s.substr(i + 1));
	}

	public static function addToStringsEnd(s:Array<String>, v:String):Array<String> return [for (e in s) e + v];
	public static function addToStringsBegin(s:Array<String>, v:String):Array<String> return [for (e in s) v + e];

	public static inline function quote(s:String, q:String='"'):String return q + s + q;
	public static inline function singleQuote(s:String):String return quote(s, "'");

	public static inline function replaceInQuote(s:String, sub:String, by:String, q:String = '"'):String {
		return StringTools.replace(s, quote(sub, q), quote(by, q));
	}

	public static inline function replaceInSingleQuote(s:String, sub:String, by:String):String {
		return StringTools.replace(s, singleQuote(sub), singleQuote(by));
	}

	public static inline function charCount(s:String, char:String):Int {
		return charCodeCount(s, StringTools.fastCodeAt(char, 0));
	}

	public static function charCodeCount(s:String, char:Int):Int {
		var n:Int = 0;
		for (i in 0...s.length) if (s.charCodeAt(i) == char) n++;
		return n;
	}

	public static inline function ansiForeground(s:String, c:AnsiForeground):String return '\x1b[${c}m$s\x1b[${AnsiForeground.Default}m';
	public static inline function ansiUnderlined(s:String):String return '\x1b[4m$s\x1b[24m';

	public static function replaceXmlAttr(src:String, attr:String, newval:String):String {
		var i:Int = src.indexOf(attr);
		if (i == -1) return src;
		i += attr.length;
		var q1:String = '"';
		var q2:String = "'";
		var oq:Int = src.indexOf(q1, i);
		var oq2:Int = src.indexOf(q2, i);
		var q:String = null;
		if (oq2 != -1 && oq2 < oq) {
			oq = oq2;
			q = q2;
		} else {
			q = q1;
		}
		oq++;
		var cq:Int = src.indexOf(q, oq);
		return src.substring(0, oq) + newval + src.substring(cq);
	}

}