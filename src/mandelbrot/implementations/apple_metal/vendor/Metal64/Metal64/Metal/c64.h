
//
//  c64.h
//
//  Part of Metal64
//
//  Implementation of Metal datatype complex f64 = c64
//
//  Created by Dirk Braner on 15.12.24.
//

#ifndef __C64_H
#define __C64_H

#include "f64.h"

using namespace metal;


struct c64 {
    float4 v;

    c64() {
        v = float4(0.0, 0.0, 0.0, 0.0);
    }

    /// Initialize real part with 32 bit floating point value
    c64(float a) {
        v = float4(a, 0.0, 0.0, 0.0);
    }

    /// Initialize real part with 64 bit floating point value
    c64(float2 a) {
        v.xy = a;
    }

    /// Initialize real and imag part with 64 bit floating point values
    c64(float2 a, float2 b) {
        v = float4(a, b);
    }

    c64(f64 a) {
        v.xy = a.v;
    }

    c64(f64 a, f64 b) {
        v = float4(a.v, b.v);
    }

    /// Initialize c64 with float4 vector (compatible with Swift type Complex2)
    c64(float4 a) {
        v = a;
    }

    /// Initialize c64 with float
    c64 operator = (float a) {
        v = float4(a, 0.0f, 0.0f, 0.0f);
        return *this;
    }

    /// Initialize c64 with f64
    c64 operator = (f64 a) {
        v = float4(a.v, float2(0.0f, 0.0f));
        return *this;
    }

    /// Return real part of complex number
    f64 real() {
        return f64(v.xy);
    }

    /// Return imaginary part of complex number
    f64 imaginary() {
        return f64(v.zw);
    }
};

c64 operator + (c64, c64);
c64 operator + (c64, f64);
c64 operator + (f64, c64);
c64 operator + (c64, float);
c64 operator + (float, c64);
c64 operator - (c64, c64);
c64 operator - (c64, f64);
c64 operator - (f64, c64);
c64 operator - (c64, float);
c64 operator - (float, c64);
c64 operator * (c64, c64);
c64 operator * (c64, f64);
c64 operator * (f64, c64);
c64 operator * (c64, float);
c64 operator * (float, c64);
c64 operator / (c64, c64);
c64 operator / (c64, f64);
c64 operator / (f64, c64);
c64 operator / (c64, float);
c64 operator / (float, c64);

bool isZero(c64);
bool notZero(c64);
bool operator == (c64, c64);
bool operator != (c64, c64);

c64 sqr(c64);
c64 sqrt(c64);
c64 exp(c64);

f64 norm(c64);
f64 abs(c64);
f64 arg(c64);

#endif
