import precise.FloatInterval;
import precise.FloatTools.ulp;
import utest.Assert.*;
using precise.FloatTools;

class FloatIntervalTests extends utest.Test {
	static inline var MAX_FINITE = 1.7976931348623157e308; // 2^1023 × (1 + (1 - 2^-52))

	function test_give_an_example() {
		/**
			Conversion to radix 2 of Knuth's example of a spectacular failure of the
			distributive law between ⊗ and ⊕
		**/
		var u = 3 * Math.pow(2, 44);
		var v = -7;
		var w = -v + Math.pow(2, -49);
		trace('[example] take u = $u, v = $v, w = $w');

		var fp1 = u * v + u * w;
		var fp2 = u * (v + w);
		trace('[example] FP results: u * v + u * w = $fp1 while u * (v + w) = $fp2');

		var ria1 = (u : FloatInterval) * v + u * w;
		var ria2 = (u : FloatInterval) * (v + w);
		trace('[example] but with FPI: u * v + u * w = $ria1');
		trace('[example] (cont.) while u * (v + w) = $ria2');

		// make sure the example is working as intended
		var expected = fp2;
		notEquals(expected, fp1);
		isTrue(ria1.lower <= expected && expected <= ria1.upper);
		isTrue(ria2.lower <= expected && expected <= ria2.upper);
	}

	function spec_properties() {
		var a = FloatInterval.make(2, 8);
		a.lower == 2;
		a.upper == 8;
		a.mean == 5;
		a.error == 3;
		a.relerror == 3 / 5;

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

		FloatInterval.make(1, 1 + 1 * ulp(1)).mean == 1 + 0 * ulp(1);
		FloatInterval.make(1, 1 + 3 * ulp(1)).mean == 1 + 2 * ulp(1);
		FloatInterval.make(1, 1 + 5 * ulp(1)).mean == 1 + 2 * ulp(1);
		FloatInterval.make(1, 1 + 7 * ulp(1)).mean == 1 + 4 * ulp(1);
		FloatInterval.make(1, 1 + 9 * ulp(1)).mean == 1 + 4 * ulp(1);

		var m = MAX_FINITE;
		FloatInterval.make(m - 5 * ulp(m), m).mean == m - 3 * ulp(m);  // pot. overflow
		FloatInterval.make(-ulp(0), ulp(0)).mean == 0;  // pot. underflow
	}

	function spec_add() {
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

		var k = FloatInterval.make(6, 8) + FloatInterval.make(2, 4);
		k.lower == 8 - ulp(8);
		k.upper == 12 + ulp(12);
	}

	@:access(precise.FloatInterval.impl)
	function spec_add_derivates()
	{
		var one = FloatInterval.fromFloat(1);

		var a = one.copy();
		var a0impl = a.impl;
		var ares = a += 1;
		ares.lower == (one + 1).lower;
		ares.upper == (one + 1).upper;
		a.impl == a0impl;

		var b = one.copy();
		var b0impl = b.impl;
		var bres = b++;
		bres.lower == one.lower;
		bres.upper == one.upper;
		b.impl == b0impl;
		b.lower == (one + 1).lower;
		b.upper == (one + 1).upper;

		var c = one.copy();
		var c0impl = c.impl;
		var cres = ++c;
		cres.lower == (one + 1).lower;
		cres.upper == (one + 1).upper;
		c.impl == c0impl;
	}

	function spec_sub() {
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

		var k = FloatInterval.make(6, 8) - FloatInterval.make(2, 4);
		k.lower == 2 - ulp(2);
		k.upper == 6 + ulp(6);
	}

	@:access(precise.FloatInterval.impl)
	function spec_sub_derivates()
	{
		var one = FloatInterval.fromFloat(1);

		var a = one.copy();
		var a0impl = a.impl;
		var ares = a -= 1;
		ares.lower == (one - 1).lower;
		ares.upper == (one - 1).upper;
		a.impl == a0impl;

		var b = one.copy();
		var b0impl = b.impl;
		var bres = b--;
		bres.lower == one.lower;
		bres.upper == one.upper;
		b.impl == b0impl;
		b.lower == (one - 1).lower;
		b.upper == (one - 1).upper;

		var c = one.copy();
		var c0impl = c.impl;
		var cres = --c;
		cres.lower == (one - 1).lower;
		cres.upper == (one - 1).upper;
		c.impl == c0impl;
	}

	function spec_mult() {
		var a = FloatInterval.fromFloat(1);
		var b = FloatInterval.fromFloat(1e-32);
		var c = a * b;
		var d = b * a;
		var e = a * 1e-32;
		var f = 1 * b;
		c.lower == 1e-32 - ulp(1e-32);
		c.upper == 1e-32 + ulp(1e-32);
		d.lower == c.lower;
		d.upper == c.upper;
		e.lower == c.lower;
		e.upper == c.upper;
		f.lower == c.lower;
		f.upper == c.upper;

		var g = a * Math.POSITIVE_INFINITY;
		g.lower == Math.POSITIVE_INFINITY;
		g.upper == Math.POSITIVE_INFINITY;

		var h = a * Math.NEGATIVE_INFINITY;
		h.lower == Math.NEGATIVE_INFINITY;
		h.upper == Math.NEGATIVE_INFINITY;

		var i = a * FloatInterval.make(Math.NaN, 1);
		Math.isNaN(i.lower) == true;
		Math.isNaN(i.upper) == true;

		var j = FloatInterval.fromFloat(0) * Math.POSITIVE_INFINITY;
		Math.isNaN(j.lower) == true;
		Math.isNaN(j.upper) == true;

		var k = FloatInterval.make(-8, -6) * FloatInterval.make(-2, 4);
		k.lower == -32 - ulp(32);
		k.upper == 16 + ulp(16);
	}

	@:access(precise.FloatInterval.impl)
	function spec_compound_mult()
	{
		var one = FloatInterval.fromFloat(1);

		var a = one.copy();
		var a0impl = a.impl;
		var ares = a *= 1;
		ares.lower == (one * 1).lower;
		ares.upper == (one * 1).upper;
		a.impl == a0impl;
	}

	function spec_div() {
		var a = FloatInterval.fromFloat(1);
		var b = FloatInterval.fromFloat(1e-32);
		var c = a / b;
		var d = b / a;
		var e = a / 1e-32;
		var f = 1 / b;
		c.lower == 1 / 1e-32 - ulp(1 / 1e-32);
		c.upper == 1 / 1e-32 + ulp(1 / 1e-32);
		d.lower == 1e-32 - ulp(1e-32);
		d.upper == 1e-32 + ulp(1e-32);
		e.lower == c.lower;
		e.upper == c.upper;
		f.lower == c.lower;
		f.upper == c.upper;

		var g = a / Math.POSITIVE_INFINITY;
		g.lower == -ulp(0);
		g.upper == ulp(0);

		var h = a / Math.NEGATIVE_INFINITY;
		g.lower == -ulp(0);
		g.upper == ulp(0);

		var i = Math.POSITIVE_INFINITY / a;
		i.lower == Math.POSITIVE_INFINITY;
		i.upper == Math.POSITIVE_INFINITY;

		var j = Math.NEGATIVE_INFINITY / a;
		j.lower == Math.NEGATIVE_INFINITY;
		j.upper == Math.NEGATIVE_INFINITY;

		var k = a / FloatInterval.make(Math.NaN, 1);
		Math.isNaN(k.lower) == true;
		Math.isNaN(k.upper) == true;

		var l = FloatInterval.fromFloat(Math.NEGATIVE_INFINITY) / Math.POSITIVE_INFINITY;
		Math.isNaN(l.lower) == true;
		Math.isNaN(l.upper) == true;

		var m = FloatInterval.fromFloat(0) / 0;
		Math.isNaN(m.lower) == true;
		Math.isNaN(m.upper) == true;

		var n = FloatInterval.make(-8, 6) / FloatInterval.make(-4, -2);
		n.lower == -3 - ulp(3);
		n.upper == 4 + ulp(4);
	}

	@:access(precise.FloatInterval.impl)
	function spec_compound_div()
	{
		var one = FloatInterval.fromFloat(1);

		var a = one.copy();
		var a0impl = a.impl;
		var ares = a /= 1;
		ares.lower == (one / 1).lower;
		ares.upper == (one / 1).upper;
		a.impl == a0impl;
	}

	function spec_div_by_possible_zero() {
		var a = 1 / FloatInterval.make(-1, 1);
		a.lower == Math.NEGATIVE_INFINITY; // because of 1/0-
		a.upper == Math.POSITIVE_INFINITY;

		var b = (-1) / FloatInterval.make(-1, 1);
		b.lower == Math.NEGATIVE_INFINITY;
		b.upper == Math.POSITIVE_INFINITY; // because of -1/0-

		var c = 1 / FloatInterval.make(Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY);
		c.lower == Math.NEGATIVE_INFINITY;
		c.upper == Math.POSITIVE_INFINITY;

		var d = FloatInterval.make(-1, 1) / FloatInterval.make(-1, 1);
		Math.isNaN(d.lower) == true; // must consider 0/0
		Math.isNaN(d.upper) == true; // must consider 0/0

		var e = Math.POSITIVE_INFINITY /
				FloatInterval.make(Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY);
		Math.isNaN(e.lower) == true; // must consider ∞/±∞
		Math.isNaN(e.upper) == true; // must consider ∞/±∞

		var f = FloatInterval.make(Math.NaN, 1) / FloatInterval.make(-1, 1);
		Math.isNaN(f.lower) == true; // NaN dividend taints everything
		Math.isNaN(f.upper) == true; // NaN dividend taints everything
	}

	function spec_neg() {
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

		var f = FloatInterval.make(8 - ulp(8), 8 + ulp(8));
		(-f + f).mean == 0;
		(-f + f).error == 2 * ulp(8) + ulp(2 * ulp(8));
		(f - f).mean == (-f + f).mean;
		(f - f).error == (-f + f).error;
	}

	function spec_ids() {
		var a = FloatInterval.make(2, 8);

		(a + 0).lower == a.lower - ulp(a.lower);
		(a + 0).upper == a.upper + ulp(a.upper);

		(a - 0).lower == a.lower - ulp(a.lower);
		(a - 0).upper == a.upper + ulp(a.upper);

		(a * 1).lower == a.lower - ulp(a.lower);
		(a * 1).upper == a.upper + ulp(a.upper);

		(a / 1).lower == a.lower - ulp(a.lower);
		(a / 1).upper == a.upper + ulp(a.upper);
	}

	function spec_comparisons() {
		!(FloatInterval.make(3, 4) < FloatInterval.make(1, 2));
		!(FloatInterval.make(3, 4) <= FloatInterval.make(1, 2));
		!(FloatInterval.make(3, 4) == FloatInterval.make(1, 2));
		FloatInterval.make(3, 4) >= FloatInterval.make(1, 2);
		FloatInterval.make(3, 4) > FloatInterval.make(1, 2);
		FloatInterval.make(3, 4) != FloatInterval.make(1, 2);

		!(FloatInterval.make(3, 4) < FloatInterval.make(2, 3));
		FloatInterval.make(3, 4) <= FloatInterval.make(2, 3);
		FloatInterval.make(3, 4) == FloatInterval.make(2, 3);
		FloatInterval.make(3, 4) >= FloatInterval.make(2, 3);
		!(FloatInterval.make(3, 4) > FloatInterval.make(2, 3));
		!(FloatInterval.make(3, 4) != FloatInterval.make(2, 3));

		FloatInterval.make(3, 4) == FloatInterval.make(3, 4);
		!(FloatInterval.make(3, 4) != FloatInterval.make(3, 4));
		FloatInterval.make(3 + .1, 4 - .1) == FloatInterval.make(3, 4);
		!(FloatInterval.make(3 + .1, 4 - .1) != FloatInterval.make(3, 4));
		FloatInterval.make(3, 4) == FloatInterval.make(3 + .1, 4 - .1);
		!(FloatInterval.make(3, 4) != FloatInterval.make(3 + .1, 4 - .1));

		!(FloatInterval.make(3, 4) < FloatInterval.make(4, 5));
		FloatInterval.make(3, 4) <= FloatInterval.make(4, 5);
		FloatInterval.make(3, 4) == FloatInterval.make(4, 5);
		FloatInterval.make(3, 4) >= FloatInterval.make(4, 5);
		!(FloatInterval.make(3, 4) > FloatInterval.make(4, 5));
		!(FloatInterval.make(3, 4) != FloatInterval.make(4, 5));

#if neko
	}

	/**
		Since all FloatInterval operations are inlined to avoid allocations, the stack size
		on this function can get quite large, at least as far as neko is concerned
		(MAX_STACK_PER_FUNCTION is 128).

		Simply to avoid generating a invalid neko module because of this, split the function
		into several parts that each fit within the Neko stack size limit.
	**/
	function spec_comparisons_part2() {
#end
		FloatInterval.make(3, 4) < FloatInterval.make(5, 6);
		FloatInterval.make(3, 4) <= FloatInterval.make(5, 6);
		!(FloatInterval.make(3, 4) == FloatInterval.make(5, 6));
		!(FloatInterval.make(3, 4) >= FloatInterval.make(5, 6));
		!(FloatInterval.make(3, 4) > FloatInterval.make(5, 6));
		FloatInterval.make(3, 4) != FloatInterval.make(5, 6);

		!(FloatInterval.fromFloat(3) < 2);
		!(FloatInterval.fromFloat(3) <= 2);
		!(FloatInterval.fromFloat(3) == 2);
		FloatInterval.fromFloat(3) >= 2;
		FloatInterval.fromFloat(3) > 2;
		FloatInterval.fromFloat(3) != 2;

		!(FloatInterval.fromFloat(3) < 3);
		FloatInterval.fromFloat(3) <= 3;
		FloatInterval.fromFloat(3) == 3;
		FloatInterval.fromFloat(3) >= 3;
		!(FloatInterval.fromFloat(3) > 3);
		!(FloatInterval.fromFloat(3) != 3);

		FloatInterval.fromFloat(3) < 4;
		FloatInterval.fromFloat(3) <= 4;
		!(FloatInterval.fromFloat(3) == 4);
		!(FloatInterval.fromFloat(3) >= 4);
		!(FloatInterval.fromFloat(3) > 4);
		FloatInterval.fromFloat(3) != 4;

#if neko
	}

	// see comment for spec_comparisons_part2
	function spec_comparisons_part3() {
#end

		!(FloatInterval.make(3, 4) < 2);
		!(FloatInterval.make(3, 4) <= 2);
		!(FloatInterval.make(3, 4) == 2);
		FloatInterval.make(3, 4) >= 2;
		FloatInterval.make(3, 4) > 2;
		FloatInterval.make(3, 4) != 2;

		!(FloatInterval.make(3, 4) < 3);
		FloatInterval.make(3, 4) <= 3;
		FloatInterval.make(3, 4) == 3;
		FloatInterval.make(3, 4) >= 3;
		!(FloatInterval.make(3, 4) > 3);
		!(FloatInterval.make(3, 4) != 3);

		!(FloatInterval.make(3, 4) < 4);
		FloatInterval.make(3, 4) <= 4;
		FloatInterval.make(3, 4) == 4;
		FloatInterval.make(3, 4) >= 4;
		!(FloatInterval.make(3, 4) > 4);
		!(FloatInterval.make(3, 4) != 4);

		FloatInterval.make(3, 4) < 5;
		FloatInterval.make(3, 4) <= 5;
		!(FloatInterval.make(3, 4) == 5);
		!(FloatInterval.make(3, 4) >= 5);
		!(FloatInterval.make(3, 4) > 5);
		FloatInterval.make(3, 4) != 5;
	}

	function spec_comparison_properties() {
		var exact = [2, 3, 4, 5];
		var fpis = [
			for (lower in exact)
				for (upper in exact)
					if (lower <= upper)
						FloatInterval.make(lower, upper)
		];

		// the set of comparisons is coherent
		for (lhs in fpis) {
			for (rhs in fpis) {
				isTrue((lhs <= rhs) == (lhs < rhs || lhs == rhs),
						'expected lte == lt || eq (lhs=$lhs, rhs=$rhs)');
				isTrue((lhs >= rhs) == (lhs > rhs || lhs == rhs),
						'expected gte == gt || eq (lhs=$lhs, rhs=$rhs)');
				isTrue((lhs != rhs) == !(lhs == rhs),
						'expected nte == !eq (lhs=$lhs, rhs=$rhs)');
			}
		}
	}

	/**
		Haxe doesn't cmurrently support overloading the assign – @:op(a = b) –
		operator.  Thus we're always working on references.

		This has both semantic and efficiency implications.  This example shows the
		effects of both, and also allows the inspection of the AST (if its dump has
		been enabled).

		It will have to be updated once @:op(a = b) is allowed and used in
		FloatInterval.
	**/
	@:access(precise.FloatInterval.impl)
	function test_assign_semantics() {
		var a = (1:FloatInterval), a0impl = a.impl;
		var b = a;
		var c = a.copy();
		a += 3;
		equals(a0impl, a.impl);
		equals(a0impl, b.impl); // b still points to a
		notEquals(a0impl, c.impl);

		var d = (5:FloatInterval), d0impl = d.impl;
		var e = (7:FloatInterval), e0impl = e.impl;
		for (i in 0...1000) { // hack: prevent this loop from unrolling
			d = d*d + i;
			e.assign(e*e - i);
			if (i > 5)
				break;
		}
		notEquals(d0impl, d); // updating d caused allocations
		equals(e0impl, e);

		pass('[hack] don\'t optmize away, ${a.error + d.error + e.error}');
	}
}
