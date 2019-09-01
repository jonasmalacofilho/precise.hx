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

	inline function assignInternal(surelyLower:Float, surelyUpper:Float) {
		this.lo = surelyLower;
		this.up = surelyUpper;
		return new FloatInterval(this);
	}

	inline public function assign(x:FloatInterval):FloatInterval {
		return assignInternal(x.lower, x.upper);
	}

	@:op(a += b) inline public function assignAdd(rhs:FloatInterval) {
		var lo = this.lo + rhs.lower;
		var up = this.up + rhs.upper;
		return assignInternal(lo - ulp(lo), up + ulp(up));
	}

	@:op(a -= b) inline public function assignSub(rhs:FloatInterval) {
		var lo = this.lo - rhs.upper;
		var up = this.up - rhs.lower;
		return assignInternal(lo - ulp(lo), up + ulp(up));
	}

	@:op(a *= b) inline public function assignMult(rhs:FloatInterval) {
		var ll = this.lo * rhs.lower;
		var lu = this.lo * rhs.upper;
		var ul = this.up * rhs.lower;
		var uu = this.up * rhs.upper;
		var lo = min(ll, lu, ul, uu);
		var up = max(ll, lu, ul, uu);
		return assignInternal(lo - ulp(lo), up + ulp(up));
	}

	@:op(a /= b) inline public function assignDiv(rhs:FloatInterval) {
		if (rhs.lower < 0 && rhs.upper > 0) {
			if ((this.lo <= 0 && this.up >= 0) || !Math.isFinite(this.lo) ||
					!Math.isFinite(this.up)) {
				return assignInternal(Math.NaN, Math.NaN);
			}
			return assignInternal(Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY);
		}
		var ll = this.lo / rhs.lower;
		var lu = this.lo / rhs.upper;
		var ul = this.up / rhs.lower;
		var uu = this.up / rhs.upper;
		var lo = min(ll, lu, ul, uu);
		var up = max(ll, lu, ul, uu);
		return assignInternal(lo - ulp(lo), up + ulp(up));
	}

	@:op(++a) inline public function preIncrement() {
		return assignAdd(1);
	}

	@:op(a++) inline public function postIncrement() {
		var tmp = copy();
		preIncrement();
		return tmp;
	}

	@:op(--a) inline public function preDecrement() {
		return assignSub(1);
	}

	@:op(a--) inline public function postDecrement() {
		var tmp = copy();
		preDecrement();
		return tmp;
	}

	@:op(a + b) @:commutative inline public function add(rhs:FloatInterval) {
		var tmp = copy();
		tmp += rhs;
		return tmp;
	}

	@:op(a - b) inline public static function sub(lhs:FloatInterval, rhs:FloatInterval) {
		var tmp = lhs.copy();
		tmp -= rhs;
		return tmp;
	}

	@:op(a * b) @:commutative inline public function mult(rhs:FloatInterval) {
		var tmp = copy();
		tmp *= rhs;
		return tmp;
	}

	@:op(a / b) inline public static function div(lhs:FloatInterval, rhs:FloatInterval) {
		var tmp = lhs.copy();
		tmp /= rhs;
		return tmp;
	}

	@:op(-a) inline public function neg() {
		return makeFast(-this.up, -this.lo);
	}

	@:op(a < b) inline public static function lt(lhs:FloatInterval, rhs:FloatInterval) {
		return lhs.upper < rhs.lower;
	}

	@:op(a <= b) inline public static function lte(lhs:FloatInterval, rhs:FloatInterval) {
		return lhs.lower <= rhs.upper;
	}

	@:op(a >= b) inline public static function gte(lhs:FloatInterval, rhs:FloatInterval) {
		return lhs.lower >= rhs.upper || lhs.upper >= rhs.lower;
	}

	@:op(a > b) inline public static function gt(lhs:FloatInterval, rhs:FloatInterval) {
		return lhs.lower > rhs.upper;
	}

	@:op(a == b) inline public static function eq(lhs:FloatInterval, rhs:FloatInterval) {
		return lhs.upper >= rhs.lower && lhs.lower <= rhs.upper;
	}

	@:op(a != b) inline public static function neq(lhs:FloatInterval, rhs:FloatInterval) {
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
