import numpy as np
import numpy.typing as npt

from mandelbrot.domain import ColorMap, MandelbrotComputerInterface, Pixels


class MandelbrotComputer(MandelbrotComputerInterface):
    def compute(
        self,
        width: int,
        height: int,
        x_range: tuple[float, float],
        y_range: tuple[float, float],
        cutoff: int,
        colors: ColorMap,
    ) -> Pixels:
        divergence = compute_mandelbrot(width, height, x_range, y_range, cutoff)
        pixels = apply_colormap(divergence, cutoff, colors)
        return pixels


@np.vectorize
def mandelbrot(x: np.float64, y: np.float64, cutoff: np.uint32) -> np.uint32:
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


def compute_mandelbrot(
    width: int,
    height: int,
    x: tuple[float, float],
    y: tuple[float, float],
    cutoff: int,
) -> npt.NDArray[np.uint32]:
    x_min, x_max = x
    y_min, y_max = y

    x_scale = abs(x_min - x_max) / width
    y_scale = abs(y_min - y_max) / height

    x_inputs, y_inputs = np.indices((width, height), dtype=np.float64)
    divergence = mandelbrot(
        x_min + x_inputs * x_scale,
        y_min + y_inputs * y_scale,
        cutoff,
    )
    return divergence


def apply_colormap(
    divergence: npt.NDArray[np.uint32],
    cutoff: int,
    colormap: ColorMap,
):
    color_index = (divergence / cutoff * len(colormap)).astype(np.uint32)
    pixels = colormap[color_index]
    return pixels
