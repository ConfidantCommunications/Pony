package pony.unity3d.scene;

import pony.events.Signal0;
import pony.time.DeltaTime;
import pony.events.LV;
import pony.events.Signal;
import pony.unity3d.ui.LoadScreen;
import unityengine.BoxCollider;
import unityengine.MeshCollider;
import unityengine.Input;
import unityengine.MonoBehaviour;
import unityengine.Transform;

using hugs.HUGSWrapper;

/**
 * MouseHelper
 * @author AxGord <axgord@gmail.com>
 * @author BoBaH6eToH
 */
@:nativeGen class MouseHelper extends MonoBehaviour {

	public static var globalMiddleDown:Signal = new Signal();
	public static var globalMiddleUp:Signal = new Signal();
	public static var lock:LV<Int> = new LV(0);
	public static var middleMousePressed:Bool = false;
	private static var inited:Bool = false;
	
	@:meta(UnityEngine.HideInInspector)
	@:isVar public var overed(get,never):Bool;
	@:meta(UnityEngine.HideInInspector)
	public var over:Signal0<MouseHelper>;
	public var out:Signal0<MouseHelper>;
	public var down:Signal0<MouseHelper>;
	public var middleDown:Signal0<MouseHelper>;
	public var middleUp:Signal0<MouseHelper>;
	
	@:meta(UnityEngine.HideInInspector)
	private var _overed:Int = 0;
	@:meta(UnityEngine.HideInInspector)
	private var ovr:MouseHelper;
	@:meta(UnityEngine.HideInInspector)
	private var ovrs:Int = 0;
	
	@:meta(UnityEngine.HideInInspector)
	public var sub:Bool = false;
	
	public static function updateStatic():Void
	{
		if (Input.GetMouseButton(2))
		{			
			if (!middleMousePressed) {
				middleMousePressed = true;
				globalMiddleDown.dispatch();
			}
		}
		else if (middleMousePressed) 
		{
			globalMiddleUp.dispatch();
			middleMousePressed = false;			
		}
	}
	
	public static function init():Void
	{
		if ( inited ) return;
		inited = true;
		DeltaTime.update.add(updateStatic);//todo: add if have listener
	}
	
	
	private function new() {
		super();
		over = Signal.create(this);
		out = Signal.create(this);
		down = Signal.create(this);
		middleDown = Signal.create(this);
		middleUp = Signal.create(this);
		lock.add(resetOvrs);
		lock.add(updateOverState);
	}
	
	public function Start():Void {
		init();
		if (LoadScreen.lastLoader != null && !sub)
			LoadScreen.lastLoader.addAction(ft);
		else
			ft();
	}
	
	public function ft():Void {
		if (renderer != null && collider == null)
			gameObject.addTypedComponent(MeshCollider);
		
		for (e in gameObject.getComponentsInChildrenOfType(Transform)) {
			if (e == transform) continue;
			ovr = e.gameObject.getTypedComponent(MouseHelper);
			if (ovr == null) {
				ovr = e.gameObject.addTypedComponent(MouseHelper);
				ovr.sub = true;
			}
			ovr.over.add(subOver);
			ovr.out.add(subOut);
			ovr.down.add(down.dispatchEvent);
			ovr.middleDown.add(middleDown.dispatchEvent);
			ovr.middleUp.add(middleUp.dispatchEvent);
		}
		
	}
	
	private function resetOvrs():Void {
		if (overed) out.dispatch();
		ovrs = 0;
		_overed = 0;
	}
	
	private function subOver():Void {
		if (!overed)
			over.dispatch();
		ovrs++;
	}
	
	private function subOut():Void {
		ovrs--;
		if (!overed)
			out.dispatch();
	}
	
	private function Update():Void {
		if (lock.value > 0) return;
		if (_overed == 0) return;
		_overed--;
		if (_overed == 0) updateOverState();
	}
	
	private function OnMouseOver():Void {
		if (!enabled) return;
		if (lock.value > 0) return;
		if (_overed == 2) return;
		_overed = 2;
		updateOverState();
	}
	
	private function updateOverState():Void {
		if (_overed == 2 && lock.value == 0) {
			if (!overed) {
				ovrs++;
				over.dispatch();
				globalMiddleDown.add(middleDown.dispatchEvent);
				globalMiddleUp.add(middleUp.dispatchEvent);
			}
		} else {
			if (overed) {
				ovrs--;
				out.dispatch();
				globalMiddleDown.remove(middleDown.dispatchEvent);
				globalMiddleUp.remove(middleUp.dispatchEvent);
			}
		}
	}
	
	private function OnMouseDown():Void {
		if (overed)
			down.dispatch();
	}
	
	inline private function get_overed():Bool return ovrs > 0;
}