package pony.net.http.modules.mmodels.actions;

import pony.Pair;
import pony.net.http.modules.mmodels.Action;
import pony.net.http.WebServer;
import pony.Stream;
import pony.net.http.modules.mmodels.MModelsPut;
import pony.net.http.modules.mmodels.ModelConnect;
import pony.net.http.modules.mmodels.ModelPut;
import pony.text.tpl.ITplPut;
import pony.text.tpl.Tpl;
import pony.text.tpl.TplData;
import pony.text.tpl.Valuator;

using pony.Tools;

/**
 * Many
 * @author AxGord <axgord@gmail.com>
 */
class Many extends Action {
	override public function connect(cpq:CPQ, modelConnect:ModelConnect):Pair<EConnect, ISubActionConnect> {
		return new Pair(REG(cast new ManyConnect(this, cpq, modelConnect)), null);
	}
}

/**
 * ManyConnect
 * @author AxGord <axgord@gmail.com>
 */
class ManyConnect extends ActionConnect {
	
	override public function tpl(parent:ITplPut):ITplPut {
		initTpl();
		return new ManyPut(this, cpq, parent);
	}
	
}

/**
 * ManyPut
 * @author AxGord <axgord@gmail.com>
 */
@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(":async"))
class ManyPut extends pony.text.tpl.TplPut<ManyConnect, CPQ> {
	
	@:async
	override public function tag(name:String, content:TplData, arg:String, args:Map<String, String>, ?kid:ITplPut):String
	{
		if (!a.checkAccess()) return '';
		
		var mp:ModelPut = cast parent;
		var f = arg == null ? 'id' : arg;
		var a:Array<Dynamic> = @await a.call(mp.b == null ? [] : [Reflect.field(mp.b, f)]);
		if (args.exists('!'))
			return a.length == 0 ? @await parent.tplData(content) : '';
		else {
			if (args.exists('div')) {
				return @await div(arg, args, a);
			} else
				return @await many(a, ManyPutSub, content, arg);
		}
	}
	
	@:async
	private function div(arg:String, args:Map<String, String>, a:Array<Dynamic>):String {
		var n:String = args.get('div') == null ? 'many' : args.get('div');
		var na:Array<String> = [];
		if (args.exists('cols')) for (e in a){
			var s:String = '<div class="' + n + '">';
			for (f in args.get('cols').split(',').map(StringTools.trim))
				s += '<div class="' + f + '">'
					+ @await html(e, f)
					+ '</div>';
			s += '</div>';
			na.push(s);
		} else for (e in a) {
			var s:String = '<div class="' + n + '">';
			for (f in Reflect.fields(e))
				s += '<div class="' + f + '">'
					+ @await html(e, f)
					+ '</div>';
			s += '</div>';
			na.push(s);
		}
		return na.join(arg == null ? '' : arg);
	}
	
	@:async
	private function html(e:Dynamic, f:String):String {
		var c = a.base.model.columns[f];
		if (c.tplPut != null) {
			var o:Dynamic = Type.createInstance(c.tplPut, [c, e, this]);
			return @await o.html(f);
		} else {
			return Reflect.field(e, f);
		}
	}
	
}

/**
 * ManyPutSub
 * @author AxGord <axgord@gmail.com>
 */
@:build(com.dongxiguo.continuation.Continuation.cpsByMeta(":async"))
@:final class ManyPutSub extends Valuator<ManyPut, Dynamic> {
	
	@:async
	override public function tag(name:String, content:TplData, arg:String, args:Map<String, String>, ?kid:ITplPut):String
	{
		if (a.a.model.subactions.exists(name)) {
			return @await a.a.model.subactions[name].subtpl(parent, b).tag(name, content, arg, args, kid);
		} else {
			if (name == 'selected') {
				var f1 = a.a.checkActivePath(b);
				var f2 = !args.exists('!');
				if ((f1 && f2) || (!f1 && !f2))
					return @await tplData(content);
				else
					return '';
			} else {
				if (!a.a.base.model.columns.exists(name)) {
					var sm = a.b.getModule(MModelsConnect).list[name];
					if (sm != null) {
						return @await sm.tpl(this).tplData(content);
					} else {
						return '%$name%';
					}
				}
				var c = a.a.base.model.columns[name];
				if (c != null && c.tplPut != null) {
					var o = Type.createInstance(c.tplPut, [c, b, this]);
					return @await o.tag(name, content, arg, args, kid);
				} else
					return @await super.tag(name, content, arg, args, kid);
			}
		}
	}
	
	@:async
	override public function shortTag(name:String, arg:String, ?kid:ITplPut):String 
	{
		if (a.a.model.subactions.exists(name)) {
			return @await a.a.model.subactions[name].subtpl(parent, b).shortTag(name, arg, kid);
		} else {
			if (!a.a.base.model.columns.exists(name)) return '%$name%';
			var c = a.a.base.model.columns[name];
			if (c != null && c.tplPut != null) {
				var o = Type.createInstance(c.tplPut, [c, b, this]);
				return @await o.shortTag(name, arg, kid);
			} else
				return @await super.shortTag(name, arg, kid);
		}
	}
	
	@:async
	override public function valu(name:String, arg:String):String {
		if (Reflect.hasField(b, name))
			return Std.string(Reflect.field(b, name));
		else
			return null;
	}
	
}