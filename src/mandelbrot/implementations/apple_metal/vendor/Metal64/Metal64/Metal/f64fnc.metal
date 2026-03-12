//
//  f64fnc.h
//
//  Functions for 64 bit floating point GPU/Metal calculations
//
//  Created by Dirk Braner on 13.12.24.
//
//  64 bit real float:
//
//    A 64 bit float value is represented by float2 data type.
//    The corresponding Swift data types are SIMD2<Float32> and Float2.
//      .x = High value part
//      .y = Low value part
//
//  64 bit complex float:
//
//    A 64 bit complex value is represented by float4 data type.
//    The corresponding Swift data type is SIMD4<Float32> and Complex2.
//      .xy = float2 with real part high, low
//      .zw = float2 with imaginary part high, low
//
//  References:
//
//    CORDIC algorithms: // https://people.sc.fsu.edu/~jburkardt/c_src/cordic/cordic.html
//

#include <metal_stdlib>

#include "f64fnc.h"

using namespace metal;


// ----------------------------------------------------------------------------
//  Helper functions
// ----------------------------------------------------------------------------

// Convert float32 to float2
float2 flt2(float a) {
    return float2(a, 0.0f);
}

// Add hi and lo
float2 sumq(float a, float b) {
    float s = a + b;
    float e = b - (s - a);
    return float2(s, e);
}

float2 sumq(float2 a) {
    float s = a.x + a.y;
    float e = a.y - (s - a.x);
    return float2(s, e);
}

float4 sump(float2 a_ri, float2 b_ri) {
    float2 s = a_ri + b_ri;
    float2 v = s - a_ri;
    float2 e = (a_ri - (s - v)) + (b_ri - v);
    return float4(s.x, e.x, s.y, e.y);
}

// Split two 32 bit floats into four 16 bit floats
float4 split4(float2 c) {
    float2 t = c * 4097.0;
    float2 c_hi = t - (t - c);
    float2 c_lo = c - c_hi;
    return float4(c_hi.x, c_lo.x, c_hi.y, c_lo.y);
}

float2 prod(float a, float b) {
    float p = a * b;
    float4 s = split4(float2(a, b));
    float e = ((s.x * s.z - p) + s.x * s.w + s.y * s.z) + s.y * s.w;
    return float2(p, e);
}

// ----------------------------------------------------------------------------
//  Real operations
// ----------------------------------------------------------------------------

// Add 2 64 bit floating point values
float2 add_f64(float2 a, float2 b) {
    float4 st = sump(a, b);
    st.y += st.z;
    st.xy = sumq(st.xy);
    st.y += st.w;
    return sumq(st.xy);
}

// Subtract 2 64 bit floating point values
float2 sub_f64(float2 a, float2 b) {
    return add_f64(a, -b);
}

// Multiplication: f64 * f64
float2 mul_f64(float2 a, float2 b) {
    float2 p = prod(a.x, b.x);
    p.y += a.x * b.y + a.y * b.x;
    return sumq(p);
}


// Multiplication: f64 * f32
float2 mulds(float2 a, float b) {
    float2 p = prod(a.x, b);
    p.y += a.y * b;
    return sumq(p);
}

// Square of f64
float2 sqr_f64(float2 a) {
    float2 p = prod(a.x, a.x);
    p.y += 2.0f * a.x * a.y;
    return sumq(p);
}

// f64 square of float
float2 sqr_f64(float a) {
    return sumq(prod(a, a));
}

// Division: f64 / f64
float2 div_f64(float2 b, float2 a) {
    float xn = 1.0f / a.x;
    float yn = b.x * xn;
    float2 ayn = mulds(a, yn);
    float diff = sub_f64(b, ayn).x;
    float2 p = prod(xn, diff);
    return add_f64(flt2(yn), p);
}

// ----------------------------------------------------------------------------
// Compare two 64 bit floating point values
// ----------------------------------------------------------------------------

// Check for zero
bool isZero_f64(float2 a) {
    return all(a == 0.0);
}

// Return sign of value: -1: <0, 0: =0, 1: >0
int sign_f64(float2 a) {
    if (all(a == 0.0)) {
        return 0;
    }
    else if (a.x < 0.0 || (a.x == 0.0 && a.y < 0.0)) {
        return -1;
    }
    else {
        return 1;
    }
}

// Equal
bool eq(float2 a, float2 b) {
    return all(a == b);
}

// Not equal
bool ne(float2 a, float2 b) {
    return any(a != b);
}

// Less than
bool lt(float2 a, float2 b) {
    return (a.x < b.x || (a.x == b.x && a.y < b.y));
}

// Less than zero
bool ltZero(float2 a) {
    return (a.x < 0.0 || (a.x == 0.0 && a.y < 0.0));
}

// Greater than
bool gt(float2 a, float2 b) {
    return (a.x > b.x || (a.x == b.x && a.y > b.y));
}

// Greater than zero
bool gtZero(float2 a) {
    return (a.x > 0.0 || (a.x == 0.0 && a.y > 0.0));
}

// Less or equal
bool le(float2 a, float2 b) {
    return lt(a, b) || eq(a, b);
}

// Greater or equal
bool ge(float2 a, float2 b) {
    return gt(a, b) || eq(a, b);
}

// ----------------------------------------------------------------------------
//  Square root, exponential, logarithm and trigonomical functions
// ----------------------------------------------------------------------------

// Square root
float2 sqrt_f64(float2 a) {
    float xn = rsqrt(a.x);
    float yn = a.x * xn;
    float diff = (sub_f64(a, sqr_f64(yn))).x;
    float2 p = prod(xn, diff) * 0.5f;
    return add_f64(flt2(yn), p);
}

// Exponential
float2 exp_f64(float2 a) {
    /*
    float2 s = add_f64(a, F2_ONE);
    float2 t = a;
    float2 d = a;
    int m = 2;

    while (abs(t.x) > 1e-20) {
        d = div_f64(a, flt2(m));
        t = mul_f64(t, d);
        s = add_f64(s, t);
        m++;
    }

    return s;
     */
    return exp_iterate(a);
}

// Natural logarithm
float2 log_f64(float2 a) {
    if (eq(a, F2_ONE)) return F2_ZERO;
    if (le(a, F2_ZERO)) return NAN;

    return log_iterate(a);
}

// Power f64, f64
// Returns NAN for a < 0
float2 pow_f64(float2 a, float2 b) {
    return exp_f64(mul_f64(b, log_f64(a)));
}

// Power f64, int
float2 pow_f64(float2 a, int b) {
    float2 r = F2_ONE;
    int e = abs(b);
    int i;

    for (i=0; i<e; i++) {
        r = mul_f64(r, a);
    }

    // a ^ -b = 1 / a ^ b
    return b >= 0 ? r : div_f64(F2_ONE, r);
}

// Floor
float2 floor_f64(float2 a) {
    if(ltZero(a)) {
        float2 f = floor(a);
        return flt2(f.x < 0.0 ? f.x : f.y);
    }
    else {
        return float2((int)a.x);
    }
}

// Floating point modulo division
float2 fmod_f64(float2 a, float2 b) {
    float2 d = div_f64(a, b);
    float i = float(int(d.x));
    return sub_f64(a, mulds(b, i));
}

// Sine
float2 sin_f64(float2 a) {
    return sincos_iterate(a).xy;
}

// Cosine
float2 cos_f64(float2 a) {
    return sincos_iterate(a).zw;
}

// Tangent
float2 tan_f64(float2 a) {
    return tan_iterate(a);
}

// Inverse tangent
float2 atan_f64(float2 a) {
    return atan2_iterate(a, F2_ONE);
}

// Inverse tangent2
float2 atan2_f64(float2 y, float2 x) {
    return atan2_iterate(y, x);
}

// Inverse sine
float2 asin_f64(float2 a) {
    // asin_iterate() is faster while atan2_iterate is more accurate
    return asin_iterate(a);
    // return atan2_iterate(a, sqrt_f64(sub_f64(F2_ONE, sqr_f64(a))));
}

// Inverse cosine
float2 acos_f64(float2 a) {
    if(lt(a, flt2(-1)) || gt(a, F2_ONE)) return NAN;

    // acos_iterate() is faster while atan2_iterate is more accurate
    return acos_iterate(a);
    // return atan2_iterate(sqrt_f64(sub_f64(F2_ONE, sqr_f64(a))), a);
}

// ----------------------------------------------------------------------------
//  Complex operations
// ----------------------------------------------------------------------------

// Add 2 64 bit complex values
float4 add_c64(float4 a, float4 b) {
    return float4(add_f64(a.xy, b.xy), add_f64(a.zw, b.zw));
}

// Subtract 2 64 bit complex values
float4 sub_c64(float4 a, float4 b) {
    return float4(add_f64(a.xy, -b.xy), add_f64(a.zw, -b.zw));
}

// Multiply 2 64 bit complex values
float4 mul_c64(float4 a, float4 b) {
    float2 r1 = mul_f64(a.xy, b.xy);    // a.r * b.r
    float2 r2 = mul_f64(a.zw, b.zw);    // a.i * b.i
    float2 i1 = mul_f64(a.xy, b.zw);    // a.r * b.i
    float2 i2 = mul_f64(a.zw, b.xy);    // a.i * b.r
    return float4(sub_f64(r1, r2), add_f64(i1, i2));
}

// Square of 64 bit complex value
float4 sqr_c64(float4 a) {
    float2 r1 = mul_f64(a.xy, a.xy);
    float2 r2 = mul_f64(a.zw, a.zw);
    float2 i1 = mul_f64(a.xy, a.zw);
    return float4(sub_f64(r1, r2), add_f64(i1, i1));
}

// Divide 2 64 bit complex values
float4 div_c64(float4 a, float4 b) {
    float2 d = add_f64(mul_f64(b.xy, b.xy), mul_f64(b.zw, b.zw));
    float2 r = div_f64(add_f64(mul_f64(a.xy, b.xy), mul_f64(a.zw, b.zw)), d);
    float2 i = div_f64(sub_f64(mul_f64(a.zw, b.xy), mul_f64(a.xy, b.zw)), d);
    return float4(r, i);
}

// 64 bit complex square root
float4 sqrt_c64(float4 a) {
    float2 dc = abs_c64(a);
    float2 r = sqrt_f64(mulds(add_f64(dc, a.xy), 0.5));
    float2 i = lt(a.zw, F2_ZERO) ? -sqrt_f64(mulds(sub_f64(dc, a.xy), 0.5)) : sqrt_f64(mulds(sub_f64(dc, a.xy), 0.5));
    return float4(r, i);
}

// 64 bit complex exponential function
float4 exp_c64(float4 a) {
    float2 e = exp_f64(a.xy);
    return float4(mul_f64(e, cos_f64(a.zw)), mul_f64(e, sin_f64(a.zw)));
}

// Compare 64 bit complex values
bool eq(float4 a, float4 b) {
    return all(a == b);
}

bool ne(float4 a, float4 b) {
    return any(a != b);
}

float2 norm_c64(float4 c) {
    return add_f64(sqr_f64(c.xy), sqr_f64(c.zw));
}

float2 abs_c64(float4 c) {
    return sqrt_f64(norm_c64(c));
}

// ----------------------------------------------------------------------------
//  Special functions
// ----------------------------------------------------------------------------

// Calculate Z = Z^2 + C (experimental!)
// Returns 2 float4 values:
//   [0] = Zn
//   [1].xy = norm (float2)
//   [1].z  = flag (float): 0 = bailout reached, 1 = continue iteration
//   [1].w  = unused
float2x4 mandelbrot(float4 z, float4 c, float2 bailout) {
    float2 r1 = sqr_f64(z.xy);
    float2 r2 = sqr_f64(z.zw);
    float2 n = add_f64(r1, r2);

    if (ge(n, bailout)) return float2x4(z, float4(n, F2_ZERO));

    float2 i1 = mul_f64(z.xy, z.zw);
    float4 z1 = float4(add_f64(sub_f64(r1, r2), c.xy), add_f64(add_f64(i1, i1), c.zw));

    return float2x4(z1, float4(n, F2_ONE));
}
