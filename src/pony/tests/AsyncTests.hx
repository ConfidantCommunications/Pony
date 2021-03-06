package pony.tests;

import haxe.CallStack;
import haxe.Log;
import haxe.PosInfos;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import pony.Pair;

using pony.Tools;

/**
 * AsyncTests
 * @author DIS
 * @author AxGord
 */
class AsyncTests extends TestCase {
	
	public static var isRead:Map<Int, Bool>;
	private static var assertList:List < {a:Dynamic, b:Dynamic, pos:PosInfos} > = new List();
	private static var testCount:Int = 0;
	private static var complite:Bool = false;
	private static var dec:String = '----------';
	private static var waitList:List<{it:IntIterator, cb:Void->Void}> = new List<{it:IntIterator, cb:Void->Void}>();
	private static var counter:Int = 0;
	private static var lock:Bool;
	
	static public function init(count:Int):Void 
	{
		if (testCount != 0) throw 'Second init';
		Log.trace('$dec Begin tests ($count) $dec');
		testCount = count;
		isRead = [for (i in 0...count) i => false];
	}

	static public inline function equals<T>(a:T, b:T, ?infos:PosInfos):Void 
	{
		assertList.push({a:a, b:b, pos: infos});
	}
	
	static public function setFlag(n:Int, ?infos:PosInfos) 
	{
		#if cs
		pony.cs.Synchro.lock(isRead, function() {
		#end
			//trace(counter++);
			if (n >= testCount || n < 0) throw 'Wrong test number';
			if (isRead[n]) throw 'Double complite';
			Log.trace('$dec Test #$n finished $dec', infos);
			isRead[n] = true;
			if (lock) {
				trace('Locked call');
				return;
			}
			lock = true;
			checkWaitList();
			for (e in isRead) if (!e) {
				lock = false;
				return;
			}
			var test:TestRunner = new TestRunner();
			test.add(new AsyncTests());
			test.run();
		#if cs
		});
		#end
	}
	
	public function testRun()
	{
		for (e in assertList) assertEquals(e.a, e.b, e.pos);
		complite = true;
	}
	
	static public function finish(?infos:PosInfos):Void {
		if (!complite) throw 'Tests not complited: ' + {
			var a = [];
			for (k in isRead.keys()) if (!isRead[k]) a.push(k);
			a;
		};
		Log.trace('$dec All tests finished $dec', infos);
	}
	
	static public function wait(it:IntIterator, cb:Void->Void):Void {
		if (checkWait(it))
		{
			cb();
		}
		else 
		{
			waitList.push({it:it,cb:cb});
		}
	}
	
	static private function checkWait(it:IntIterator):Bool {
		for (i in it.copy()) if (!isRead[i]) return false;
		return true;
	}
	
	static private function checkWaitList():Void {
		for (e in waitList) if (checkWait(e.it)) {
			e.cb();
			waitList.remove(e);
		}
	}
	
}