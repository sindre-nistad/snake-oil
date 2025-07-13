# cython: infer_types=True
# distutils: language=c
# cython: boundscheck=False
# cython: cdivision=True
# cython: exceptval=-1

import cython
from cython import double, int, uint
import cython.cimports.numpy as cnp
import numpy as np


cnp.import_array()


@cython.cfunc
@cython.nogil
def mandelbrot(x: double, y: double, cutoff: uint) -> uint:
    """Compute the margins of the mandelbrot set"""
    z = 0 + 0j
    c = x + y * 1j
    iterations: uint = 0
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
)
@cython.ccall
def compute_mandelbrot(
    width: int,
    height: int,
    x: tuple[double, double],
    y: tuple[double, double],
    cutoff: uint,
):
    divergence: uint[:, ::1] = np.zeros((width, height), dtype=np.uint32)

    x_min, x_max = x
    y_min, y_max = y

    x_scale = abs(x_min - x_max) / width
    y_scale = abs(y_min - y_max) / height

    for i in range(width):
        for j in range(height):
            divergence[i, j] = mandelbrot(
                x_min + i * x_scale, y_min + j * y_scale, cutoff
            )
    return divergence


@cython.locals(
    n=int,
    m=int,
    i=int,
    j=int,
)
def apply_colormap(
        divergence: uint[:, ::1],
        cutoff: uint,
        colormap,
):
    color_indices = np.floor(np.asarray(divergence) / cutoff * len(colormap)).astype(np.uint32)
    n, m = color_indices.shape
    pixels = np.zeros((n, m, 3), dtype=np.uint8)
    for i in range(n):
        for j in range(m):
            pixels[i, j, :] = colormap[color_indices[i, j]]
    return pixels
