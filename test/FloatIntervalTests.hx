import precise.FloatInterval;
import precise.FloatTools.ulp;
import utest.Assert.*;
using precise.FloatTools;

class FloatIntervalTests extends utest.Test {
	function test_api()
	{
		pass();
	}

	function spec_properties()
	{
		var a = FloatInterval.make(2, 8);
		a.lower == 2;
		a.upper == 8;
		a.mean == 5;
		a.error == 3;
		a.relerror == 3/5;

		var b = FloatInterval.fromFloat(3.14);
		b.lower == b.upper;
		b.mean == b.lower;
		b.mean == 3.14;
		b.error == 0;
		b.relerror == 0;
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

	function test_mult()
	{
		var a = FloatInterval.fromFloat(1);
		var b = FloatInterval.fromFloat(1e-32);
		var c = a*b;
		var d = b*a;
		var e = a*1e-32;
		var f = 1.*b;
		equals(1e-32 - ulp(1e-32), c.lower);
		equals(1e-32 + ulp(1e-32), c.upper);
		equals(c.lower, d.lower);
		equals(c.upper, d.upper);
		equals(c.lower, e.lower);
		equals(c.upper, e.upper);
		equals(c.lower, f.lower);
		equals(c.upper, f.upper);
	}

	function test_div()
	{
		var a = FloatInterval.fromFloat(1);
		var b = FloatInterval.fromFloat(1e-32);
		var c = a/b;
		var d = b/a;
		var e = a/1e-32;
		var f = 1./b;
		equals(1/1e-32 - ulp(1/1e-32), c.lower);
		equals(1/1e-32 + ulp(1/1e-32), c.upper);
		equals(1e-32 - ulp(1e-32), d.lower);
		equals(1e-32 + ulp(1e-32), d.upper);
		equals(c.lower, e.lower);
		equals(c.upper, e.upper);
		equals(c.lower, f.lower);
		equals(c.upper, f.upper);
	}

	function test_neg()
	{
		var a = FloatInterval.make(2, 8);
		var b = -a;
		equals(-8, b.lower);
		equals(-2, b.upper);
	}
}
