import FloatTools.ulp;

/**

  Patrikalakis, N.; Maekawa, T.; Cho, W.  Shape Interrogation for Computer
  Aided Design and Manufacturing.  Section 4.8, Rounded interval arithmetic and
  its implementation.  Available at
  http://web.mit.edu/hyperbook/Patrikalakis-Maekawa-Cho/node46.html
**/
abstract FloatInterval(FloatIntervalImpl) {
	public var lower(get, never):Float;
	public var upper(get, never):Float;

	inline function new(interval)
	{
		this = interval;
	}

	inline function get_lower()
	{
		return this.lo;
	}

	inline function get_upper()
	{
		return this.up;
	}

	inline public static function make(lower:Float, upper:Float)
	{
		return new FloatInterval({ lo: lower, up: upper });
	}

	@:from
	public static function fromFloat(number:Float)
	{
		return make(number, number);  // FIXME ± 1 ulp?
	}

	@:commutative @:op(a + b)
	public function add(rhs:FloatInterval)
	{
		var lo = this.lo + rhs.lower;
		var up = this.up + rhs.upper;
		return make(lo - ulp(lo), up + ulp(up));
	}

	@:commutative @:op(a - b)
	public function sub(rhs:FloatInterval)
	{
		var lo = this.lo - rhs.upper;
		var up = this.up - rhs.lower;
		return make(lo - ulp(lo), up + ulp(up));
	}

	@:op(a*b)
	public function mult(rhs:FloatInterval)
	{
		var lo = min(this.lo*rhs.lower, this.lo*rhs.upper,
				this.up*rhs.lower, this.up*rhs.upper);
		var up = max(this.lo*rhs.lower, this.lo*rhs.upper,
				this.up*rhs.lower, this.up*rhs.upper);
		return make(lo - ulp(lo), up + ulp(up));
	}

	@:op(a/b)
	public function div(rhs:FloatInterval)
	{
		var lo = min(this.lo/rhs.lower, this.lo/rhs.upper,
				this.up/rhs.lower, this.up/rhs.upper);
		var up = max(this.lo/rhs.lower, this.lo/rhs.upper,
				this.up/rhs.lower, this.up/rhs.upper);
		return make(lo - ulp(lo), up + ulp(up));
	}

	static function min(x:Float, y:Float, w:Float, z:Float)
	{
		var ret = x;
		if (y < ret)
			ret = y;
		if (w < ret)
			ret = w;
		if (z < ret)
			ret = z;
		return ret;
	}

	static function max(x:Float, y:Float, w:Float, z:Float)
	{
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

typedef FloatIntervalImpl = IntervalImpl<Float>

typedef IntervalImpl<T> = {
	var lo:T;
	var up:T;
}
