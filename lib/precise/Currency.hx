package precise;

@:forward(upper, lower, mean, error, relerror, repr)
abstract Currency(FloatInterval) to FloatInterval {
	inline function new(value) {
		this = value;
	}

	inline public function copy() {
		return new Currency(this.copy());
	}

	public static inline function parse(text:String) {
		var float = Std.parseFloat(text);
		if (!Math.isFinite(float))
			throw 'Currency only defined for finite numbers, but argument $float';
		var ulp = FloatTools.ulp(float);
		return new Currency(@:privateAccess FloatInterval.makeFast(float - ulp, float + ulp));
	}

	@:from public static inline function fromFloat(number:Float) {
		return new Currency(number);
	}

	inline public function assign(x:FloatInterval):FloatInterval {
		return this.assign(x);
	}

	@:op(a += b) inline function assignAdd(rhs:Currency) {
		return assign(add(rhs));
	}

	@:op(a -= b) inline function assignSub(rhs:Currency) {
		return assign(sub(cast this, rhs));
	}

	@:op(a *= b) inline function assignMult(rhs:FloatInterval) {
		return assign(mult(rhs));
	}

	@:op(a /= b) inline function assignDiv(rhs:FloatInterval) {
		return assign(div(rhs));
	}

	@:op(++a) inline function preIncrement() {
		return assignAdd(1);
	}

	@:op(a++) inline function postIncrement() {
		var tmp = copy();
		preIncrement();
		return tmp;
	}

	@:op(--a) inline function preDecrement() {
		return assignSub(1);
	}

	@:op(a--) inline function postDecrement() {
		var tmp = copy();
		preDecrement();
		return tmp;
	}

	@:op(a + b) @:commutative inline function add(rhs:Currency) {
		return checkAndCast(this + rhs);
	}

	@:op(a - b) static inline function sub(lhs:Currency, rhs:Currency) {
		return checkAndCast((lhs:FloatInterval) - rhs);
	}

	@:op(a * b) inline function mult(rhs:FloatInterval) {
		return checkAndCast(this * rhs);
	}

	@:op(a / b) inline function div(rhs:FloatInterval) {
		return checkAndCast(this / rhs);
	}

	@:op(-a) inline function neg() {
		return new Currency(-this);
	}

	@:op(a < b) static function lt(lhs:Currency, rhs:Currency):Bool;

	@:op(a <= b) static function lte(lhs:Currency, rhs:Currency):Bool;

	@:op(a >= b) static function gte(lhs:Currency, rhs:Currency):Bool;

	@:op(a > b) static function gt(lhs:Currency, rhs:Currency):Bool;

	@:op(a == b) static function eq(lhs:Currency, rhs:Currency):Bool;

	@:op(a != b) static function neq(lhs:Currency, rhs:Currency):Bool;

	@:to public inline function toString() {
		return Std.string(this.mean);
	}

	/**
		Check that FPI error is bellow threshold and cast the result

		This is optimized for the case where the error is indeed bellow the threshold, or
		that this check has been disabled.  Because the handler will be overriden at runtime
		and can't be inlined, it will receive a copy of the value.  This allows the fast
		path to avoid allocations.
	**/
	static inline function checkAndCast(x:FloatInterval, ?pos:haxe.PosInfos) {
		if (CurrentFlags.max_error != null && x.error > CurrentFlags.max_error)
			CurrentFlags.max_error_handler(new Currency(x.copy()), pos);
		return new Currency(x);
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
