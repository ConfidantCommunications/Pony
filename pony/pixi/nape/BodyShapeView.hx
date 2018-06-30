/**
* Copyright (c) 2012-2018 Alexander Gordeyko <axgord@gmail.com>. All rights reserved.
* 
* Redistribution and use in source and binary forms, with or without modification, are
* permitted provided that the following conditions are met:
* 
* 1. Redistributions of source code must retain the above copyright notice, this list of
*   conditions and the following disclaimer.
* 
* 2. Redistributions in binary form must reproduce the above copyright notice, this list
*   of conditions and the following disclaimer in the documentation and/or other materials
*   provided with the distribution.
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
**/
package pony.pixi.nape;

import pixi.core.graphics.Graphics;
import haxe.io.BytesInput;
import pony.Byte;
import pony.physics.nape.BodyShape;

/**
 * BodyShapeView
 * @author AxGord <axgord@gmail.com>
 */
class BodyShapeView extends BodyBaseView<BodyShape> {

	override private function drawDebug(g:Graphics):Void {
		var bi = new BytesInput(core.sbytes);
		var pb:Byte = bi.readByte();
		var fp:Byte = bi.readByte();
		g.moveTo(fp.a * core.resolution, fp.b * core.resolution);
		while (bi.position < bi.length) {
			var p:Byte = bi.readByte();
			g.lineTo(p.a * core.resolution, p.b * core.resolution);
		}
		g.lineTo(fp.a * core.resolution, fp.b * core.resolution);
		g.beginFill(g.lineColor = debugLines.pivotColor);
		g.x = -pb.a * core.resolution;
		g.y = -pb.b * core.resolution;
		g.drawCircle(-g.x, -g.y, debugLines.pivotSize);
	}

}