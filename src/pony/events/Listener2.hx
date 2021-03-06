package pony.events;

enum Listener2Type<T1, T2> {
	LFunction0( f:Void->Bool );
	LFunction1( f:T1->Bool );
	LFunction2( f:T1->T2->Bool );
	LEvent0( s:Event0, ?safe:Bool );
	LEvent1( s:Event1<T1>, ?safe:Bool );
	LEvent2( s:Event2<T1, T2>, ?safe:Bool );
	LSub( s:Event0, v1:T1, v2:T2 );
	LSub1( s:Event1<T2>, v:T1 );
	LSub2( s:Event1<T1>, v:T2 );
	LNot( s:Event2<T1,T2>, v1:T1, v2:T2 );
	LNot1( s:Event2<T1,T2>, v:T1 );
	LNot2( s:Event2<T1,T2>, v:T2 );
}

typedef Listener2_ < T1, T2 > = { once:Bool, listener:Listener2Type<T1, T2> }

/**
 * Listener1
 * @author AxGord <axgord@gmail.com>
 */
@:forward(once, listener)
abstract Listener2<T1, T2>(Listener2_<T1, T2>) to Listener2_<T1, T2> from Listener2_<T1, T2> {
	
	@:from @:extern inline private static function f0<T1,T2>(f:Void->Void):Listener2<T1, T2> return { once:false, listener:LFunction0(cast f) };
	@:from @:extern inline private static function f1<T1,T2>(f:T1->Void):Listener2<T1, T2> return { once:false,  listener:LFunction1(cast f) };
	@:from @:extern inline private static function f2<T1,T2>(f:T1->T2->Void):Listener2<T1, T2> return { once:false,  listener:LFunction2(cast f) };
	@:from @:extern inline private static function s0<T1,T2>(f:Event0):Listener2<T1, T2> return { once:false,  listener:LEvent0(f) };
	@:from @:extern inline private static function s1<T1,T2>(f:Event1<T1>):Listener2<T1, T2> return { once:false, listener:LEvent1(f) };
	@:from @:extern inline private static function s2<T1,T2>(f:Event2<T1, T2>):Listener2<T1, T2> return { once:false, listener:LEvent2(f) };
	inline public function call(a1:T1, a2:T2, ?safe:Bool):Bool return switch this.listener {
		case LFunction0(f): f();
		case LFunction1(f): f(a1);
		case LFunction2(f): f(a1, a2);
		case LEvent0(s, sv): s.dispatch(sv||safe);
		case LEvent1(s, sv): s.dispatch(a1, sv||safe);
		case LEvent2(s, sv): s.dispatch(a1, a2, sv||safe);
		case LSub(s, v1, v2) if (v1 == a1 && v2 == a2): s.dispatch(safe);
		case LSub1(s, v1) if (v1 == a1): s.dispatch(a2, safe);
		case LSub2(s, v2) if (v2 == a2): s.dispatch(a1, safe);
		case LNot(s, v1, v2) if (v1 != a1 && v2 != a2): s.dispatch(a1, a2, safe);
		case LNot1(s, v1) if (v1 != a1): s.dispatch(a1, a2, safe);
		case LNot2(s, v2) if (v2 != a2): s.dispatch(a1, a2, safe);
		case _: false;
	}
}