#include <cuComplex.h>

__device__ unsigned int mandelbrot(
    const double x,
    const double y,
    const unsigned int cutoff
) {
    cuDoubleComplex z = make_cuDoubleComplex(0.0, 0.0);
    const cuDoubleComplex c = make_cuDoubleComplex(x, y);
    int iterations = 0;
    while (iterations < cutoff && cuCabs(z) < 2.0) {
        z = cuCadd(cuCmul(z, z), c);
        ++iterations;
    }
    return iterations - 1;
}

__global__ void compute_mandelbrot(
    const int width,
    const int height,
    const double x_0, const double x_1,
    const double y_0, const double y_1,
    const unsigned int cutoff,

    unsigned int *divergence,
    const size_t N
) {
    const unsigned int tid = threadIdx.x + blockIdx.x * blockDim.x;
    const double x_scale = abs(x_0 - x_1) / static_cast<double>(width);
    const double y_scale = abs(y_0 - y_1) / static_cast<double>(height);

    const unsigned int _i = tid % width;
    const unsigned int _j = tid / width;
    divergence[tid] = mandelbrot(
        x_0 + static_cast<double>(_i) * x_scale,
        y_0 + static_cast<double>(_j) * y_scale,
        cutoff
    );
}


__global__ void apply_colormap(
    const unsigned int *divergence,
    const unsigned int cutoff,
    const unsigned char *colormap,
    const size_t N_colormap,
    unsigned char *pixels,
    const size_t N
) {
    const unsigned int tid = threadIdx.x + blockIdx.x * blockDim.x;
    const unsigned char color_index = (divergence[tid] * N_colormap / cutoff);

    pixels[tid + 0 * N] = colormap[color_index + 0 * N_colormap];
    pixels[tid + 1 * N] = colormap[color_index + 1 * N_colormap];
    pixels[tid + 2 * N] = colormap[color_index + 2 * N_colormap];
}
