import precise.FloatInterval;
import precise.FloatTools.ulp;
import utest.Assert.*;
using precise.FloatTools;

class FloatIntervalTests extends utest.Test {
	function test_give_an_example()
	{
		/**
			Conversion to radix 2 of Knuth's example of a expectacular failure of the
			distributive law between ⊗ and ⊕
		**/
		var u = 3*Math.pow(2, 44);
		var v = -7;
		var w = -v + Math.pow(2, -49);
		trace('[example] take u = $u, v = $v, w = $w');

		var fp1 = u*v + u*w;
		var fp2 = u*(v + w);
		trace('[example] FP results: u*v + u*w = $fp1 while u*(v + w) = $fp2');

		var ria1 = (u:FloatInterval)*v + u*w;
		var ria2 = (u:FloatInterval)*(v + w);
		trace('[example] but with RIA: u*v + u*w = ${ria1.mean} ± ${ria1.error}');
		trace('[example] (cont.) while u*(v + w) = ${ria2.mean} ± ${ria2.error}');

		// make sure the example is working as intended
		var expected = fp2;
		notEquals(expected, fp1);
		isTrue(ria1.lower <= expected && expected <= ria1.upper);
		isTrue(ria2.lower <= expected && expected <= ria2.upper);
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

		// TODO test rounding of .mean
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

		var i = a*FloatInterval.make(Math.NaN, 1);
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

		var k = a/FloatInterval.make(Math.NaN, 1);
		Math.isNaN(k.lower) == true;
		Math.isNaN(k.upper) == true;

		var l = FloatInterval.fromFloat(Math.NEGATIVE_INFINITY)/Math.POSITIVE_INFINITY;
		Math.isNaN(l.lower) == true;
		Math.isNaN(l.upper) == true;

		var m = FloatInterval.fromFloat(0)/0;
		Math.isNaN(m.lower) == true;
		Math.isNaN(m.upper) == true;
	}

	function spec_div_by_possible_zero()
	{
		var a = 1/FloatInterval.make(-1, 1);
		a.lower == Math.NEGATIVE_INFINITY;  // because of 1/0-
		a.upper == Math.POSITIVE_INFINITY;

		var b = (-1)/FloatInterval.make(-1, 1);
		b.lower == Math.NEGATIVE_INFINITY;
		b.upper == Math.POSITIVE_INFINITY;  // because of -1/0-

		var c = 1/FloatInterval.make(Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY);
		c.lower == Math.NEGATIVE_INFINITY;
		c.upper == Math.POSITIVE_INFINITY;

		var d = FloatInterval.make(-1, 1)/FloatInterval.make(-1, 1);
		Math.isNaN(d.lower) == true;  // must consider 0/0
		Math.isNaN(d.upper) == true;  // must consider 0/0

		var e = Math.POSITIVE_INFINITY/FloatInterval.make(Math.NEGATIVE_INFINITY,
				Math.POSITIVE_INFINITY);
		Math.isNaN(e.lower) == true;  // must consider ∞/±∞
		Math.isNaN(e.upper) == true;  // must consider ∞/±∞

		var f = FloatInterval.make(Math.NaN, 1)/FloatInterval.make(-1, 1);
		Math.isNaN(f.lower) == true;  // NaN divident taints everything
		Math.isNaN(f.upper) == true;  // NaN divident taints everything
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

		(-a + a).mean == 0;  // FIXME
		(a - a).mean == 0;  // FIXME

		// TODO test a/a and a/(-a)
	}

	function spec_ids()
	{
		var a = FloatInterval.make(2, 8);

		(a + 0).lower == a.lower - ulp(a.lower);
		(a + 0).upper == a.upper + ulp(a.upper);

		(a - 0).lower == a.lower - ulp(a.lower);
		(a - 0).upper == a.upper + ulp(a.upper);

		(a*1).lower == a.lower - ulp(a.lower);
		(a*1).upper == a.upper + ulp(a.upper);

		(a/1).lower == a.lower - ulp(a.lower);
		(a/1).upper == a.upper + ulp(a.upper);
	}
}
