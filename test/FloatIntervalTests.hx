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
		Math.isNaN(c.mean) == true;
		c.error == Math.POSITIVE_INFINITY;
		Math.isNaN(c.relerror) == true;

		var d = FloatInterval.fromFloat(Math.NaN);
		Math.isNaN(d.lower) == true;
		Math.isNaN(d.upper) == true;

		var e = FloatInterval.make(8, 2);
		e.lower == 2;
		e.upper == 8;
	}

	function spec_add()
	{
		var a = FloatInterval.fromFloat(1);
		var b = FloatInterval.fromFloat(1e-32);
		var c = a + b;
		var d = b + a;
		var e = a + 1e-32;
		var f = 1 + b;
		c.lower == 1 + 1e-32 - ulp(1 + 1e-32);
		c.upper == 1 + 1e-32 + ulp(1 + 1e-32);
		d.lower == c.lower;
		d.upper == c.upper;
		e.lower == c.lower;
		e.upper == c.upper;
		f.lower == c.lower;
		f.upper == c.upper;

		var g = a + Math.POSITIVE_INFINITY;
		g.lower == Math.POSITIVE_INFINITY;
		g.upper == Math.POSITIVE_INFINITY;

		var h = a + Math.NEGATIVE_INFINITY;
		h.lower == Math.NEGATIVE_INFINITY;
		h.upper == Math.NEGATIVE_INFINITY;

		var i = a + Math.NaN;
		Math.isNaN(i.lower) == true;
		Math.isNaN(i.upper) == true;

		var j = FloatInterval.fromFloat(Math.POSITIVE_INFINITY) + Math.NEGATIVE_INFINITY;
		Math.isNaN(j.lower) == true;
		Math.isNaN(j.upper) == true;
	}

	function spec_sub()
	{
		var a = FloatInterval.fromFloat(1);
		var b = FloatInterval.fromFloat(1e-32);
		var c = a - b;
		var d = b - a;
		var e = a - 1e-32;
		var f = 1 - b;
		c.lower == 1 - 1e-32 - ulp(1 - 1e-32);
		c.upper == 1 - 1e-32 + ulp(1 - 1e-32);
		d.lower == 1e-32 - 1 - ulp(1e-32 - 1);
		d.upper == 1e-32 - 1 + ulp(1e-32 - 1);
		e.lower == c.lower;
		e.upper == c.upper;
		f.lower == c.lower;
		f.upper == c.upper;

		var g = a - Math.POSITIVE_INFINITY;
		g.lower == Math.NEGATIVE_INFINITY;
		g.upper == Math.NEGATIVE_INFINITY;

		var h = a - Math.NEGATIVE_INFINITY;
		h.lower == Math.POSITIVE_INFINITY;
		h.upper == Math.POSITIVE_INFINITY;

		var i = a - Math.NaN;
		Math.isNaN(i.lower) == true;
		Math.isNaN(i.upper) == true;

		var j = FloatInterval.fromFloat(Math.POSITIVE_INFINITY) - Math.POSITIVE_INFINITY;
		Math.isNaN(j.lower) == true;
		Math.isNaN(j.upper) == true;
	}

	function spec_mult()
	{
		var a = FloatInterval.fromFloat(1);
		var b = FloatInterval.fromFloat(1e-32);
		var c = a*b;
		var d = b*a;
		var e = a*1e-32;
		var f = 1*b;
		c.lower == 1e-32 - ulp(1e-32);
		c.upper == 1e-32 + ulp(1e-32);
		d.lower == c.lower;
		d.upper == c.upper;
		e.lower == c.lower;
		e.upper == c.upper;
		f.lower == c.lower;
		f.upper == c.upper;

		var g = a*Math.POSITIVE_INFINITY;
		g.lower == Math.POSITIVE_INFINITY;
		g.upper == Math.POSITIVE_INFINITY;

		var h = a*Math.NEGATIVE_INFINITY;
		h.lower == Math.NEGATIVE_INFINITY;
		h.upper == Math.NEGATIVE_INFINITY;

		var i = a*Math.NaN;
		Math.isNaN(i.lower) == true;
		Math.isNaN(i.upper) == true;

		var j = FloatInterval.fromFloat(0)*Math.POSITIVE_INFINITY;
		Math.isNaN(j.lower) == true;
		Math.isNaN(j.upper) == true;
	}

	function spec_div()
	{
		var a = FloatInterval.fromFloat(1);
		var b = FloatInterval.fromFloat(1e-32);
		var c = a/b;
		var d = b/a;
		var e = a/1e-32;
		var f = 1/b;
		c.lower == 1/1e-32 - ulp(1/1e-32);
		c.upper == 1/1e-32 + ulp(1/1e-32);
		d.lower == 1e-32 - ulp(1e-32);
		d.upper == 1e-32 + ulp(1e-32);
		e.lower == c.lower;
		e.upper == c.upper;
		f.lower == c.lower;
		f.upper == c.upper;

		var g = a/Math.POSITIVE_INFINITY;
		g.lower == -ulp(0);
		g.upper == ulp(0);

		var h = a/Math.NEGATIVE_INFINITY;
		g.lower == -ulp(0);
		g.upper == ulp(0);

		var i = Math.POSITIVE_INFINITY/a;
		i.lower == Math.POSITIVE_INFINITY;
		i.upper == Math.POSITIVE_INFINITY;

		var j = Math.NEGATIVE_INFINITY/a;
		j.lower == Math.NEGATIVE_INFINITY;
		j.upper == Math.NEGATIVE_INFINITY;

		var k = a/Math.NaN;
		Math.isNaN(k.lower) == true;
		Math.isNaN(k.upper) == true;

		var m = FloatInterval.fromFloat(0)/0;
		Math.isNaN(m.lower) == true;
		Math.isNaN(m.upper) == true;
	}

	function spec_neg()
	{
		var a = FloatInterval.make(2, 8);
		var b = -a;
		b.lower == -8;
		b.upper == -2;

		var c = -FloatInterval.fromFloat(Math.POSITIVE_INFINITY);
		c.lower == Math.NEGATIVE_INFINITY;
		c.upper == Math.NEGATIVE_INFINITY;

		var d = -FloatInterval.fromFloat(Math.NEGATIVE_INFINITY);
		d.lower == Math.POSITIVE_INFINITY;
		d.upper == Math.POSITIVE_INFINITY;

		var e = -FloatInterval.fromFloat(Math.NaN);
		Math.isNaN(e.lower) == true;
		Math.isNaN(e.upper) == true;
	}
}
