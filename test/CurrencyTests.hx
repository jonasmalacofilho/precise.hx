import precise.Currency;
import utest.Assert.*;

class CurrencyTests extends utest.Test {
	function test_give_an_example() {
		var min = Currency.parse("998.00");
		trace('[example] add: ${(min + 18).mean} ± ${(min + 18).error}');
		trace('[example] sub: ${(min - 18).mean} ± ${(min - 18).error}');
		trace('[example] mul: ${(min * 18).mean} ± ${(min * 18).error}');
		trace('[example] div: ${(min / 18).mean} ± ${(min / 18).error}');
		pass();
	}

	function test_default_max_error() {
		// TODO save previous CurrencyFlags
		// TODO restore default CurrencyFlags
		var min = Currency.parse("998.00");
		var interest = 1.005;
		var sum = min;
		var i = 0;
		try {
			while (true) {
				sum = sum * interest + min;
				i++;
			}
		} catch (err:Dynamic) {
			trace('[info] survived $i iterations; last sum = ${sum.mean} ± ${sum.error}');
			trace('[info] error was: $err');
		}
		isTrue(i > 1e3);
		isTrue(sum.mean > 1e6);
		// TODO restore previous CurrencyFlags
	}
}
