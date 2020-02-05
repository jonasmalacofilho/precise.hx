package precise;

/**
	Tools for using Floats in precise computations

	TODO null safety
**/
class FloatTools {
	/**
		Faster and inlineable version of Math.isNaN

		Only safe if the target correctly implements comparisons between NaN and
		NEGATIVE_INFINITY.
	**/
	public static inline function fastIsNaN(x:Float) {
		return !(x >= Math.NEGATIVE_INFINITY);
	}

	/**
		Return the binary encoding of a Float in a Bytes object
	**/
	public static inline function toBytes(x:Float, bigEndian = false):haxe.io.Bytes {
		#if (neko && !neko_v21 && haxe_ver >= 3.2)
		return nekoFastFloatToBytes(x, bigEndian);
		#else
		return safeFloatToBytes(x, bigEndian);
		#end
	}

	#if neko
	static function nekoFastFloatToBytes(x:Float, bigEndian = false):haxe.io.Bytes {
		/**
			Haxe APIs on Neko are currently implemented with std.ndll::double_bytes:

			 - Bytes.setDouble -> FPHelper._double_bytes -> std.ndll::double_bytes
			 - BytesOutput.writeDouble -> FPHelper.doubleToI64 -> std.ndll::double_bytes

			Note: as of 4.0.0-rc.1+93044746a, Haxe is not tested with -D neko_v21, and
			enabling this flag doesn't produce working builds.
		**/
		var data = @:privateAccess haxe.io.FPHelper._double_bytes(x, bigEndian);
		return haxe.io.Bytes.ofData(untyped data);
	}
	#end

	static function safeFloatToBytes(x:Float, bigEndian = false):haxe.io.Bytes {
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
	}

	/**
		Compute the unit-in-the-last-place (ULP) of a Float

		If the finite FP number X = d[0].d[1]d[2]...d[p−1]×r^e is used to represent an
		infinitely precise x, it is in error by |d[0].d[1]d[2]...d[p−1] - (x/r^e)| units in
		the last place.  Thus, for finite X,

				      ulp(X) = r^(e - p + 1).

		However, if X is ±∞, x cannot be represented by a finite FP number and ulp(X) is the
		distance between the largest finite number and its predecessor.  Moreover, ulp(NaN)
		is NaN.

		This particular definition of ULP combines the cheap implementation for finite X
		from Goldberg (1991) with the well defined behavior around ±∞ and NaN from Muller
		(2005).

		Additionally, from this definition and for finite X (Muller, 2005):

					  X = RN(x) ⇒ |X − x| ≤ 1/2×ulp(X)
				   |X - x| < 1/2×ulp(X) does not imply X = RN(x)
				       X ∈ {RD(x), RU(x)} ⇒ |X − x| ≤ ulp(X)
				 |X − x| < ulp(X) does not imply X ∈ {RD(x), RU(x)}

		The implemntation manipulates the binary represation of the FP number.  For this, is
		useful to recal that, assuming little endianess (and all APIs used garantee little
		endianess regardless of the platform), the memory layout of a double precision
		floating point number is:

			      63  62       52  51                                    0
			     [s][  b. exp.  ][               fraction                ]
			     | SEEEEEEE| EEEEFFFF| FFFFFFFF| ... | FFFFFFFF| FFFFFFFF|
			     | byte[7] | byte[6] | byte[5] | ... | byte[1] | byte[0] |
			     |         int32[1]         ...         int32[0]         |

		When computing and returning the resulting value of ulp(X), there are four cases to
		consider:

		1. Both X and ulp(X) are normal and finite
		2. X is normal and finite, but ulp(X) will be subnormal
		3. X is not finite
		4. X is already subnormal

		Goldberg (1991).  What every computer scientist should know about floating-point
		arithmetic.

		Knuth (1997).  The art of computer programming, 3rd edition (section 4.2.2.A).

		Muller, Jean-Michel (2005).  On the definition of ulp(x).
		http://ljk.imag.fr/membres/Carine.Lucas/TPScilab/JMMuller/ulp-toms.pdf

		Patrikalakis, N.; Maekawa, T.; Cho, W (2009).  Shape interrogation for computer
		aided design and manufacturing (section 4.8.2, algorithm 4.2).
		http://web.mit.edu/hyperbook/Patrikalakis-Maekawa-Cho/node46.html
	**/
	public static inline function ulp(x:Float):Float {
		#if (!hl || precise.force_fast_ulp)
		return fastUlp(x);
		#else
		return safeUlp(x);
		#end
	}

	@:access(haxe.Int64)
	static function fastUlp(x:Float):Float {
		// FIXME (hl) breaks thread safety
		// FIXME (hlc) breakes -O3
		var tmp:haxe.Int64 = haxe.io.FPHelper.doubleToI64(x);
		var bexp = (tmp.high >> 20) & 0x7ff;
		if (bexp > 52 && bexp != 0x7ff) { // normal ulp
			tmp.set_high((bexp - 52) << 20);
			tmp.set_low(0);
		} else if (bexp > 0 && bexp != 0x7ff) { // subnormal ulp, but normal x
			var uexp = bexp - 1;
			tmp.set_high(0);
			tmp.set_low(1 << (uexp % 32));
			if (uexp > 32) {
				tmp.set_high(tmp.low);
				tmp.set_low(0);
			}
		} else if (bexp == 0x7ff) { // ulp of non finite x
			// inefficient, but focuses code and performance on the more common paths
			return fastIsNaN(x) ? Math.NaN : Math.pow(2, 1023 - 52);
		} else { // subnormal x
			tmp.set_high(0);
			tmp.set_low(1);
		}
		return haxe.io.FPHelper.i64ToDouble(tmp.low, tmp.high);
	}

	static function safeUlp(x:Float):Float {
		var tmp:haxe.io.Bytes = toBytes(x, false);
		var lbexp = 0x7ff0 & tmp.getUInt16(6); // left shifted biased exponent
		tmp.fill(0, 8, 0);
		if (lbexp == 0x7ff0) { // ulp of non finite x
			// inefficient, but focuses code and performance on the more common paths
			return fastIsNaN(x) ? Math.NaN : Math.pow(2, 1023 - 52);
		} else if (lbexp > 0x0340) { // normal ulp (note: 0x034 == 52)
			tmp.setUInt16(6, lbexp - 0x0340);
		} else if (lbexp > 0) { // subnormal ulp, but normal x
			var e1 = (lbexp >> 4) - 1;
			var pos = e1 >> 3;
			var bit = e1 % 8;
			tmp.set(pos, 1 << bit);
		} else { // subnormal x
			tmp.set(0, 1);
		}
		return tmp.getDouble(0);
	}

	/**
		Return a human-readable representation of a Float's binary encoding

		The return value always represents the binary encoding of the Float in big endian
		order.
	**/
	public static function repr(x:Float):String {
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
