package precise;

class FloatTools {
	/**
		Return the binary encoding of a Float in a Bytes object

		The choice of std calls used assumes that the most relevant target is neko.
		Regardless, compatibility with other targets is garanteed (as long as the std calls
		behave as documented).
	**/
	public static function toBytes(x:Float, bigEndian=false):haxe.io.Bytes
	{
		/*
			On Neko (!neko_v21):

			 - Bytes.setDouble -> FPHelper._double_bytes
				-> std.ndll::double_bytes
			 - BytesOutput.writeDouble -> FPHelper.doubleToI64
				-> std.ndll::double_bytes

			Note: as of 4.0.0-rc.1+93044746a, neko_v21 doesn't produce working builds,
			and is currently untestd on upstream.
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

	/**
		Compute the unit-in-the-last-place (ULP) of a Float
	**/
	public static function ulp(x:Float):Float
	{
		if (!Math.isFinite(x))
			throw 'ulp only defined for finite numbers, but argument is $x';

		/*
			We use a Bytes object to manipulate the Float in binary; note that
			Bytes.getDouble assumes little endianess.

			63  62       52  51                                    0
			[s][  b. exp.  ][               mantissa                ]
			| SEEEEEEE| EEEEMMMM| MMMMMMMM| ... | MMMMMMMM| MMMMMMMM|
			| byte[7] | byte[6] | byte[5] | ... | byte[1] | byte[0] |

			Based on: Patrikalakis, N.; Maekawa, T.; Cho, W.  Shape Interrogation for
			Computer Aided Design and Manufacturing (Section 4.8.2, algorithm 4.2).
		*/
		var bytes = toBytes(x, false);

		// isolate the biased exponent, but keep it left (up) shifted by 4 bits
		var exp = 0x7ff0 & bytes.getUInt16(6);

		// ulp = 2^(E)*2^(-52) and 52 << 4 = 0x0340
		bytes.fill(0, 8, 0);
		if (exp > 0x0340) {  // normalized ulp
			bytes.setUInt16(6, exp - 0x0340);
		} else if (exp > 0) {  // subnormal ulp, but normal x
			var e1 = (exp >> 4) - 1;
			var pos = e1 >> 3;
			var bit = e1 % 8;
			bytes.set(pos, 1 << bit);
		} else {   // subnormal x
			bytes.set(0, 1);
		}
		return bytes.getDouble(0);
	}

	/**
		Return a human-readable representation of a Float's binary encoding

		The return value always represents the binary encoding of the Float in big endian
		order.
	**/
	public static function toBinaryRepr(x:Float):String
	{
		var bytes = toBytes(x, true);
		var buf = new StringBuf();
		for (byte in 0...8) {
			for (bit in 0...8) {
				if ((byte == 0 && bit == 1) || (byte == 1 && bit == 4))
					buf.add(" ");
				buf.add((bytes.get(byte) >> (7 - bit)) & 1);
			}
		}
		return buf.toString();
	}
}
