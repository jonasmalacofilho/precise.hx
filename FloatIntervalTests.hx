import utest.Assert.*;
using FloatTools;

class FloatIntervalTests extends utest.Test {
	function test_api()
	{
		pass();
	}

	function test_add_interval()
	{
		var a = FloatInterval.make(0.9, 1.1);
		var b = FloatInterval.fromFloat(3.2);
		var c = a + b;
		var d = b + a;
		trace(1.toBinaryRepr());
		trace(1e-1022.toBinaryRepr());
		equals(4.1, c.lower);
		equals(4.3, c.upper);
		equals(c.lower, d.lower);
		equals(c.upper, d.upper);
		fail("TODO");
	}

	function test_add_float()
	{
		var a = FloatInterval.fromFloat(1);
		var b = FloatInterval.fromFloat(1e-32);
		var c = a + b;
		trace(c.lower, c.upper, c.upper - c.lower, c.lower == c.upper);
		fail("TODO");
	}
}
