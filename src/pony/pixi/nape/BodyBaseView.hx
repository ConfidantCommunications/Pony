package pony.pixi.nape;

import pixi.core.textures.RenderTexture;
import pixi.core.graphics.Graphics;
import pixi.core.sprites.Sprite;
import pixi.core.display.DisplayObject;
import haxe.extern.EitherType;
import pony.geom.Point;
import pony.geom.Rect;
import pony.events.Signal1;
import pony.physics.nape.BodyBase;
import pony.physics.nape.DebugLineStyle;
import pony.pixi.App;
import pony.Pair;
import haxe.io.Bytes;

/**
 * BodyBaseView
 * @author AxGord <axgord@gmail.com>
 */
@:abstract class BodyBaseView<T:BodyBase> extends Sprite implements pony.magic.HasAbstract implements pony.magic.HasSignal {

	public static var DEBUG_CACHE(default, null):Map<String, Pair<Point<Float>, RenderTexture>> = new Map<String, Pair<Point<Float>, RenderTexture>>();

	public static var LIST(default, null):Map<Int, BodyBaseView<T>> = new Map<Int, BodyBaseView<T>>();

	@:auto public var onOut:Signal1<BodyBaseView<T>>;
	public var core(default, null):T;
	public var debugLines(default, set):DebugLineStyle;
	private var debugView:Sprite;

	public function new(core:T) {
		super();
		this.core = core;
		LIST[core.body.id] = this;
		core.onPos << posHandler;
		core.onRotation << rotationHandler;
		core.onOut << out;
		core.onDestroy < destroy.bind(null);
	}

	private function out():Void eOut.dispatch(this);

	public function scl(x:Float, y:Float):Void {
		scale.set(x, y);
		core.scale(x, y);
	}

	private function set_debugLines(v:DebugLineStyle):DebugLineStyle {
		if (debugLines != null) {
			removeChild(debugView);
			debugView.destroy();
			debugView = null;
		}
		if (v.pivotColor == null)
			v.pivotColor = v.color;
		if (v.pivotSize == null)
			v.pivotSize = v.size;
		debugLines = v;
		if (v != null) {
			var cid:Bytes = core.getCacheId();
			if (cid != null) {
				var cids:String = cid.toHex();
				var ct:Pair<Point<Float>, RenderTexture> = DEBUG_CACHE[cids];
				if (ct == null) {
					var g:Graphics = new Graphics();
					g.lineStyle(v.size, v.color);
					drawDebug(g);
					var p = new Point(g.x, g.y);
					g.x = v.size;
					g.y = v.size;
					var w = (-p.x + g.width + v.size) * 2;
					var h = (-p.y + g.height + v.size) * 2;
					g.scale.set(2);
					ct = new Pair(p, RenderTexture.create(w, h));
					App.main.app.renderer.render(g, ct.b, true);
					DEBUG_CACHE[cids] = ct;
				}
				debugView = new Sprite(ct.b);
				debugView.scale.set(0.5);
				debugView.position.set(ct.a.x - v.size, ct.a.y - v.size);
				addChild(debugView);
			} else {
				debugView = new Sprite();
				addChild(debugView);
				var g:Graphics = new Graphics();
				debugView.addChild(g);
				g.lineStyle(v.size, v.color);
				drawDebug(g);
				g.cacheAsBitmap = true;
			}
		}
		return v;
	}

	@:abstract private function drawDebug(g:Graphics):Void;

	private function posHandler(px:Float, py:Float):Void {
		position.set(px, py);
	}

	private function rotationHandler(r:Float):Void {
		rotation = r;
	}

	override public function destroy(?options:EitherType<Bool, DestroyOptions>):Void {
		if (core == null) return;
		LIST.remove(core.body.id);
		var c = core;
		core = null;
		c.destroy();
		if (debugView != null) {
			removeChild(debugView);
			debugView.destroy();
			debugView = null;
		}
		destroySignals();
		super.destroy(options);
	}
	
	public static function clearCache():Void {
		for (e in DEBUG_CACHE) e.b.destroy();
		DEBUG_CACHE = new Map<String, Pair<Point<Float>, RenderTexture>>();
	}
}