class FloatTools {
	public static function toBytes(x:Float, bigEndian=false)
	{
		/*
		The choice of which std calls are used depends on the most relevant target,
		and for stout it is neko.  However, minimal cross-platform compatibility
		should be kept (interp and, if possible, other targets too, even if with
		some performance penalty).

		On Neko (!neko_v21):

		 - Bytes.setDouble -> FPHelper._double_bytes -> std.ndll::double_bytes
		 - BytesOutput.writeDouble -> FPHelper.doubleToI64 -> std.ndll::double_bytes

		Note: neko_v21 doesn't produce working builds on the Haxe version tested
		(4.0.0-rc.1+93044746a), and is currently untestd on upstream.
		*/
#if (neko && !neko_v21 && haxe_ver >= 3.2)
		var data = @:privateAccess haxe.io.FPHelper._double_bytes(x, bigEndian);
		return haxe.io.Bytes.ofData(untyped data);
#else
		if (!bigEndian) {
			var bytes = haxe.io.Bytes.alloc(8);
			bytes.setDouble(0, x);
			return bytes;
		} else {
			var tmp = new haxe.io.BytesOutput();
			tmp.bigEndian = bigEndian;
			tmp.writeDouble(x);
			return tmp.getBytes();
		}
#end
	}

	// TODO test/improve/add unit tests/consider relerr
	// TODO double check subnormal x
	// TODO improve choice of std calls
	public static function ulp(x:Float)
	{
		// minipulate raw float data; note that Bytes is little endian
		var bytes = haxe.io.Bytes.alloc(8);
		bytes.setDouble(0, x);

		// isolate the biased exponent, but keep it right shifted by 4 bits
		var exp = 0x7ff0 & bytes.getUInt16(6);

		// ulp = 2^(E)*2^(-52); note that 52 << 4 = 0x0340
		bytes.fill(0, 8, 0);
		if (exp > 0x340) {
			// normalized ulp
			bytes.setUInt16(6, exp - 0x0340);
		} else if (exp > 0) {
			// subnormal ulp, but normal x
			var e1 = (exp >> 4) - 1;
			var pos = e1 >> 3;
			var bit = e1 % 8;
			bytes.set(pos, 1 << bit);
		} else {
			// subnormal x
			bytes.set(0, 1);
		}
		return bytes.getDouble(0);
	}

	public static function show(x:Float, hex=false, visual=true)
	{
		var bytes = toBytes(x, true);
		if (hex)
			return bytes.toHex();
		var buf = new StringBuf();
		for (byte in 0...8) {
			for (bit in 0...8) {
				if (visual && ((byte == 0 && bit == 1) ||
						(byte == 1 && bit == 4)))
					buf.add(" ");
				buf.add((bytes.get(byte) >> bit) & 1);
			}
		}
		return buf.toString();
	}
}
