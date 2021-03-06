package pony.ui.gui;

import pony.geom.Align;
import pony.geom.Border;
import pony.geom.GeomTools;
import pony.geom.Point;

using pony.Tools;

/**
 * RubberLayoutCore
 * @author AxGord <axgord@gmail.com>
 */
class RubberLayoutCore<T> extends BaseLayoutCore<T> {
	
	public var width(default, set):Float;
	public var height(default, set):Float;

	@:arg private var _vert:Bool = false;
	@:arg private var _border:Border<Int> = 0;
	@:arg private var _padding:Bool = true;
	@:arg private var _align:Align = new Pair(VAlign.Middle, HAlign.Center);
	
	public var vert(get, set):Bool;
	public var border(get, set):Border<Int>;
	public var padding(get, set):Bool;
	public var align(get, set):Align;
	
	override public function update():Void {
		if (objects == null) return;
		if (!ready) return;
		var positions = GeomTools.pointsCeil(GeomTools.center(
				new Point(width, height),
				[for (obj in objects) {
					var v:Point<Float> = getObjSize(obj);
					v == null ? new Point<Float>(0, 0) : v;
				}],
				vert, border, padding, align
			));
		for (p in objects.pair(positions)) {
			setXpos(p.a, p.b.x);
			setYpos(p.a, p.b.y);
		}
		super.update();
	}
	
	override private function get_size():Point<Float> return new Point(width, height);
	
	@:extern inline private function get_vert():Bool return _vert;
	@:extern inline private function get_border():Border<Int> return _border;
	@:extern inline private function get_padding():Bool return _padding;
	@:extern inline private function get_align():Align return _align;
	
	@:extern inline private function set_width(v:Float):Float {
		if (width == v) return v;
		width = v;
		update();
		return v;
	}
	
	@:extern inline private function set_height(v:Float):Float {
		if (height == v) return v;
		height = v;
		update();
		return v;
	}
	
	@:extern inline private function set_vert(v:Bool):Bool {
		if (vert == v) return v;
		_vert = v;
		update();
		return v;
	}
	
	@:extern inline private function set_border(v:Border<Int>):Border<Int> {
		if (border == v) return v;
		_border = v;
		update();
		return v;
	}
	
	@:extern inline private function set_padding(v:Bool):Bool {
		if (padding == v) return v;
		_padding = v;
		update();
		return v;
	}
	
	@:extern inline private function set_align(v:Align):Align {
		if (align == v) return v;
		_align = v;
		update();
		return v;
	}
	
}