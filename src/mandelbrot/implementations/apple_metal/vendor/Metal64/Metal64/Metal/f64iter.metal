//
//  f64iter.metal
//
//  Part of Metal64
//
//  CORDIC iteration functions
//
//  Created by Dirk Braner on 11.04.25.
//

#include <metal_stdlib>

#include "f64fnc.h"

using namespace metal;

//
// Constants for CORDIC algorithms
//

// Number of iterations
constant int CORDIC_SINCOS_ITERATIONS = 50;
constant int CORDIC_TAN_ITERATIONS    = 50;
constant int CORDIC_ASIN_ITERATIONS   = 50;
constant int CORDIC_ACOS_ITERATIONS   = 50;
constant int CORDIC_ATAN_ITERATIONS   = 50;
constant int CORDIC_LOGEXP_ITERATIONS = 50;
constant int CORDIC_MAX_ITERATIONS    = 50;


//
// Predefined values
//

// Lookup table for 1 / power of 2
// for i = 1..n: x[i] = 1 / 2 ^ i
constant float2 pot[CORDIC_MAX_ITERATIONS] = {
    float2(1.0, 0.0),
    float2(0.5, 0.0),
    float2(0.25, 0.0),
    float2(0.125, 0.0),
    float2(0.0625, 0.0),
    float2(0.03125, 0.0),
    float2(0.015625, 0.0),
    float2(0.0078125, 0.0),
    float2(0.00390625, 0.0),
    float2(0.001953125, 0.0),
    float2(0.0009765625, 0.0),
    float2(0.00048828125, 0.0),
    float2(0.00024414062, 0.0),
    float2(0.00012207031, 0.0),
    float2(6.1035156e-05, 0.0),
    float2(3.0517578e-05, 0.0),
    float2(1.5258789e-05, 0.0),
    float2(7.6293945e-06, 0.0),
    float2(3.8146973e-06, 0.0),
    float2(1.9073486e-06, 0.0),
    float2(9.536743e-07, 0.0),
    float2(4.7683716e-07, 0.0),
    float2(2.3841858e-07, 0.0),
    float2(1.1920929e-07, 0.0),
    float2(5.9604645e-08, 0.0),
    float2(2.9802322e-08, 0.0),
    float2(1.4901161e-08, 0.0),
    float2(7.450581e-09, 0.0),
    float2(3.7252903e-09, 0.0),
    float2(1.8626451e-09, 0.0),
    float2(9.313226e-10, 0.0),
    float2(4.656613e-10, 0.0),
    float2(2.3283064e-10, 0.0),
    float2(1.1641532e-10, 0.0),
    float2(5.820766e-11, 0.0),
    float2(2.910383e-11, 0.0),
    float2(1.4551915e-11, 0.0),
    float2(7.275958e-12, 0.0),
    float2(3.637979e-12, 0.0),
    float2(1.8189894e-12, 0.0),
    float2(9.094947e-13, 0.0),
    float2(4.5474735e-13, 0.0),
    float2(2.2737368e-13, 0.0),
    float2(1.1368684e-13, 0.0),
    float2(5.684342e-14, 0.0),
    float2(2.842171e-14, 0.0),
    float2(1.4210855e-14, 0.0),
    float2(7.1054274e-15, 0.0),
    float2(3.5527137e-15, 0.0),
};

// Lookup table for trigonomical iterations
//
// Building the table (starting with index 0):
//
//   for i=1..n: x[i-1] = arctan (0.5 ^ i)
//
constant int CORDIC_ANGLES_LENGTH = 60;
constant float2 trig_angles[CORDIC_ANGLES_LENGTH] = {
    float2(0.7853982, -2.1855694e-08),
    float2(0.4636476, 5.0121587e-09),
    float2(0.24497867, -3.1786778e-09),
    float2(0.124354996, -1.2403822e-09),
    float2(0.06241881, -1.0272779e-09),
    float2(0.031239834, -2.525072e-10),
    float2(0.015623729, -1.2420882e-10),
    float2(0.007812341, -1.4939992e-10),
    float2(0.0039062302, -7.742832e-11),
    float2(0.0019531226, -3.8799422e-11),
    float2(0.0009765622, -1.9402376e-11),
    float2(0.00048828122, -9.701271e-12),
    float2(0.00024414062, -4.850638e-12),
    float2(0.00012207031, -6.0632977e-13),
    float2(6.1035156e-05, -7.579123e-14),
    float2(3.0517578e-05, -9.473904e-15),
    float2(1.5258789e-05, -1.1842385e-15),
    float2(7.6293945e-06, -1.4803002e-16),
    float2(3.8146973e-06, -1.8503858e-17),
    float2(1.9073486e-06, -2.3130352e-18),
    float2(9.536743e-07, -2.8915587e-19),
    float2(4.7683716e-07, -3.615772e-20),
    float2(2.3841858e-07, -4.5263323e-21),
    float2(1.1920929e-07, -5.6910026e-22),
    float2(5.9604645e-08, -7.2791894e-23),
    float2(2.9802322e-08, -9.926167e-24),
    float2(1.4901161e-08, -1.6543612e-24),
    float2(7.450581e-09, 0.0),
    float2(3.7252903e-09, 0.0),
    float2(1.8626451e-09, 0.0),
    float2(9.313226e-10, 0.0),
    float2(4.656613e-10, 0.0),
    float2(2.3283064e-10, 0.0),
    float2(1.1641532e-10, 0.0),
    float2(5.820766e-11, 0.0),
    float2(2.910383e-11, 0.0),
    float2(1.4551915e-11, 0.0),
    float2(7.275958e-12, 0.0),
    float2(3.637979e-12, 0.0),
    float2(1.8189894e-12, 0.0),
    float2(9.094947e-13, 0.0),
    float2(4.5474735e-13, 0.0),
    float2(2.2737368e-13, 0.0),
    float2(1.1368684e-13, 0.0),
    float2(5.684342e-14, 0.0),
    float2(2.842171e-14, 0.0),
    float2(1.4210855e-14, 0.0),
    float2(7.1054274e-15, 0.0),
    float2(3.5527137e-15, 0.0),
    float2(1.7763568e-15, 0.0),
    float2(8.881784e-16, 0.0),
    float2(4.440892e-16, 0.0),
    float2(2.220446e-16, 0.0),
    float2(1.110223e-16, 0.0),
    float2(5.551115e-17, 0.0),
    float2(2.7755576e-17, 0.0),
    float2(1.3877788e-17, 0.0),
    float2(6.938894e-18, 0.0),
    float2(3.469447e-18, 0.0),
    float2(1.7347235e-18, 0.0)
};

// Lookup table for sincos iteration
//
// Building the table (starting with index 0):
//
//   for i = 1..n: x[i-1] = 1 / sqrt (1 + 0.5 ^ (2 * i))
//
// max(n) = 24 (values are constant after 24 elements)
//
constant int CORDIC_KPROD_LENGTH = 24;
constant float2 trig_kprod[CORDIC_KPROD_LENGTH] = {
    float2(0.70710677, 1.21016175e-08),
    float2(0.6324555, 4.251236e-09),
    float2(0.613572, -1.0379318e-08),
    float2(0.6088339, 3.4830234e-09),
    float2(0.60764825, 2.8153113e-09),
    float2(0.6073518, -9.796448e-09),
    float2(0.60727763, 1.2333882e-08),
    float2(0.6072591, 1.7583774e-08),
    float2(0.6072545, -2.5824908e-08),
    float2(0.6072533, 8.0252995e-09),
    float2(0.607253, 1.6487784e-08),
    float2(0.60725296, 3.7022383e-09),
    float2(0.60725296, -1.439531e-08),
    float2(0.60725296, -1.8919696e-08),
    float2(0.60725296, -2.0050793e-08),
    float2(0.60725296, -2.0333568e-08),
    float2(0.60725296, -2.0404261e-08),
    float2(0.60725296, -2.0421934e-08),
    float2(0.60725296, -2.0426352e-08),
    float2(0.60725296, -2.0427457e-08),
    float2(0.60725296, -2.0427734e-08),
    float2(0.60725296, -2.0427802e-08),
    float2(0.60725296, -2.042782e-08),
    float2(0.60725296, -2.0427823e-08)
};

// Lookup table for log_iterate() and exp_iterate()
//
// Building the table (starting with index 0):
//
//   for i=1..n: x[i-1] = exp(2 ^ (-i))
//
constant int CORDIC_LOGEXP_LENGTH = 29;
constant float2 logexp[CORDIC_LOGEXP_LENGTH] = {
    float2(1.6487212, 5.2590998e-08),
    float2(1.2840254, -1.39915795e-08),
    float2(1.1331484, 2.1288873e-08),
    float2(1.0644945, -3.1705614e-08),
    float2(1.0317434, 2.4965208e-10),
    float2(1.0157477, 4.222774e-08),
    float2(1.0078431, -3.9580968e-08),
    float2(1.0039139, 9.943816e-09),
    float2(1.001955, 1.24237e-09),
    float2(1.000977, 1.5525825e-10),
    float2(1.0004884, 1.9404922e-11),
    float2(1.0002441, 2.980475e-08),
    float2(1.0001221, 7.4508835e-09),
    float2(1.000061, 1.8626831e-09),
    float2(1.0000305, 4.6566595e-10),
    float2(1.0000153, 1.1641599e-10),
    float2(1.0000076, 2.910383e-11),
    float2(1.0000038, 7.275958e-12),
    float2(1.0000019, 1.8189894e-12),
    float2(1.000001, 4.5474735e-13),
    float2(1.0000005, 1.1368684e-13),
    float2(1.0000002, 2.842171e-14),
    float2(1.0000001, 7.1054274e-15),
    float2(1.0000001, -5.9604645e-08),
    float2(1.0, 2.9802322e-08),
    float2(1.0, 1.4901161e-08),
    float2(1.0, 7.450581e-09),
    float2(1.0, 3.7252903e-09),
    float2(1.0, 1.8626451e-09)
};

// Shift angle of sine/cosine iteration
float2 angle_shift(float2 alpha, float2 beta) {
    float2 gamma;

    if (lt(alpha, beta)) {
        gamma = add_f64(sub_f64(beta, fmod_f64(sub_f64(beta, alpha), F2_2_PI)), F2_2_PI);
    }
    else {
        gamma = add_f64(beta, fmod_f64(sub_f64(alpha, beta), F2_2_PI));
    }

    return gamma;
}

// Sine/Cosine CORDIC algorithm
float4 sincos_iterate(float2 a) {
    float2 angle;
    float2 c2;
    float2 factor;
    int j;
    float2 fkprod;
    float2 poweroftwo = F2_ONE;
    int sigma = 0;
    int sign_factor = 1;
    float2 theta = 0.0;
    float2 c = F2_ONE, s = 0.0f;

    // Shift angle to interval [-pi,pi].
    theta = angle_shift(a, -F2_PI);

    // Shift angle to interval [-pi/2,pi/2] and account for signs.
    if (lt(theta, -F2_PI_2)) {
        theta = add_f64(theta, F2_PI);
        sign_factor = -1;
    }
    else if (lt(F2_PI_2, theta)) {
        theta = sub_f64(theta, F2_PI_2);
        sign_factor = -1;
    }

    angle = trig_angles[0];

    // Iterate
    for (j=1; j<CORDIC_SINCOS_ITERATIONS; j++) {
        sigma = ltZero(theta) ? -1 : 1;

        factor = sigma < 0 ? -poweroftwo : poweroftwo;

        c2 = sub_f64(c, mul_f64(factor, s));
        s  = add_f64(mul_f64(factor, c), s);
        c  = c2;

        // Update the remaining angle
        theta = sub_f64(theta, sigma < 0 ? -angle : angle);

        // poweroftwo = pot[j];
        poweroftwo = mulds(poweroftwo, 0.5);

        // Update the angle from table, or eventually by just dividing by two
        angle = j < CORDIC_ANGLES_LENGTH ? trig_angles[j] : mulds(angle, 0.5);
    }

    // Adjust length of output vector to be [cos(beta), sin(beta)]

    // KPROD is essentially constant after a certain point, so if N is
    // large, just take the last available value
    if (CORDIC_SINCOS_ITERATIONS > 0) {
        fkprod = trig_kprod[ min(CORDIC_SINCOS_ITERATIONS, CORDIC_KPROD_LENGTH) - 1 ];
        c = mul_f64(c, fkprod);
        s = mul_f64(s, fkprod);
    }

    //  Adjust for possible sign change because angle was originally not in quadrant 1 or 4.
    // c = mulds(c, sign_factor);
    // s = mulds(s, sign_factor);

    return sign_factor < 0 ? float4(-s, -c) : float4(s, c);
}

// Tangent CORDIC algorithm
float2 tan_iterate(float2 a) {
    float2 angle;
    float2 c = F2_ONE;
    float2 s = 0.0;
    float2 c2;
    float2 factor;
    int j;
    float2 poweroftwo = F2_ONE;
    int sigma;
    float2 theta;

    // Shift angle to interval [-pi,pi]
    theta = angle_shift (a, -F2_PI);

    // Shift angle to interval [-pi/2,pi/2]
    if (lt(theta, -F2_PI_2)) {
        theta = add_f64(theta, F2_PI);
    }
    else if (gt(theta, F2_PI_2)) {
        theta = sub_f64(theta, F2_PI);
    }

    angle = trig_angles[0];

    for (j=1; j<=CORDIC_TAN_ITERATIONS; j++) {
        sigma = ltZero(theta) ? -1 : 1;

        factor = sigma < 0 ? -poweroftwo : poweroftwo;

        c2 = sub_f64(c, mul_f64(factor, s));
        s  = add_f64(s, mul_f64(factor, c));
        c = c2;

        // Update the remaining angle
        theta = sigma < 0 ? add_f64(theta, angle) : sub_f64(theta, angle);

        poweroftwo = mulds(poweroftwo, 0.5);

        // Update the angle from table, or eventually by just dividing by two.
        angle = j + 1 > CORDIC_ANGLES_LENGTH ? mulds(angle, 0.5) : trig_angles[j];
    }

    return div_f64(s, c);
}

// Arc sine CORDIC algorithm
float2 asin_iterate(float2 a) {
    int i, j;
    int sigma;
    int sign_z1;
    float2 angle;
    float2 poweroftwo = F2_ONE;
    float2 theta = 0.0;
    float2 x1 = F2_ONE;
    float2 y1 = 0.0;
    float2 x2;
    float2 factor;

    if (gt(abs(a), F2_ONE)) return NAN;

    for (j=1; j<=CORDIC_ASIN_ITERATIONS; j++) {
        sign_z1 = ltZero(x1) ? -1 : 1;
        sigma = le(y1, a) ? sign_z1 : -sign_z1;

        angle = j <= CORDIC_ANGLES_LENGTH ? trig_angles[j - 1] : mulds(angle, 0.5);

        factor = sigma < 0 ? -poweroftwo : poweroftwo;

        for (i=1; i<=2; i++) {
            x2 = sub_f64(x1, mul_f64(factor, y1));
            y1 = add_f64(y1, mul_f64(factor, x1));
            x1 = x2;
        }

        theta = add_f64(theta, mulds(sigma < 0 ? -angle : angle, 2.0));

        a = add_f64(a, mul_f64(a, sqr_f64(poweroftwo)));

        poweroftwo = mulds(poweroftwo, 0.5);
    }

    return theta;
}

// Arc cosine CORDIC algorithm
float2 acos_iterate(float2 a) {
    float2 angle;
    int i;
    int j;
    float2 poweroftwo = F2_ONE;
    int sigma;
    int sign_z2;
    float2 theta = 0.0;
    float2 x1 = F2_ONE;
    float2 x2;
    float2 y1 = 0.0;
    float2 factor;

    if (gt(abs(a), F2_ONE)) return NAN;

    for (j=1; j<=CORDIC_ACOS_ITERATIONS; j++) {
        sign_z2 = ltZero(y1) ? -1 : 1;

        sigma = le(a, x1) ? sign_z2 : -sign_z2;

        angle = j <= CORDIC_ANGLES_LENGTH ? trig_angles[j - 1] : mulds(angle, 0.5);

        factor = sigma < 0 ? -poweroftwo : poweroftwo;

        for (i=1; i<=2; i++) {
            x2 = sub_f64(x1, mul_f64(factor, y1));
            y1 = add_f64(y1, mul_f64(factor, x1));
            x1 = x2;
        }

        theta = add_f64(theta, mulds(sigma < 0 ? -angle : angle, 2.0));

        a = add_f64(a, mul_f64(a, sqr_f64(poweroftwo)));

        poweroftwo = mulds(poweroftwo, 0.5);
    }

    return theta;
}

// Arc tangent 2 CORDIC algorithm
// For arc tangent set x = 1
float2 atan2_iterate(float2 y, float2 x) {
    float2 angle;
    int j;
    float2 poweroftwo = F2_ONE;
    int sigma;
    int sign_factor = 1;
    float2 theta = 0.0f;
    float2 x1 = x;
    float2 x2;
    float2 y1 = y;
    float2 factor;

    if (ltZero(x1) && ltZero(y1)) {
        x1 = -x1;
        y1 = -y1;
    }

    if (ltZero(x1)) {
        x1 = -x1;
        sign_factor = -1;
    }
    else if (ltZero(y1)) {
        y1 = -y1;
        sign_factor = -1;
    }

    for (j=1; j<=CORDIC_ATAN_ITERATIONS; j++) {
        sigma = le(y1, F2_ZERO) ? 1 : -1;

        angle = j <= CORDIC_ANGLES_LENGTH ? trig_angles[j-1] : mulds(angle, 0.5);

        factor = sigma < 0 ? -poweroftwo : poweroftwo;
        x2 = sub_f64(x1, mul_f64(factor, y1));
        y1 = add_f64(y1, mul_f64(factor, x1));
        x1 = x2;

        theta = sub_f64(theta, sigma < 0 ? -angle : angle);

        poweroftwo = mulds(poweroftwo, 0.5);
    }

    return sign_factor < 0 ? -theta : theta;
}

// Exponential function CORDIC algorithm
float2 exp_iterate(float2 a) {
    float2 ai;
    float2 fx = F2_ONE;
    int i;
    float2 poweroftwo = flt2(0.5);
    int w[CORDIC_LOGEXP_ITERATIONS];
    int x_int;
    float2 z;

    x_int = (int) floor(a.x);

    // Determine the weights.
    z = sub_f64(a, flt2(x_int));

    for (i=0; i<CORDIC_LOGEXP_ITERATIONS; i++) {
        if (lt(poweroftwo, z)) {
            w[i] = 1;
            z = sub_f64(z, poweroftwo);
        }
        else {
            w[i] = 0;
        }
        poweroftwo = mulds(poweroftwo, 0.5);
    }

    // Calculate products
    for (i=0; i<CORDIC_LOGEXP_ITERATIONS; i++) {
        if (w[i]) {
            ai = i < CORDIC_LOGEXP_LENGTH ? logexp[i] : add_f64(F2_ONE, mulds(sub_f64(ai, F2_ONE), 0.5));
            fx = mul_f64(fx, ai);
        }
    }

    // Perform residual multiplication
    float2 z12 = mulds(z, 0.5);
    float2 z13 = mul_f64(z, F2_1_3);
    float2 z14 = mulds(z, 0.25);
    fx = mul_f64(fx, add_f64(F2_ONE, mul_f64(z, add_f64(F2_ONE, mul_f64(z12, add_f64(F2_ONE, mul_f64(z13, add_f64(F2_ONE, z14))))))));

    // Account for factor EXP(X_INT).
    if (x_int < 0) {
        for (i=1; i<=-x_int; i++) {
            fx = mul_f64(fx, F2_1_E);
        }
    }
    else {
        for (i=1; i<=x_int; i++) {
            fx = mul_f64(fx, F2_E);
        }
    }

    return fx;
}

// Natural logarithm CORDIC algorithm
float2 log_iterate(float2 a) {
    float2 ai;
    int i;
    int k = 0;
    float2 poweroftwo = flt2(0.5);
    int w[CORDIC_LOGEXP_ITERATIONS];

    if (le(a, 0.0)) return NAN;

    while (le(F2_E, a)) {
        k++;
        a = mul_f64(a, F2_1_E);
    }

    while (lt(a, F2_ONE)) {
        k--;
        a = mul_f64(a, F2_E);
    }

    // Determine the weights.
    for (i=0; i<CORDIC_LOGEXP_ITERATIONS; i++) {
        w[i] = 0;

        ai = i < CORDIC_LOGEXP_LENGTH ? ai = logexp[i] : add_f64(mulds(sub_f64(ai, F2_ONE), 0.5), F2_ONE);

        if (lt(ai, a)) {
            w[i] = 1;
            a = div_f64(a, ai);
        }
    }

    a = sub_f64(a, F2_ONE);

    float2 x12 = mulds(a, 0.5);
    float2 x13 = mul_f64(a, F2_1_3);
    float2 x14 = mulds(a, 0.25);

    a = mul_f64(a, sub_f64(1.0, mul_f64(x12, add_f64(F2_ONE, mul_f64(x13, sub_f64(F2_ONE, x14))))));

    // Assemble
    for (i=0; i<CORDIC_LOGEXP_ITERATIONS; i++) {
        if (w[i]) a = add_f64(a, poweroftwo);
        poweroftwo = mulds(poweroftwo, 0.5);
    }

    return add_f64(a, flt2(k));
}
