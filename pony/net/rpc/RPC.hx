package pony.net.rpc;

import haxe.io.BytesOutput;
import pony.magic.HasSignal;

/**
 * IRPC - Remove Procedure Call Build System
 * -lib hxbit
 * use with IRPC
 * @author AxGord <axgord@gmail.com>
 */
class RPC<T:pony.net.rpc.IRPC> extends RPCBase<T> implements HasSignal {

	public var socket:pony.net.INet;

	public function new(s:pony.net.INet) {
		super();
		socket = s;
		s.onData << dataHandler;
		if (Std.is(s, pony.net.SocketClient)) {
			var s:pony.net.SocketClient = cast s;
			s.onConnect << s.sendAllStack;
		}
	}

	private function send():Void {
		var bo:BytesOutput = new BytesOutput();
		bo.write(pack());
		socket.send(bo);
	}

}