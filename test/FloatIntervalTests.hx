import precise.FloatInterval;
import precise.FloatTools.ulp;
import utest.Assert.*;

class FloatIntervalTests extends utest.Test {
	function test_api()
	{
		pass();
	}

	function test_properties()
	{
		var a = FloatInterval.make(2, 8);
		equals(2, a.lower);
		equals(8, a.upper);
		equals(5, a.mean);
		equals(3, a.error);
		equals(3/5, a.relerror);
	}

	function test_add()
	{
		var a = FloatInterval.fromFloat(1);
		var b = FloatInterval.fromFloat(1e-32);
		var c = a + b;
		var d = b + a;
		var e = a + 1e-32;
		var f = 1. + b;
		equals(1 + 1e-32 - ulp(1 + 1e-32), c.lower);
		equals(1 + 1e-32 + ulp(1 + 1e-32), c.upper);
		equals(c.lower, d.lower);
		equals(c.upper, d.upper);
		equals(c.lower, e.lower);
		equals(c.upper, e.upper);
		equals(c.lower, f.lower);
		equals(c.upper, f.upper);
	}

	function test_sub()
	{
		var a = FloatInterval.fromFloat(1);
		var b = FloatInterval.fromFloat(1e-32);
		var c = a - b;
		var d = b - a;
		var e = a - 1e-32;
		var f = 1. - b;
		equals(1 - 1e-32 - ulp(1 - 1e-32), c.lower);
		equals(1 - 1e-32 + ulp(1 - 1e-32), c.upper);
		equals(1e-32 - 1 - ulp(1e-32 - 1), d.lower);
		equals(1e-32 - 1 + ulp(1e-32 - 1), d.upper);
		equals(c.lower, e.lower);
		equals(c.upper, e.upper);
		equals(c.lower, f.lower);
		equals(c.upper, f.upper);
	}
}
