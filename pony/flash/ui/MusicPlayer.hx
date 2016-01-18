/**
* Copyright (c) 2012-2016 Alexander Gordeyko <axgord@gmail.com>. All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification, are
* permitted provided that the following conditions are met:
*
*   1. Redistributions of source code must retain the above copyright notice, this list of
*      conditions and the following disclaimer.
*
*   2. Redistributions in binary form must reproduce the above copyright notice, this list
*      of conditions and the following disclaimer in the documentation and/or other materials
*      provided with the distribution.
*
* THIS SOFTWARE IS PROVIDED BY ALEXANDER GORDEYKO ``AS IS'' AND ANY EXPRESS OR IMPLIED
* WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
* FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ALEXANDER GORDEYKO OR
* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
* ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
* ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
* The views and conclusions contained in the software and documentation are those of the
* authors and should not be interpreted as representing official policies, either expressed
* or implied, of Alexander Gordeyko <axgord@gmail.com>.
**/
package pony.flash.ui;

import flash.display.MovieClip;
import flash.text.TextField;
import pony.flash.ui.Button;
import pony.flash.ui.SongPlayer;
import pony.geom.Point;
import pony.ui.gui.ButtonCore;
import pony.ui.gui.SwitchableList;

import pony.flash.SongPlayerCore;

/**
 * MusicPlayer
 * @author AxGord
 */
class MusicPlayer extends SongPlayer {
#if !starling
	@:stage(set) private var song:MovieClip;
	
	private var songClass:Class<MovieClip>;
	private var beginPoint:Point<Float>;
	private var songHeight:Float;
	private var sw:SwitchableList;
	
	private var songList:List<MovieClip> = new List();
	private var currentList:Array<SongInfo>;
	
	override private function init() {
		visible = false;
		super.init();
		songClass = Type.getClass(song);
		beginPoint = {x: song.x, y: song.y};
		songHeight = song.height;
		removeChild(song);
		song = null;
	}
	
	
	public function loadPlaylist(pl:Array<SongInfo>):Void {
		if (visible) unloadPlaylist();
		visible = true;
		currentList = pl;
		var bcs:Array<ButtonCore> = [];
		var i = 0;
		for (e in pl) {
			var o:MovieClip = Type.createInstance(songClass, []);
			o.x = beginPoint.x;
			o.y = beginPoint.y + i * songHeight;
			addChild(o);
			songList.push(o);
			var b:Button = untyped o.b;
			bcs.push(b.core);
			var t:TextField = untyped o.tTitle;
			t.text = SongPlayerCore.formatSong(e);
			t.mouseEnabled = false;
			var t:TextField = untyped o.tTime;
			t.text = e.length;
			t.mouseEnabled = false;
			i++;
		}
		sw = new SwitchableList(bcs);
		sw.change << select;
		core.loadSong(pl[0]);
		core.onComplete << sw.next;
	}
	
	public function select(n:Int):Void {
		var song = currentList[n];
		core.loadSong(song);
	}
	
	public function unloadPlaylist():Void {
		visible = false;
	}
#end
}