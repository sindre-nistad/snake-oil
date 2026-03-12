//
//  f64.h
//
//  Part of Metal64
//
//  Implementation of datatype f64
//
//  Mandatory Xcode build settings:
//
//    Metal Compiler - Build Options - Math Mode = "Safe"
//    User Defined - MTL_FAST_MATH = "NO"
//
//  Created by Dirk Braner on 15.12.24.
//

#ifndef __F64_H
#define __F64_H

#include "f64fnc.h"

using namespace metal;

/// Struct for 64 bit floating points
struct f64 {
    float2 v;

    f64() {
        v = float2(0.0f, 0.0f);
    }

    f64(float a) {
        v = float2(a, 0.0f);
    }

    f64(float2 a) {
        v = a;
    }

    f64(float a, float b) {
        v = float2(a, b);
    }

    f64 operator = (float a) {
        v = float2(a, 0.0f);
        return *this;
    }
};

// Constants
constant f64 F64_PI     = f64(3.1415927, -8.742278e-08);    // PI
constant f64 F64_1_PI   = f64(0.31830987, 1.28412765e-08);  // 1 / PI
constant f64 F64_PI_2   = f64(1.5707964, -4.371139e-08);    // PI / 2
constant f64 F64_2_PI   = f64(6.2831855, -1.7484555e-07);   // PI * 2
constant f64 F64_PI_180 = f64(0.017453292, 1.351996e-10);   // PI / 180
constant f64 F64_LOG2   = f64(0.6931472, -1.9046542e-09);   // LOG(2)
constant f64 F64_1_LOG2 = f64(1.442695, 1.925963e-08);      // 1 / LOG(2)
constant f64 F64_E      = f64(2.7182817, 8.2548404e-08);    // E
constant f64 F64_1_E    = f64(0.36787945, -9.149755e-09);   // 1 / E
constant f64 F64_1_3    = f64(0.33333334, -9.934108e-09);   // 1 / 3

// Functions
f64 floor(f64);
f64 fmod(f64, f64);
f64 sqr(f64);
f64 sqrt(f64);
f64 pow(f64, int);
f64 pow(f64, f64);
f64 exp(f64);
f64 log(f64);
f64 sin(f64);
f64 cos(f64);
f64 tan(f64);
f64 asin(f64);
f64 acos(f64);
f64 atan(f64);
f64 atan2(f64, f64);

f64 operator + (f64, f64);
f64 operator + (f64, float);
f64 operator + (float, f64);
f64 operator - (f64, f64);
f64 operator - (f64, float);
f64 operator - (float, f64);
f64 operator * (f64, f64);
f64 operator * (f64, float);
f64 operator * (float, f64);
f64 operator / (f64, f64);
f64 operator / (f64, float);
f64 operator / (float, f64);

bool operator == (f64, f64);
bool operator != (f64, f64);
bool operator < (f64, f64);
bool operator > (f64, f64);
bool operator <= (f64, f64);
bool operator >= (f64, f64);

bool isZero(f64);
bool notZero(f64);
int sign(f64);

#endif
