import utest.Assert.*;
using precise.FloatTools;

/**
	TODO ulp(null)
**/
class FloatToolsTests extends utest.Test {
	static inline var MIN_POSITIVE_SUBNORMAL = 4.9406564584124654e-324;  // 2^-1022 × 2^-52

	function test_show()
	{
		equals("0 01111111111 0000000000000000000000000000000000000000000000000000",
				1.toBinaryRepr());
		equals("0 10000000000 1001001000011111101101010100010001000010110100011000",
				Math.PI.toBinaryRepr());
		equals("1 11111111111 0000000000000000000000000000000000000000000000000000",
				Math.NEGATIVE_INFINITY.toBinaryRepr());
	}

	function test_normal_ulp()
	{
		var x = 1.;
		var ulp = x.ulp();
		equals("0 01111111111 0000000000000000000000000000000000000000000000000000",
				x.toBinaryRepr());
		equals("0 01111111111 0000000000000000000000000000000000000000000000000001",
				(x + ulp).toBinaryRepr());
		equals("0 01111111110 1111111111111111111111111111111111111111111111111110",
				(x - ulp).toBinaryRepr());
		equals(Math.pow(2, -52), ulp);
	}

	function test_subnormal_ulp()
	{
		var x = 2.2250738585072014e-307;
		var ulp = x.ulp();
		equals("0 00000000100 0100000000000000000000000000000000000000000000000000",
				x.toBinaryRepr());
		equals("0 00000000100 0100000000000000000000000000000000000000000000000001",
				(x + ulp).toBinaryRepr());
		equals("0 00000000100 0011111111111111111111111111111111111111111111111111",
				(x - ulp).toBinaryRepr());
		equals(Math.pow(2, 4 - 1023 - 52), ulp);
	}

	function test_subnormal_ulp_argument()
	{
		test_ulp_zero();
	}

	function test_ulp_zero()
	{
		var x = 0;
		var ulp = x.ulp();
		equals("0 00000000000 0000000000000000000000000000000000000000000000000000",
				x.toBinaryRepr());
		equals("0 00000000000 0000000000000000000000000000000000000000000000000001",
				(x + ulp).toBinaryRepr());
		equals("1 00000000000 0000000000000000000000000000000000000000000000000001",
				(x - ulp).toBinaryRepr());
		equals(Math.pow(2, -1022 - 52), ulp);
		equals(MIN_POSITIVE_SUBNORMAL, ulp);
	}

	function spec_ulp_of_non_finite()
	{
		Math.POSITIVE_INFINITY.ulp() == Math.pow(2, 1023 - 52);
		Math.NEGATIVE_INFINITY.ulp() == Math.pow(2, 1023 - 52);
		Math.isNaN(Math.NaN.ulp());
	}
}
