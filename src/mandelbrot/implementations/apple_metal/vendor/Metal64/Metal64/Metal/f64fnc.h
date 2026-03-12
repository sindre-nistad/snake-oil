//
//  f64fnc.h
//  Metal64
//
//  Created by Dirk Braner on 23.12.24.
//

#ifndef __F64FNC_H
#define __F64FNC_H

using namespace metal;


// ----------------------------------------------------------------------------
//  Constants
// ----------------------------------------------------------------------------

constant float2 F2_PI     = float2(3.1415927, -8.742278e-08);   // PI
constant float2 F2_1_PI   = float2(0.31830987, 1.28412765e-08); // 1 / PI
constant float2 F2_2_PI   = float2(6.2831855, -1.7484555e-07);  // PI * 2
constant float2 F2_PI_2   = float2(1.5707964, -4.371139e-08);   // PI / 2
constant float2 F2_PI_180 = float2(0.017453292, 1.351996e-10);  // PI / 180
constant float2 F2_LOG2   = float2(0.6931472, -1.9046542e-09);  // LOG(2)
constant float2 F2_1_LOG2 = float2(1.442695, 1.925963e-08);     // 1 / LOG(2)
constant float2 F2_E      = float2(2.7182817, 8.2548404e-08);   // E
constant float2 F2_1_E    = float2(0.36787945, -9.149755e-09);  // 1 / E
constant float2 F2_1_3    = float2(0.33333334, -9.934108e-09);  // 1 / 3

constant float2 F2_ZERO   = 0.0f;
constant float2 F2_ONE    = float2(1.0f, 0.0f);


// ----------------------------------------------------------------------------
//  Functions
// ----------------------------------------------------------------------------

// Helper functions
float2 flt2(float);
float2 sumq(float, float);
float2 sumq(float2);
float4 sump(float2, float2);
float4 split4(float2);
float2 prod(float, float);

// CORDIC iteration functions
float4 sincos_iterate(float2);
float2 tan_iterate(float2);
float2 asin_iterate(float2);
float2 acos_iterate(float2);
float2 atan2_iterate(float2, float2);
float2 exp_iterate(float2);
float2 log_iterate(float2);

float2 add_f64(float2, float2);
float2 sub_f64(float2, float2);
float2 mul_f64(float2, float2);
float2 sqr_f64(float2);
float2 sqr_f64(float);
float2 mulds(float2, float);
float2 div_f64(float2, float2);

bool isZero_f64(float2);
bool ltZero(float2);
bool gtZero(float2);
int sign_f64(float2);

bool eq(float2, float2);
bool ne(float2, float2);
bool lt(float2, float2);
bool gt(float2, float2);
bool le(float2, float2);
bool ge(float2, float2);

float2 sqrt_f64(float2);
float2 exp_f64(float2);
float2 log_f64(float2);
float2 pow_f64(float2, float2);
float2 pow_f64(float2, int);

float2 floor_f64(float2);
float2 fmod_f64(float2, float2);

float2 sin_f64(float2);
float2 cos_f64(float2);
float2 tan_f64(float2);
float2 atan_f64(float2);
float2 atan2_f64(float2, float2);
float2 asin_f64(float2);
float2 acos_f64(float2);

float4 add_c64(float4, float4);
float4 sub_c64(float4, float4);
float4 mul_c64(float4, float4);
float4 sqr_c64(float4);
float4 sqrt_c64(float4);
float4 div_c64(float4, float4);
float4 exp_c64(float4);

bool eq(float4, float4);
bool ne(float4, float4);

float2 norm_c64(float4);
float2 abs_c64(float4);

float2x4 mandelbrot(float4, float4, float2);

#endif
