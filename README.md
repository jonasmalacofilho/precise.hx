# precise.hx

_Floating point arithmetic with reliable error bounds_


## Overview

### `FloatInterval`

Floating point interval (FPI) arithmetic with double precision.

```haxe
var u = 3 * Math.pow(2, 44);
var v = -7;
var w = -v + Math.pow(2, -49);
trace('[example] take u = $u, v = $v, w = $w');

// FP results (with double precision):
trace(u * (v + w));                     // 0.09375 (expected value)
trace(u * v + u * w);                   // 0.125 <-- NOO!!!

// but with FPI arithmetic:
trace((u : FloatInterval) * (v + w));   // 0.09375 ± 1.38777878078145e-17
trace((u : FloatInterval) * v + u * w); // 0.125 ± 0.0625
```

### `Currency`

Manipulation of currency amounts using FPI arithmetic.

### `FloatTools`

Assorted tools for `Float`, including `.ulp()` and `.repr()`.


## Installing

```
$ haxelib git precise https://github.com/jonasmalacofilho/precise.hx
```

## Contributing

```
$ git clone https://github.com/jonasmalacofilho/precise.hx
$ haxelib dev precise precise.hx

$ haxelib newrepo
$ haxelib install test.hxml

$ haxe test.hxml
$ haxe test_{neko,hl,hlc}.hxml
```
