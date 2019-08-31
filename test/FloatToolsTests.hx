import utest.Assert.*;

using precise.FloatTools;

class FloatToolsTests extends utest.Test {
	static inline var MIN_POSITIVE_SUBNORMAL = 4.9406564584124654e-324; // 2^-1022 × 2^-52

	function spec_repr() {
		1.repr() ==
			"0 01111111111 0000000000000000000000000000000000000000000000000000";
		Math.PI.repr() ==
			"0 10000000000 1001001000011111101101010100010001000010110100011000";
		Math.NEGATIVE_INFINITY.repr() ==
			"1 11111111111 0000000000000000000000000000000000000000000000000000";
	}

	function spec_normal_ulp() {
		var x = 1.;
		var ulp = x.ulp();
		x.repr() ==
			"0 01111111111 0000000000000000000000000000000000000000000000000000";
		(x + ulp).repr() ==
			"0 01111111111 0000000000000000000000000000000000000000000000000001";
		(x - ulp).repr() ==
			"0 01111111110 1111111111111111111111111111111111111111111111111110";
		Math.pow(2, -52) == ulp;
	}

	function spec_subnormal_ulp() {
		// FIXME test ulp > buffer atom size and other cases
		var x = 2.2250738585072014e-307;
		var ulp = x.ulp();
		x.repr() ==
			"0 00000000100 0100000000000000000000000000000000000000000000000000";
		(x + ulp).repr() ==
			"0 00000000100 0100000000000000000000000000000000000000000000000001";
		(x - ulp).repr() ==
			"0 00000000100 0011111111111111111111111111111111111111111111111111";
		Math.pow(2, 4 - 1023 - 52) == ulp;
	}

	function spec_ulp_of_subnormal() {
		spec_ulp_of_zero();
	}

	function spec_ulp_of_zero() {
		var x = 0;
		var ulp = x.ulp();
		x.repr() ==
			"0 00000000000 0000000000000000000000000000000000000000000000000000";
		(x + ulp).repr() ==
			"0 00000000000 0000000000000000000000000000000000000000000000000001";
		(x - ulp).repr() ==
			"1 00000000000 0000000000000000000000000000000000000000000000000001";
		Math.pow(2, -1022 - 52) == ulp;
		MIN_POSITIVE_SUBNORMAL == ulp;
	}

	function spec_ulp_of_non_finite() {
		Math.POSITIVE_INFINITY.ulp() == Math.pow(2, 1023 - 52);
		Math.NEGATIVE_INFINITY.ulp() == Math.pow(2, 1023 - 52);
		Math.isNaN(Math.NaN.ulp()) == true;
	}
}
