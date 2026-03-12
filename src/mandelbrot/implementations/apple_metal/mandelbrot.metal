#include <metal_stdlib>
# include "c64.h"
using namespace metal;


uint mandelbrot(
                       const f64 x,
                       const f64 y,
                       const uint cutoff
) {
    c64 z = c64(0.0, 0.0);
    const c64 c = c64(x, y);

    uint iterations = 0;
    while (iterations < cutoff && abs(z) < 2.0) {
        z = z * z + c;
        iterations += 1;
    }
    return iterations;
}


kernel void compute_mandelbrot(
    device const int& width,
    device const int& height,
    device const f64& x_0, device const f64& x_1,
    device const f64& y_0, device const f64& y_1,
    device const unsigned int& cutoff,

    device unsigned int *divergence,
    device const size_t& N,
    uint tid [[thread_position_in_grid]]
) {
    //const unsigned int tid = threadIdx.x + blockIdx.x * blockDim.x;
    const f64 x_scale = abs(x_0 - x_1) / static_cast<f64>(width);
    const f64 y_scale = abs(y_0 - y_1) / static_cast<f64>(height);

    const unsigned int _i = tid % width;
    const unsigned int _j = tid / width;

    divergence[tid] = mandelbrot(
        x_0 + static_cast<f64>(_i) * x_scale,
        y_0 + static_cast<f64>(_j) * y_scale,
        cutoff
    );
}

kernel void apply_colormap(
    device const unsigned int* divergence,
    device const unsigned int& cutoff,
    device const unsigned char* colormap,
    device const size_t& N_colormap,
    device unsigned char* pixels,
    device const size_t& N,
   uint tid [[thread_position_in_grid]]
) {
//    const unsigned int tid = threadIdx.x + blockIdx.x * blockDim.x;
    const unsigned char color_index = (divergence[tid] * N_colormap / cutoff);

    pixels[tid + 0 * N] = colormap[color_index + 0 * N_colormap];
    pixels[tid + 1 * N] = colormap[color_index + 1 * N_colormap];
    pixels[tid + 2 * N] = colormap[color_index + 2 * N_colormap];
}
