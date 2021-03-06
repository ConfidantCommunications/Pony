package module;

import types.BAConfig;
import types.BASection;
import pony.Fast;
import pony.text.TextTools;
import pony.fs.File;
import pony.fs.Dir;

private typedef TPConfig = { > BAConfig, > TPUnit,
	from: String,
	to: String,
	?clean: Bool
}

private typedef TPUnit = {
	format: String,
	scale: Float,
	?datascale: Float,
	quality: Float,
	input: Array<String>,
	output: String,
	rotation: Bool,
	?trim: String
}

/**
 * Texturepacker module
 * @author AxGord <axgord@gmail.com>
 */
class Texturepacker extends CfgModule<TPConfig> {

	private static inline var PRIORITY:Int = 3;

	private var ignoreList:Array<String>;
	private var toList:Array<String>;
	private var haveClean:Bool;

	public function new() super('texturepacker');

	override public function init():Void initSections(PRIORITY, BASection.Prepare);

	override private function readNodeConfig(xml:Fast, ac:AppCfg):Void {
		new Path(xml, {
			app: ac.app,
			debug: ac.debug,
			before: false,
			section: BASection.Prepare,
			format: 'json png',
			scale: 1,
			quality: 1,
			from: '',
			to: '',
			rotation: true,
			input: [],
			output: null,
			allowCfg: false
		}, configHandler);
	}

	override private function runNode(cfg:TPConfig):Void {
		var unit:TPUnit = cfg;
		unit.input = [for (e in cfg.input) cfg.from + e];
		unit.output = cfg.to + cfg.output;

		if (cfg.clean) haveClean = true;

		var format = unit.format.split(' ');
		var f:String = format.shift();

		var first:Bool = true;
		for (s in format) {
			var command = unit.input.copy();

			command.push('--format');
			command.push(f);
			
			var outExt = switch f {
				case 'phaser-json-array', 'phaser-json-hash', 'pixijs': 'json';
				case f: f;
			}

			var datafile = unit.output + (first ? '' : '_$s') + '.' + outExt;
			command.push('--data');
			command.push(datafile);
			
			var sheetfile = unit.output + '.' + s;
			command.push('--sheet');
			command.push(sheetfile);

			if (cfg.clean) {
				ignoreList.push(datafile);
				ignoreList.push(sheetfile);
				toList.push((datafile:File).fullDir);
			}

			command.push('--scale');
			command.push(Std.string(unit.scale));

			command.push('--scale-mode');
			command.push('Smooth');

			command.push(unit.rotation ? '--enable-rotation' : '--disable-rotation');

			switch format[1] {
				case 'png':
					command.push('--png-opt-level');
					command.push('7');
				case 'jpg':
					command.push('--jpg-quality');
					command.push(Std.string(Std.int(unit.quality * 100)));
				case _:
			}

			command.push('--force-squared');

			command.push('--pack-mode');
			command.push('Best');

			command.push('--algorithm');
			command.push('MaxRects');

			command.push('--maxrects-heuristics');
			command.push('Best');

			if (unit.trim != null) {
				var a:Array<String> = unit.trim.split(' ');
				if (a.length == 2) {
					var v:Int = Std.parseInt(a[0]);
					if (Std.string(v) == a[0]) {
						command.push('--trim-mode');
						command.push(a[1]);
						command.push('--trim-threshold');
						command.push(Std.string(v));
					} else {
						var v:Int = Std.parseInt(a[1]);
						command.push('--trim-mode');
						command.push(a[0]);
						command.push('--trim-threshold');
						command.push(Std.string(v));
					}
				} else if (a.length == 1) {
					var v:Int = Std.parseInt(a[0]);
					if (Std.string(v) == a[0]) {
						command.push('--trim-mode');
						command.push('Trim');
						command.push('--trim-threshold');
						command.push(Std.string(v));
					} else {
						command.push('--trim-mode');
						command.push(a[0]);
					}
				}
			}

			Utils.command('TexturePacker', command);

			if (unit.datascale != null) {
				switch outExt {
					case 'json':
						pony.text.TextTools.betweenReplaceFile(datafile, '"scale": "', '",', Std.string(unit.datascale));
					case _:
				}
			}
			
			first = false;
		}
	}

	override private function run(cfg:Array<TPConfig>):Void {
		ignoreList = [];
		toList = [];
		haveClean = false;
		for (e in cfg) runNode(e);
		clean();
		finishCurrentRun();
	}

	private function clean():Void {
		if (haveClean) {
			var remList:Array<String> = toList.copy();
			for (a in toList) {
				for (b in toList) {
					if (a.length > b.length) {
						if (a.indexOf(b) == 0) remList.remove(a);
					} 
				}
			}

			log('Clean pathes: ' + remList.join(', '));
			log('Ignores: ' + ignoreList.join(', '));

			for (p in remList) {
				var d:Dir = p;
				for (f in d.contentRecursiveFiles()) {
					if (ignoreList.indexOf(f.first) == -1) {
						log('Delete file: ' + f.first);
						f.delete();
					}
				}
			}

		}
	}

}

private class Path extends BAReader<TPConfig> {

	override private function clean():Void {
		cfg.format = 'json png';
		cfg.scale = 1;
		cfg.quality = 1;
		cfg.from = '';
		cfg.to = '';
		cfg.rotation = true;
		cfg.input = [];
		cfg.output = null;
	}

	override private function readXml(xml:Fast):Void {
		var variants:Array<TPConfig> = [for (node in xml.nodes.variant) cast (selfCreate(node), Path).cfg];
		if (variants.length > 0) {
			for (v in variants) {
				cfg = v;
				super.readXml(xml);
			}
		} else {
			super.readXml(xml);
		}
	}

	override private function readAttr(name:String, val:String):Void {
		switch name {
			case 'format': cfg.format = val;
			case 'scale': cfg.scale = cfg.scale * Std.parseFloat(val);
			case 'datascale': cfg.datascale = Std.parseFloat(val);
			case 'quality': cfg.quality = Std.parseFloat(val);
			case 'from': cfg.from += val;
			case 'to': cfg.to += val;
			case 'rotation': cfg.rotation = !TextTools.isFalse(val);
			case 'trim': cfg.trim = StringTools.trim(val);
			case 'clean': cfg.clean = TextTools.isTrue(val);
			case _:
		}
	}

	override private function readNode(xml:Fast):Void {
		switch xml.name {
			case 'path': selfCreate(xml);
			case 'unit': new Unit(xml, copyCfg(), onConfig);
			case 'variant':
			case _: throw 'Unknown tag';
		}
	}

}

private class Unit extends Path {

	override private function readNode(xml:Fast):Void {
		switch xml.name {
			case 'path':
				var from = normalize(xml.att.from);
				for (node in xml.nodes.input) {
					cfg.input.push(from + normalize(node.innerData));
				}
			case 'input': cfg.input.push(normalize(xml.innerData));
			case 'output': cfg.output = normalize(xml.innerData);
			case _: throw 'Unknown tag';
		}
	}

	override private function end():Void onConfig(cfg);

}