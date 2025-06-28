import numpy as np
import numpy.typing as npt

from mandelbrot.colors import Colors

def compute_mandelbrot(
    width: int,
    height: int,
    x: tuple[float, float],
    y: tuple[float, float],
    cutoff: int,
) -> npt.NDArray[np.uint32]: ...
def apply_colormap(
    divergence: npt.NDArray[np.uint32],
    cutoff: int,
    colormap: list[tuple[int, int, int]],
) -> npt.NDArray[np.uint8]: ...
