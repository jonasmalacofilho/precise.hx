/**
	Mandelbrot set drawing benchmark

	Adapted from haxe/tests/benchs/mandelbrot/Mandelbrot.hx, part of
	the Haxe compiler test suite.

	The Haxe Compiler
	Copyright (C) 2005-2019  Haxe Foundation

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
**/

import haxe.Timer.stamp in now;

#if precise
typedef FloatType = precise.FloatInterval;
#else
typedef FloatType = Float;
#end

class Mandelbrot {
	static inline var SIZE = 25;
	static inline var MAX_ITERATIONS = 1000;
	static inline var MAX_RAD = 1 << 16;
	static inline var width = 35 * SIZE;
	static inline var height = 20 * SIZE;

	public static function main() {
		var t0 = now();
		inline function elapsed() {
			return Math.round((now() - t0) * 1000);
		}

		var palette = [];
		for (i in 0...(MAX_ITERATIONS + 1))
			palette.push(createPalette(i / MAX_ITERATIONS));
		var image = [];
		image[width * height - 1] = cast null;
		var outPixel = 0;
		var scale:FloatType = 0.1 / SIZE;
		var totalIterations = 0;

		for (y in 0...height) {
			if (y % 10 == 0) {
				var progress = Math.floor(y / height * 100);
				trace('${elapsed()} ms: $progress%, $totalIterations iterations');
			}
			for (x in 0...width) {
				var iteration = 0;
				var offsetI = x * scale - 2.5;
				var offsetJ = y * scale - 1.0;
				var valI:FloatType = 0.0;
				var valJ:FloatType = 0.0;
				#if precise
				while ((valI * valI + valJ * valJ).lower < MAX_RAD &&
						iteration < MAX_ITERATIONS) {
				#else
				while (valI * valI + valJ * valJ < MAX_RAD &&
						iteration < MAX_ITERATIONS) {
				#end
					var vi = valI * valI - valJ * valJ + offsetI;
					var vj = 2.0 * valI * valJ + offsetJ;
					#if precise
						valI.blit(vi);
						valJ.blit(vj);
					#else
						valI = vi;
						valJ = vj;
					#end
					iteration++;
				}
				image[outPixel++] = palette[iteration];
				totalIterations += iteration;
			}
		}

		var time = elapsed();
		trace('Mandelbrot $width x $height: $time ms, $totalIterations iterations');
		trace('${Math.round(time/totalIterations * 1e7) / 10} ns/iteration');
		#if sys
			var header = 'P6 $width $height 255\n';
			var buffer = haxe.io.Bytes.alloc(header.length + width * height * 3);
			var pos = header.length;
			buffer.blit(0, haxe.io.Bytes.ofString(header), 0, pos);
			for (pixel in image) {
				buffer.set(pos++, pixel.r);
				buffer.set(pos++, pixel.g);
				buffer.set(pos++, pixel.b);
			}
			sys.io.File.saveBytes("mandelbrot.ppm", buffer);
		#end
	}

	public static function createPalette(inFraction:Float)
	{
		var r = Std.int(inFraction * 255);
		var g = Std.int((1 - inFraction) * 255);
		var b = Std.int((0.5 - Math.abs(inFraction - 0.5)) * 2 * 255);
		return new RGB(r, g, b);
	}
}

abstract RGB(Int) {
	public var r(get, never):Int;
	public var g(get, never):Int;
	public var b(get, never):Int;

	inline public function new(inR:Int, inG:Int, inB:Int)
	{
		this = (inR << 16) | (inG << 8) | inB;
	}

	inline function get_r()
	{
		return (this & 0xff0000) >> 16;
	}

	inline function get_g()
	{
		return (this & 0xff00) >> 8;
	}

	inline function get_b()
	{
		return this & 0xff;
	}
}
