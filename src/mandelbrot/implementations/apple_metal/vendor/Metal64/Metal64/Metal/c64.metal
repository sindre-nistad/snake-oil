//
//  c64.metal
//  Metal64
//
//  Created by Dirk Braner on 22.12.24.
//

#include <metal_stdlib>

#include "c64.h"

using namespace metal;

c64 operator + (c64 a, c64 b) {
    return c64(add_c64(a.v, b.v));
}

c64 operator + (c64 a, f64 b) {
    return c64(add_f64(a.v.xy, b.v), a.v.zw);
}

c64 operator + (f64 b, c64 a) {
    return c64(add_f64(a.v.xy, b.v), a.v.zw);
}

c64 operator + (c64 a, float b) {
    return c64(add_f64(a.v.xy, float2(b, 0.0f)), a.v.zw);
}

c64 operator + (float b, c64 a) {
    return c64(add_f64(a.v.xy, float2(b, 0.0f)), a.v.zw);
}

c64 operator - (c64 a, c64 b) {
    return c64(sub_c64(a.v, b.v));
}

c64 operator - (c64 a, f64 b) {
    return c64(sub_f64(a.v.xy, b.v), a.v.zw);
}

c64 operator - (f64 b, c64 a) {
    return c64(sub_f64(b.v, a.v.xy), a.v.zw);
}

c64 operator - (c64 a, float b) {
    return c64(sub_f64(a.v.xy, float2(b, 0.0f)), a.v.zw);
}

c64 operator - (float b, c64 a) {
    return c64(sub_f64(float2(b, 0.0f), a.v.xy), a.v.zw);
}

c64 operator * (c64 a, c64 b) {
    return c64(mul_c64(a.v, b.v));
}

c64 operator * (c64 a, f64 b) {
    return c64(mul_f64(a.v.xy, b.v), mul_f64(a.v.zw, b.v));
}

c64 operator * (f64 b, c64 a) {
    return c64(mul_f64(a.v.xy, b.v), mul_f64(a.v.zw, b.v));
}

c64 operator * (c64 a, float b) {
    return c64(mulds(a.v.xy, b), mulds(a.v.zw, b));
}

c64 operator * (float b, c64 a) {
    return c64(mulds(a.v.xy, b), mulds(a.v.zw, b));
}

c64 operator / (c64 a, c64 b) {
    return c64(div_c64(a.v, b.v));
}

c64 operator / (c64 a, f64 b) {
    return c64(div_f64(a.v.xy, b.v), div_f64(a.v.zw, b.v));
}

c64 operator / (f64 b, c64 a) {
    return c64(div_f64(b.v, a.v.xy), div_f64(b.v, a.v.zw));
}

c64 operator / (c64 a, float b) {
    return c64(div_f64(a.v.xy, float2(b, 0.0f)), div_f64(a.v.zw, float2(b, 0.0f)));
}

c64 operator / (float b, c64 a) {
    return c64(div_f64(float2(b, 0.0f), a.v.xy), div_f64(float2(b, 0.0f), a.v.zw));
}

bool isZero(c64 a) {
    return all(a.v == 0.0);
}

bool notZero(c64 a) {
    return any(a.v != 0.0);
}

bool operator == (c64 a, c64 b) {
    return all(a.v == b.v);
}

bool operator != (c64 a, c64 b) {
    return any(a.v != b.v);
}

c64 sqr(c64 a) {
    return c64(sqr_c64(a.v));
}

c64 sqrt(c64 a) {
    return c64(sqrt_c64(a.v));
}

c64 exp(c64 a) {
    return c64(exp_c64(a.v));
}

f64 norm(c64 a) {
    return f64(norm_c64(a.v));
}

f64 abs(c64 a) {
    return f64(abs_c64(a.v));
}

f64 arg(c64 a) {
    return f64(atan2_f64(a.v.zw, a.v.xy));
}
