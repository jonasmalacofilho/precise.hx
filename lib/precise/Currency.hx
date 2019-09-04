package precise;

@:forward(upper, lower, mean, error, relerror, repr)
abstract Currency(FloatInterval) to FloatInterval {
	inline function new(value) {
		this = value;
	}

	public static function parse(text:String) {
		var float = Std.parseFloat(text);
		if (!Math.isFinite(float))
			throw 'Currency only defined for finite numbers, but argument $float';
		var ulp = FloatTools.ulp(float);
		return new Currency(FloatInterval.make(float - ulp, float + ulp));
	}

	@:from public static function fromFloat(number:Float) {
		return new Currency(number);
	}

	@:op(a + b) @:commutative function add(rhs:Currency) {
		var res = new Currency(this + rhs);
		if (CurrentFlags.max_error != null && res.error > CurrentFlags.max_error)
			CurrentFlags.max_error_handler(res);
		return res;
	}

	@:op(a - b) static function sub(lhs:Currency, rhs:Currency) {
		var res = new Currency((lhs : FloatInterval) - rhs);
		if (CurrentFlags.max_error != null && res.error > CurrentFlags.max_error)
			CurrentFlags.max_error_handler(res);
		return res;
	}

	@:op(a * b) function mult(rhs:FloatInterval) {
		var res = new Currency(this * rhs);
		if (CurrentFlags.max_error != null && res.error > CurrentFlags.max_error)
			CurrentFlags.max_error_handler(res);
		return res;
	}

	@:op(a / b) function div(rhs:FloatInterval) {
		var res = new Currency(this / rhs);
		if (CurrentFlags.max_error != null && res.error > CurrentFlags.max_error)
			CurrentFlags.max_error_handler(res);
		return res;
	}

	@:to public inline function toString() {
		return Std.string(this.mean);  // FIXME round
	}
}

class CurrentFlags {
	public static var max_error:Null<Float> = 0.0005;
	public static var max_error_handler = default_handler;

	// TODO receive op and args
	static function default_handler(value:Currency, ?pos:haxe.PosInfos) {
		throw 'Error bound exceeds threadshold; FPI = ${value.repr()}';
	}
}
