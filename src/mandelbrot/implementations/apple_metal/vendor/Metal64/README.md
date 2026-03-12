
This project is emulating 64 bit floating point real and complex numbers in Metal.

# Two approaches

The project contains two different approaches for emulating 64 bit floating point values in Metal:

1. Emulate by using 32 bit floating point values
2. Emulate by using 64 bit unsinged integer values

Variant 1 can be found in folder "Metal64", variant 2 in folder "MetailUInt64". Variant 1 is faster than variant 2.

# Xcode requirements and settings

The Float2 and Complex2 implementation in Swift is using the SIMD module.
The package "swift-numerics" must be added as a dependency.

The option **Math Mode** under *Metal Compiler - Build Options* must be set to **safe** to ensure
IEEE conformity of floating point numbers.

The option **Relax IEEE Compliance** under *Apple Clang - Code Generation* must be set to **No**.

# Variant 1: Metal64
## Swift Part
### Construct 64 bit floating point numbers (Float2)

The Swift datatype **Float2** is an alias for the `SIMD2<Float32>` datatype. The following constructors are available:

> Float2()  
> Float2(Double)  
> Float2(Float)  

The assignment of literal numeric values is supported:

`let myFlt2: Float2 = 2.0`

### Convert a 64 bit floating point number to Double

The datatype Double is extended by a constructor to init a Double value with a Float2 value:

`let myDbl: Double = Double(myFlt2)`

### Construct 64 bit complex numbers (Complex2)

The Swift datatype **Complex2** is an alias for the `SIMD4<Float32>` datatype. The following constructors are available:

> Complex2()                  // 0  
> Complex2(Double)            // Init real part. Imaginary part is set to 0  
> Complex2(Double, Double)    // Init real and imaginary part  
> Complex2(ComplexDouble)  
> Complex2(Float2)  
> Complex2(Int)  

The assignment of literal numeric values is supported:

`let myCplx2: Complex2 = 2.0`

### Convert a 64 bit complex number to ComplexDouble

The datatype ComplexDouble (an alias for Complex<Float64>) is extended by a constructor which accepts a Complex2 value:

`let myCplx: ComplexDouble = ComplexDouble(myCplx2)`


## Metal part
### 64 bit real floating point numbers

The class f64 is used to define 64 bit real floating point variables in Metal. A 64 bit floating point number is internally stored as
a float2 vector element "v" in a f64 object. The metal source files must include "f64.h":

`#include "f64.h"`

#### Constructors

> f64()  
> f64(float)  
> f64(float2)  
> f64(float, float)    // Don't use this constructor, for internal use only  

#### Initialize by assigning literal values

Assign a float value to a f64 variable:

`f64 x = 2.0;`

#### Accessing / converting f64 objects

> f64 value = 2.0;
> float2 flt2val = value.v;

#### Operators

The mathematical operators +, -, \*, / are overloaded to support any combination of f64 and float operands.
The comparison operators ==, !=, \<, \>, \<=, \>= are only supporting f64 operands.

#### Mathematical functions

| Function       | Result |
|----------------|--------|
| floor(f64 x)   | Floor function |
| fmod(f64 x,f64 y)| Modulo division |
| sqr(f64 x)     | Square x \* x |
| sqrt(f64 x)    | Square root |
| pow(f64 x,int y) | Power x ^ y |
| pow(f64 x,f64 y) | Power x ^ y, for x > 0 |      
| exp(f64 x)     | Exponential |
| log(f64 x)     | Natural logarithm |
| sin(f64 x)     | Sine |
| cos(f64 x)     | Cosine |
| tan(f64 x)     | Tangent |
| asin(f64 x)    | Arc sine |
| acos(f64 x)    | Arc cosine |
| atan(f64 x)    | Arc tangent |
| atan2(f64 y,f64 x) | Arc tangent 2 |

#### Other functions

* isZero(f64 x) - Check if value is zero
* notZero(f64 x) - Check if value is not zero
* sign(f64 x) - Return sign of value: -1, 0, 1

#### Constants

| Constant   | Value      |
|------------|------------|
| F64_PI     | pi         |
| F64_1_PI   | 1 / pi     |
| F64_PI_2   | pi / 2     |
| F64_2_PI   | pi \* 2    |
| F64_PI_180 | pi / 180   |
| F64_LOG2   | log(2)     |
| F64_1_LOG2 | 1 / log(2) |
| F64_E      | e          |
| F64_1_E    | 1 / e      |
| F64_1_3    | 1 / 3      |


### 64 bit complex floating point numbers

The class c64 is used to define 64 bit complex floating point variables in Metal. A 64 bit complex floating point number is internally stored as
a float4 vector element "v" in a c64 object. The metal source files must include "c64.h" (includes "f64.h" implicitly):

`#include "c64.h"`

#### Constructors

> c64()  
> c64(float)  
> c64(float2)  
> c64(float2, float2)  
> c64(f64)  
> c64(f64, f64)  
> c64(float4)  

#### Initialize by assigning literal values

`c64 x = 2.0;`

`c64 x = f64(3.0);`

#### Accessing / converting c64 objects

> c64 complexvalue = c64(2.0, 3.0);  
> f64 realpart = complexvalue.real();  
> f64 imagpart = complexvalue.imaginary();  
> float2 real_part = complexvalue.v.xy  
> float2 imag_part = complexvalue.v.zw  
> float4 flt4value = complexvalue.v  

#### Operators

The mathematical operators +, -, \*, / are overloaded to support any combination of c64 with f64 and float operands.
The comparison operators ==, != are only supporting c64 operands.

#### Mathematical functions

| Function     | Result |
|--------------|--------|
| sqr(c64)     | Square |
| sqrt(c64)    | Square root |
| exp(c64)     | Exponential function |
| norm(c64)    | real \* real + imag \* imag |
| abs(c64)     | sqrt(norm(c64)) |
| arg(c64)     | Argument |

#### Other functions

* isZero(c64) - Check if value is zero
* notZero(c64) - Check if value is not zero
* c64.real() - Return real part
* c64.imaginary() - Return imag part

# Variant 2: MetalUInt64

tbd.
