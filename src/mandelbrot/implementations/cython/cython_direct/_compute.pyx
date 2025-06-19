# cython: infer_types=True
# distutils: language=c
# cython: boundscheck=False
# cython: cdivision=True
# cython: exceptval=-1

import cython
from cython import double, int, uint, cast, char
from cython.parallel import parallel, prange
import cython.cimports.numpy as cnp


cnp.import_array()


@cython.cfunc
@cython.nogil
def mandelbrot(x: double, y: double, cutoff: uint) -> uint:
    """Compute the margins of the mandelbrot set"""
    z = 0 + 0j
    c = x + y * 1j
    iterations = cython.declare(uint, 0)
    while iterations < cutoff and abs(z) <= 2:
        z = z**2 + c
        iterations += 1
    # The first iteration could be considered the zeroth, as z will always be 0
    # in that iteration, so the loop will be executed at least once.
    return iterations - 1


@cython.locals(
    x_scale=double,
    y_scale=double,
    i=int,
    j=int,
    x_min=double,
    x_max=double,
    y_min=double,
    y_max=double,
    divergence=uint,
)
@cython.ccall
def compute_mandelbrot(
    pixels: char[:, :, :],
    width: int,
    height: int,
    x: tuple[double, double],
    y: tuple[double, double],
    cutoff: uint,
    colormap: char[:, :],
    num_colors: uint,
):
    x_min, x_max = x
    y_min, y_max = y

    x_scale = abs(x_min - x_max) / width
    y_scale = abs(y_min - y_max) / height
    normalization: double = cast(double, num_colors) / cast(double, cutoff)

    with cython.nogil(), parallel():
        for i in prange(width):
            for j in prange(height):
                divergence = mandelbrot(
                    x_min + i * x_scale, y_min + j * y_scale, cutoff
                )
                color_index: char = cast(char, cast(double, divergence) * normalization)
                pixels[i, j, :] = colormap[color_index]
