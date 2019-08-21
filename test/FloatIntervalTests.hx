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

		var c = FloatInterval.make(Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY);
		c.lower == Math.NEGATIVE_INFINITY;
		c.upper == Math.POSITIVE_INFINITY;
		Math.isNaN(c.mean);
		Math.isNaN(c.error);
		Math.isNaN(c.relerror);

		var d = FloatInterval.fromFloat(Math.NaN);
		Math.isNaN(c.lower);
		Math.isNaN(c.upper);

		var e = FloatInterval.make(8, 2);
		a.lower == 2;
		a.upper == 8;
		a.mean == 5;
		a.error == 3;
		a.relerror == 3/5;
	}

	function test_add()
	{
		var a = FloatInterval.fromFloat(1);
		var b = FloatInterval.fromFloat(1e-32);
		var c = a + b;
		var d = b + a;
		var e = a + 1e-32;
		var f = 1 + b;
		equals(1 + 1e-32 - ulp(1 + 1e-32), c.lower);
		equals(1 + 1e-32 + ulp(1 + 1e-32), c.upper);
		equals(c.lower, d.lower);
		equals(c.upper, d.upper);
		equals(c.lower, e.lower);
		equals(c.upper, e.upper);
		equals(c.lower, f.lower);
		equals(c.upper, f.upper);

		var g = a + Math.POSITIVE_INFINITY;
		equals(Math.POSITIVE_INFINITY, g.lower);
		equals(Math.POSITIVE_INFINITY, g.upper);

		var h = a + Math.NEGATIVE_INFINITY;
		equals(Math.NEGATIVE_INFINITY, h.lower);
		equals(Math.NEGATIVE_INFINITY, h.upper);

		var i = a + Math.NaN;
		isTrue(Math.isNaN(i.lower));
		isTrue(Math.isNaN(i.upper));

		var j = FloatInterval.fromFloat(Math.POSITIVE_INFINITY) + Math.NEGATIVE_INFINITY;
		isTrue(Math.isNaN(j.lower));
		isTrue(Math.isNaN(j.upper));
	}

	function test_sub()
	{
		var a = FloatInterval.fromFloat(1);
		var b = FloatInterval.fromFloat(1e-32);
		var c = a - b;
		var d = b - a;
		var e = a - 1e-32;
		var f = 1 - b;
		equals(1 - 1e-32 - ulp(1 - 1e-32), c.lower);
		equals(1 - 1e-32 + ulp(1 - 1e-32), c.upper);
		equals(1e-32 - 1 - ulp(1e-32 - 1), d.lower);
		equals(1e-32 - 1 + ulp(1e-32 - 1), d.upper);
		equals(c.lower, e.lower);
		equals(c.upper, e.upper);
		equals(c.lower, f.lower);
		equals(c.upper, f.upper);

		var g = a - Math.POSITIVE_INFINITY;
		equals(Math.NEGATIVE_INFINITY, g.lower);
		equals(Math.NEGATIVE_INFINITY, g.upper);

		var h = a - Math.NEGATIVE_INFINITY;
		equals(Math.POSITIVE_INFINITY, h.lower);
		equals(Math.POSITIVE_INFINITY, h.upper);

		var i = a - Math.NaN;
		isTrue(Math.isNaN(i.lower));
		isTrue(Math.isNaN(i.upper));

		var j = FloatInterval.fromFloat(Math.POSITIVE_INFINITY) - Math.POSITIVE_INFINITY;
		isTrue(Math.isNaN(j.lower));
		isTrue(Math.isNaN(j.upper));
	}

	function test_mult()
	{
		var a = FloatInterval.fromFloat(1);
		var b = FloatInterval.fromFloat(1e-32);
		var c = a*b;
		var d = b*a;
		var e = a*1e-32;
		var f = 1*b;
		equals(1e-32 - ulp(1e-32), c.lower);
		equals(1e-32 + ulp(1e-32), c.upper);
		equals(c.lower, d.lower);
		equals(c.upper, d.upper);
		equals(c.lower, e.lower);
		equals(c.upper, e.upper);
		equals(c.lower, f.lower);
		equals(c.upper, f.upper);

		var g = a*Math.POSITIVE_INFINITY;
		equals(Math.POSITIVE_INFINITY, g.lower);
		equals(Math.POSITIVE_INFINITY, g.upper);

		var h = a*Math.NEGATIVE_INFINITY;
		equals(Math.NEGATIVE_INFINITY, h.lower);
		equals(Math.NEGATIVE_INFINITY, h.upper);

		var i = a*Math.NaN;
		isTrue(Math.isNaN(i.lower));
		isTrue(Math.isNaN(i.upper));

		var j = FloatInterval.fromFloat(0)*Math.POSITIVE_INFINITY;
		isTrue(Math.isNaN(j.lower));
		isTrue(Math.isNaN(j.upper));
	}

	function test_div()
	{
		var a = FloatInterval.fromFloat(1);
		var b = FloatInterval.fromFloat(1e-32);
		var c = a/b;
		var d = b/a;
		var e = a/1e-32;
		var f = 1/b;
		equals(1/1e-32 - ulp(1/1e-32), c.lower);
		equals(1/1e-32 + ulp(1/1e-32), c.upper);
		equals(1e-32 - ulp(1e-32), d.lower);
		equals(1e-32 + ulp(1e-32), d.upper);
		equals(c.lower, e.lower);
		equals(c.upper, e.upper);
		equals(c.lower, f.lower);
		equals(c.upper, f.upper);

		var g = a/Math.POSITIVE_INFINITY;
		equals(-ulp(0), g.lower);
		equals(ulp(0), g.upper);

		var h = a/Math.NEGATIVE_INFINITY;
		equals(-ulp(0), g.lower);
		equals(ulp(0), g.upper);

		var i = Math.POSITIVE_INFINITY/a;
		equals(Math.POSITIVE_INFINITY, i.lower);
		equals(Math.POSITIVE_INFINITY, i.upper);

		var j = Math.NEGATIVE_INFINITY/a;
		equals(Math.NEGATIVE_INFINITY, j.lower);
		equals(Math.NEGATIVE_INFINITY, j.upper);

		var k = a/Math.NaN;
		isTrue(Math.isNaN(k.lower));
		isTrue(Math.isNaN(k.upper));

		var m = FloatInterval.fromFloat(0)/0;
		isTrue(Math.isNaN(m.lower));
		isTrue(Math.isNaN(m.upper));
	}

	function test_neg()
	{
		var a = FloatInterval.make(2, 8);
		var b = -a;
		equals(-8, b.lower);
		equals(-2, b.upper);

		var c = -FloatInterval.fromFloat(Math.POSITIVE_INFINITY);
		equals(Math.NEGATIVE_INFINITY, c.lower);
		equals(Math.NEGATIVE_INFINITY, c.upper);

		var d = -FloatInterval.fromFloat(Math.NEGATIVE_INFINITY);
		equals(Math.POSITIVE_INFINITY, d.lower);
		equals(Math.POSITIVE_INFINITY, d.upper);

		var e = -FloatInterval.fromFloat(Math.NaN);
		isTrue(Math.isNaN(e.lower));
		isTrue(Math.isNaN(e.upper));
	}
}
