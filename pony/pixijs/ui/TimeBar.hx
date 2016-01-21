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
package pony.pixijs.ui;

import pony.geom.Point;
import pony.pixijs.UniversalText;
import pony.time.DTimer;
import pony.time.Time;
import pony.time.TimeInterval;

/**
 * TimeBar
 * @author AxGord <axgord@gmail.com>
 */
class TimeBar extends Bar {

	public var timeLabel:UniversalText;
	private var style:ETextStyle;
	private var timer:DTimer;
	
	public function new(bg:String, fillBegin:String, fill:String, ?offset:Point<Int>, ?style:ETextStyle) {
		this.style = style;
		super(bg, fillBegin, fill, offset);
		onReady < readyHandler;
	}
	
	private function readyHandler(p:Point<Int>):Void {
		timeLabel = new UniversalText('00:00', style);
		timeLabel.x = (p.x - timeLabel.width) / 2;
		timeLabel.y = (p.y - timeLabel.height) / 2 - 2;
		addChild(timeLabel);
		timer = DTimer.createFixedTimer(null);
		timer.progress << progressHandler;
		timer.update << updateHandler;
	}
	
	private function progressHandler(p:Float):Void core.percent = p;
	private function updateHandler(t:Time):Void timeLabel.text = t.showMinSec();
	
	public function start(t:TimeInterval):Void {
		timer.time = t;
		timer.reset();
		timer.start();
	}
	
	@:extern inline public function pause():Void timer.stop();
	@:extern inline public function play():Void timer.start();
	
}