package pony;

import haxe.PosInfos;
import pony.events.Signal2;

/**
 * Logable interface
 * @author AxGord <axgord@gmail.com>
 */
interface ILogable {
	#if !flash
	var onLog(get,never):Signal2<String, PosInfos>;
	var onError(get, never):Signal2<String, PosInfos>;
	#end
	function error(s:String, ?p:PosInfos):Void;
	function log(s:String, ?p:PosInfos):Void;
}