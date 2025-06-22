import numpy as np
from numba import njit
from numba.core.types import UniTuple, float64, uint8, uint32
from numpy import typing as npt

from mandelbrot.domain import ColorMap, MandelbrotComputerInterface


class MandelbrotComputer(MandelbrotComputerInterface):
    def compute(
        self,
        width: int,
        height: int,
        x_range: tuple[float, float],
        y_range: tuple[float, float],
        cutoff: int,
        colors: ColorMap,
    ) -> npt.NDArray[np.uint8]:
        divergence = compute_mandelbrot(width, height, x_range, y_range, cutoff)
        return apply_colormap(divergence, cutoff, colors)


@njit(
    uint32(float64, float64, uint32),
    fastmath=True,
    nogil=True,
    inline="always",
    boundscheck=False,
)
def mandelbrot(x: float, y: float, cutoff: int) -> int:
    """Compute the margins of the mandelbrot set"""
    z = 0 + 0j
    c = x + y * 1j
    iterations = 0
    while iterations < cutoff and abs(z) <= 2:
        z = z**2 + c
        iterations += 1
    # The first iteration could be considered the zeroth, as z will always be 0
    # in that iteration, so the loop will be executed at least once.
    return iterations - 1


@njit(
    uint32[:, ::1](uint32, uint32, UniTuple(float64, 2), UniTuple(float64, 2), uint32),
    fastmath=True,
    boundscheck=False,
)
def compute_mandelbrot(
    width: int, height: int, x: tuple[float, float], y: tuple[float, float], cutoff: int
) -> npt.NDArray[np.uint32]:
    divergence = np.zeros((width, height), dtype=np.uint32)
    x_scale = abs(x[0] - x[1]) / width
    y_scale = abs(y[0] - y[1]) / height

    for i in range(width):
        for j in range(height):
            divergence[i][j] = mandelbrot(
                x[0] + i * x_scale, y[0] + j * y_scale, cutoff
            )
    return divergence


@njit(
    uint8[:, :, ::1](uint32[:, ::1], uint32, uint8[:, ::1]),
    fastmath=True,
    boundscheck=False,
)
def apply_colormap(
    divergence: npt.NDArray[np.uint32],
    cutoff: int,
    colormap: list[tuple[float, float, float]],
):
    conv = np.floor(divergence / cutoff * len(colormap)).astype(np.uint32)
    n, m = conv.shape
    pixels = np.zeros((n, m, 3), dtype=np.uint8)
    for i in range(n):
        for j in range(m):
            pixels[i, j, :] = colormap[conv[i][j]]
    return pixels
