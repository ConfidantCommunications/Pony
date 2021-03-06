package pony.ui.gui;

import pony.events.Event1;
import pony.events.Signal1;
import pony.ui.touch.Touch;
import pony.ui.touch.Touchable;

/**
 * SliderCore
 * @author AxGord <axgord@gmail.com>
 */
class SliderCore extends BarCore {
	
	@:arg private var button:ButtonCore = null;
	private var draggable:Bool;
	
	@:bindable public var finalPercent:Float = 0;
	@:bindable public var finalPos:Float = 0;
	@:bindable public var finalValue:Float = 0;
	
	public var onStartDrag(default, null):Signal1<Touch>;
	public var onStopDrag(default, null):Signal1<Touch>;
	
	private var startPoint:Float = 0;
	public var wheelSpeed:Float = 2;

	public var track(default, set):Touchable;
	
	public function new(size:Float, isVertical:Bool = false, invert:Bool = false, draggable:Bool=true) {
		super(size, isVertical, invert);
		this.draggable = draggable;
		if (button != null) {
			onStartDrag = button.touch.onDown;
			onStopDrag = button.touch.onUp || button.touch.onOutUp;
		} else {
			onStartDrag = new Event1();
			onStopDrag = new Event1();
		}
		onStopDrag << stopDragHandler;
		if (draggable) {
			onStartDrag << (isVertical ? startYDragHandler : startXDragHandler);
			onStartDrag << startDragHandler;
		}
		if (button != null) changePos << button.touch.check;
	}
	
	@:extern inline
	public static function create(?b:ButtonCore, width:Float, height:Float, invert:Bool=false, draggable:Bool=true):SliderCore {
		var isVert = height > width;
		return new SliderCore(b, isVert ? height : width, isVert, invert, draggable);
	}
	
	override public function destroy():Void {
		destroySignals();
		if (button != null) button.destroy();
	}
	
	private function stopDragHandler(t:Touch):Void {
		if (t != null) t.onMove >> moveHandler;
		finalPos = pos;
		finalPercent = percent;
		finalValue = value;
		if (button != null) changePos << button.touch.check;
	}
	
	inline public function startDrag(t:Touch):Void untyped (onStartDrag:Event1<Touch>).dispatch(t);
	inline public function stopDrag(t:Touch):Void untyped (onStopDrag:Event1<Touch>).dispatch(t);
	
	private function startXDragHandler(t:Touch):Void startPoint = inv(pos) - t.x;
	private function startYDragHandler(t:Touch):Void startPoint = inv(pos) - t.y;
	
	private function startDragHandler(t:Touch):Void {
		if (t != null) t.onMove << moveHandler;
		if (button != null) changePos >> button.touch.check;
	}
	
	private function moveHandler(t:Touch):Void pos = limit(detectPos(t.x, t.y));
	
	@:extern inline private function detectPos(x:Float, y:Float):Float {
		return inv((isVertical ? y : x) + startPoint);
	}
	
	@:extern inline private function limit(p:Float):Float {
		return if (p < 0) 0;
		else if (p > size) size;
		else p;
	}

	public inline function wheel(v:Int):Void {
		scroll(wheelSpeed * v);
	}

	public inline function scroll(v:Float):Void {
		if (size >= 1)
			pos = limit(pos - wheelSpeed * v);
	}

	public inline function update():Void {
		var p = pos;
		pos = 0;
		pos = limit(p);
	}

	public inline function setPosValue(v:Float):Void {
		if (size >= 1) {
			value = v;
			update();
		}
	}

	public function set_track(v:Touchable):Touchable {
		if (track != v) {
			if (track != null) {
				track.onDown >> startDrag;
				track.onDown >> stopDrag;
			}
			track = v;
			if (v != null) {
				v.onDown << startDrag;
				v.onUp << stopDrag;
			}
		}
		return v;
	}

}