//
//  f64.metal
//  Metal64
//
//  Created by Dirk Braner on 23.12.24.
//

#include <metal_stdlib>

#include "f64.h"

using namespace metal;

/// Floor
f64 floor(f64 a) {
    return f64(floor_f64(a.v));
}

/// Floating point modulo division
f64 fmod(f64 a, f64 b) {
    return f64(fmod_f64(a.v, b.v));
}

/// Square
f64 sqr(f64 a) {
    return f64(sqr_f64(a.v));
}

/// Square root
f64 sqrt(f64 a) {
    return f64(sqrt_f64(a.v));
}

// Power, exponent = int
f64 pow(f64 a, int b) {
    return f64(pow_f64(a.v, b));
}

// Power, exponent = f64
f64 pow(f64 a, f64 b) {
    return f64(exp_iterate(mul_f64(b.v, log_iterate(a.v))));
}

/// Exponential function
f64 exp(f64 a) {
    return f64(exp_iterate(a.v));
}

/// Natural logarithm
f64 log(f64 a) {
    return f64(log_iterate(a.v));
}

/// Sine
f64 sin(f64 a) {
    return f64(sincos_iterate(a.v).xy);
}

/// Cosine
f64 cos(f64 a) {
    return f64(sincos_iterate(a.v).zw);
}

/// Tangent
f64 tan(f64 a) {
    return f64(tan_iterate(a.v));
}

/// Arc Sine
f64 asin(f64 a) {
    return f64(asin_iterate(a.v));
}

/// Arc Cosine
f64 acos(f64 a) {
    return f64(acos_iterate(a.v));
}

/// Arc Tangent
f64 atan(f64 a) {
    return f64(atan2_iterate(a.v, F2_ONE));
}

/// Arc Tangent2
f64 atan2(f64 a, f64 b) {
    return f64(atan2_iterate(a.v, b.v));
}

// Overloaded operators

f64 operator + (f64 a, f64 b) {
    return f64(add_f64(a.v, b.v));
}

f64 operator + (f64 a, float b) {
    return f64(add_f64(a.v, float2(b, 0.0f)));
}

f64 operator + (float b, f64 a) {
    return f64(add_f64(a.v, float2(b, 0.0f)));
}

f64 operator - (f64 a, f64 b) {
    return f64(add_f64(a.v, -b.v));
}

f64 operator - (f64 a, float b) {
    return f64(sub_f64(a.v, float2(b, 0.0f)));
}

f64 operator - (float b, f64 a) {
    return f64(sub_f64(a.v, float2(b, 0.0f)));
}

f64 operator * (f64 a, f64 b) {
    return f64(mul_f64(a.v, b.v));
}

f64 operator * (f64 a, float b) {
    return f64(mulds(a.v, b));
}

f64 operator * (float a, f64 b) {
    return f64(mulds(b.v, a));
}

f64 operator / (f64 a, f64 b) {
    return f64(div_f64(a.v, b.v));
}

f64 operator / (f64 a, float b) {
    return f64(div_f64(a.v, float2(b, 0.0f)));
}

f64 operator / (float b, f64 a) {
    return f64(div_f64(a.v, float2(b, 0.0f)));
}

bool operator == (f64 a, f64 b) {
    return all(a.v == b.v);
}

bool operator != (f64 a, f64 b) {
    return any(a.v != b.v);
}

bool operator < (f64 a, f64 b) {
    return lt(a.v, b.v);
}

bool operator > (f64 a, f64 b) {
    return gt(a.v, b.v);
}

bool operator <= (f64 a, f64 b) {
    return le(a.v, b.v);
}

bool operator >= (f64 a, f64 b) {
    return ge(a.v, b.v);
}

bool isZero(f64 a) {
    return all(a.v == 0.0);
}

bool notZero(f64 a) {
    return any(a.v != 0.0);
}

int sign(f64 a) {
    return sign_f64(a.v);
}
