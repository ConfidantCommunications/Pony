package pony;

import haxe.Constraints.Function;
import js.Browser;
import js.html.CanvasElement;
import js.html.DOMElement;

enum UserAgent {
	IE; Edge; Chrome; Safari; Firefox; Samsung; Unknown;
}

enum OS {
	Windows; Linux(type:Linux); Android; Unknown; IOS;
}

enum Linux {
	Ubuntu; Other;
}

enum ISA {
	X32; X64; Unknown;
}

typedef JsMap<K, V> = {
	set: K -> V -> Void,
	get: K -> V,
	keys: Void -> Array<K>
}

/**
 * JsTools
 * @author AxGord <axgord@gmail.com>
 */
class JsTools implements pony.magic.HasSignal {

	public static var agent(get, never):UserAgent;
	public static var os(get, never):OS;
	public static var isa(get, never):ISA;
	
	public static var isMobile(get, never):Bool;
	public static var isFSE(get, never):Bool;
	public static var webp(get, never):Bool;
	
	/**
	 *  https://github.com/jfriend00/docReady
	 */
	@:lazy public static var onDocReady:pony.events.Signal0;

	private static var _agent:UserAgent;
	private static var _os:OS;
	private static var _isa:ISA;
	private static var _webp:Null<Bool>;
	
	private static var logFunction:Function;
	
	private static function __init__():Void {
		onDocReady.clear();
		eDocReady.onTake < regDocReady;
	}

	private static function regDocReady():Void {
		js.Lib.global.docReady(eDocReady.dispatch);
	}

	@:extern public static inline function removeEval():Void {
		untyped window.eval = evalHandler;
	}

	private static function evalHandler():Void {
		throw new js.Error('Sorry, this app does not support window.eval().');
	}

	@:extern public static inline function disableDrop():Void {
		js.Browser.document.ondragover = abortEvent;
		js.Browser.document.ondrop = abortEvent;
	}

	public static function abortEvent(e:js.html.Event):Void e.preventDefault();

	public static function get_webp():Bool {
		return _webp != null ? _webp : _webp =
		cast(Browser.document.createElement('canvas'), CanvasElement).toDataURL('image/webp').indexOf('data:image/webp') == 0;
	}

	private static function get_agent():UserAgent {
		if (_agent != null) return _agent;
		var ua = Browser.navigator.userAgent.toLowerCase();
		if (ua.indexOf('msie') != -1
		|| ua.indexOf('trident/') > 0) {
			_agent = IE;
		} else if (ua.indexOf('edge') != -1) {
			_agent = Edge;
		} else if (ua.indexOf('samsung') != -1) {
			_agent = Samsung;
		} else if (ua.indexOf('chrome') != -1) {
			_agent = Chrome;
		} else if (ua.indexOf('safari') != -1 && ua.indexOf('android') == -1) {
			_agent = Safari;
		} else if (ua.indexOf('firefox') != -1) {
			_agent = Firefox;
		} else {
			_agent = UserAgent.Unknown;
		}
		return _agent;
	}
	
	private static function get_os():OS {
		if (_os != null) return _os;
		var ua = Browser.navigator.userAgent.toLowerCase();
		if (ua.indexOf('windows') != -1) {
			_os = Windows;
		} else if (ua.indexOf('android') != -1) {
			_os = Android;
		} else if (ua.indexOf('linux') != -1) {
			if (ua.indexOf('ubuntu') != -1)
				_os = Linux(Ubuntu);
			else
				_os = Linux(Other);
		} else {
			var iDevices = [
				'iPad Simulator',
				'iPhone Simulator',
				'iPod Simulator',
				'iPad',
				'iPhone',
				'iPod'
			];
			if (Browser.navigator.platform != null)
				while (iDevices.length > 0)
					if (Browser.navigator.platform == iDevices.pop())
						return _os = OS.IOS;
			_os = OS.Unknown;
		}
		return _os;
	}
	
	private static function get_isa():ISA {
		if (_isa != null) return _isa;
		var ua = Browser.navigator.userAgent.toLowerCase();
		if (ua.indexOf('x86_32') != -1 || ua.indexOf('x32') != -1) {
			_isa = X32;
		} else if (ua.indexOf('x86_64') != -1 || ua.indexOf('x64') != -1) {
			_isa = X64;
		} else {
			_isa = ISA.Unknown;
		}
		return _isa;
	}
	
	@:extern inline private static function get_isMobile():Bool {
		#if simmobile
		return true;
		#else
		return untyped Browser.window.orientation != null;
		#end
	}
	
	@:extern inline public static function remove(el:DOMElement):Void {
		agent == IE ? el.parentNode.removeChild(el) : el.remove();
	}
	
	@:extern inline public static function get_isFSE():Bool {
		return untyped 
		{
			Browser.document.fullscreenElement ||
			Browser.document.mozFullScreen ||
			Browser.document.mozFullscreenElement ||
			Browser.document.webkitFullscreenElement ||
			Browser.document.msFullscreenElement;
		};
	}
	
	public static function closeFS():Void {
		untyped {
			if (document.cancelFullScreen)
				document.cancelFullScreen();
			else if (document.mozCancelFullScreen)
				document.mozCancelFullScreen();
			else if (document.webkitCancelFullScreen)
				document.webkitCancelFullScreen();
			else if (document.msCancelFullScreen)
				document.msCancelFullScreen();
		}
	}
	
	public static function fse(e:DOMElement):Void {
		untyped {
			if (e.requestFullscreen)
				e.requestFullscreen();
			else if (e.mozRequestFullScreen)
				e.mozRequestFullScreen();
			else if (e.webkitRequestFullscreen)
				e.webkitRequestFullscreen();
			else if (e.msRequestFullscreen)
				e.msRequestFullscreen();
		}
	}
	
	public static function disableLog():Void {
		logFunction = Browser.console.log;
		untyped Browser.console.log = Tools.nullFunction0;
	}
	
	public static function enableLog():Void {
		untyped Browser.console.log = logFunction;
	}

	public static function disableContextMenuGlobal():Void {
		js.Browser.window.oncontextmenu = contextMenuHandler;
	}

	private static function contextMenuHandler(event:js.html.Event):Bool {
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	
	public static function normalizeCss(s:String):String {
		var n = Browser.document.createDivElement();
		n.style.cssText = s;
		return n.style.cssText;
	}

	public static function splitCss(s:String):Array<String> {
		var a = s.split(';');
		a.pop();
		return a.map(function(s:String) return StringTools.ltrim(s) + ';');
	}

	public static function mapToJSMap<K, V>(map:Map<K, V>):JsMap<K, V> {
		var n:JsMap<K, V> = untyped __js__('new Map()');
		for (k in map.keys()) n.set(k, map[k]);
		return n;
	}

	public static function stringJSMapToMap<K:String, V:Any>(map:JsMap<K, V>):Map<K, V> {
		return [for (k in map.keys()) k => map.get(k)];
	}

	public static function intJSMapToMap<K:Int, V:Any>(map:JsMap<K, V>):Map<K, V> {
		return [for (k in map.keys()) k => map.get(k)];
	}

}