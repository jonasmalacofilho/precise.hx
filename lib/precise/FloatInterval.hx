package precise;

import precise.FloatTools.ulp;

/**
	Floating point interval (FPI) arithmetic in double precision

	TODO pow, sqrt, log
	TODO trig functions
	TODO round methods
	TODO null safety

	Knuth (1997).  The art of computer programming, 3rd edition (section 4.2.2.C).

	Patrikalakis, N.; Maekawa, T.; Cho, W (2009).  Shape Interrogation for Computer Aided Design
	and Manufacturing (Section 4.8).
	http://web.mit.edu/hyperbook/Patrikalakis-Maekawa-Cho/node46.html
**/
abstract FloatInterval(FloatIntervalImpl) {
	public var lower(get, never):Float;
	public var upper(get, never):Float;
	public var mean(get, never):Float;
	public var error(get, never):Float;
	public var relerror(get, never):Float;
	var impl(get, never):FloatIntervalImpl;

	inline function new(interval) {
		this = interval;
	}

	inline function get_lower() {
		return this.lo;
	}

	inline function get_upper() {
		return this.up;
	}

	inline function get_mean() {
		return lower + error;
	}

	inline function get_error() {
		return (upper - lower) * .5;
	}

	inline function get_relerror() {
		return error / mean;
	}

	inline function get_impl() {
		return this;
	}

	inline static function makeFast(surelyLower:Float, surelyUpper:Float) {
		return new FloatInterval({lo: surelyLower, up:surelyUpper});
	}

	inline public static function make(lower:Float, upper:Float) {
		return makeFast(lower > upper ? upper : lower,
				lower > upper ? lower : upper);
	}

	inline public function copy() {
		return makeFast(this.lo, this.up);
	}

	@:from inline public static function fromFloat(number:Float) {
		return makeFast(number, number);
	}

	inline public function assign(x:FloatInterval):FloatInterval {
		this.lo = x.lower;
		this.up = x.upper;
		return new FloatInterval(this);
	}

	@:op(a += b) inline function assignAdd(rhs:FloatInterval) {
		return assign(add(rhs));
	}

	@:op(a -= b) inline function assignSub(rhs:FloatInterval) {
		return assign(sub(cast this, rhs));
	}

	@:op(a *= b) inline function assignMult(rhs:FloatInterval) {
		return assign(mult(rhs));
	}

	@:op(a /= b) inline function assignDiv(rhs:FloatInterval) {
		return assign(div(cast this, rhs));
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

	@:op(a + b) @:commutative inline function add(rhs:FloatInterval) {
		var lo = this.lo + rhs.lower;
		var up = this.up + rhs.upper;
		return makeFast(lo - ulp(lo), up + ulp(up));
	}

	@:op(a - b) inline static function sub(lhs:FloatInterval, rhs:FloatInterval) {
		var lo = lhs.lower - rhs.upper;
		var up = lhs.upper - rhs.lower;
		return makeFast(lo - ulp(lo), up + ulp(up));
	}

	@:op(a * b) @:commutative inline function mult(rhs:FloatInterval) {
		var ll = this.lo * rhs.lower;
		var lu = this.lo * rhs.upper;
		var ul = this.up * rhs.lower;
		var uu = this.up * rhs.upper;
		var lo = min(ll, lu, ul, uu);
		var up = max(ll, lu, ul, uu);
		return makeFast(lo - ulp(lo), up + ulp(up));
	}

	@:op(a / b) inline static function div(lhs:FloatInterval, rhs:FloatInterval) {
		if (rhs.lower < 0 && rhs.upper > 0) {
			if ((lhs.lower <= 0 && lhs.upper >= 0) || !Math.isFinite(lhs.lower) ||
					!Math.isFinite(lhs.upper)) {
				return fromFloat(Math.NaN);
			}
			return makeFast(Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY);
		}
		var ll = lhs.lower / rhs.lower;
		var lu = lhs.lower / rhs.upper;
		var ul = lhs.upper / rhs.lower;
		var uu = lhs.upper / rhs.upper;
		var lo = min(ll, lu, ul, uu);
		var up = max(ll, lu, ul, uu);
		return makeFast(lo - ulp(lo), up + ulp(up));
	}

	@:op(-a) inline function neg() {
		return makeFast(-this.up, -this.lo);
	}

	@:op(a < b) inline static function lt(lhs:FloatInterval, rhs:FloatInterval) {
		return lhs.upper < rhs.lower;
	}

	@:op(a <= b) inline static function lte(lhs:FloatInterval, rhs:FloatInterval) {
		return lhs.lower <= rhs.upper;
	}

	@:op(a >= b) inline static function gte(lhs:FloatInterval, rhs:FloatInterval) {
		return lhs.lower >= rhs.upper || lhs.upper >= rhs.lower;
	}

	@:op(a > b) inline static function gt(lhs:FloatInterval, rhs:FloatInterval) {
		return lhs.lower > rhs.upper;
	}

	@:op(a == b) inline static function eq(lhs:FloatInterval, rhs:FloatInterval) {
		return lhs.upper >= rhs.lower && lhs.lower <= rhs.upper;
	}

	@:op(a != b) inline static function neq(lhs:FloatInterval, rhs:FloatInterval) {
		return lhs.lower < rhs.lower || lhs.upper > rhs.upper ||
				rhs.lower < lhs.lower || rhs.upper > lhs.upper;
	}

	@:to public function toString() {
		return '$mean ± $error';
	}

	/**
		Return a human readable representation of the underlying interval
	**/
	public function repr() {
		return lower == upper ? '{$lower}' : '($lower, $upper)';
	}

	static function min(x:Float, y:Float, w:Float, z:Float) {
		var ret = x;
		if (y < ret)
			ret = y;
		if (w < ret)
			ret = w;
		if (z < ret)
			ret = z;
		return ret;
	}

	static function max(x:Float, y:Float, w:Float, z:Float) {
		var ret = x;
		if (y > ret)
			ret = y;
		if (w > ret)
			ret = w;
		if (z > ret)
			ret = z;
		return ret;
	}
}

@:structInit class FloatIntervalImpl {
	public var lo:Float;
	public var up:Float;

	inline public function new(lo, up) {
		this.lo = lo;
		this.up = up;
	}
}
