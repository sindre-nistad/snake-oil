import numpy as np

from mandelbrot.domain import MandelbrotComputerInterface

try:
    import _compute as _compute
except ImportError:
    from cython_direct import _compute


class CythonMandelbrotComputer(MandelbrotComputerInterface):
    def compute(self, width, height, x_range, y_range, cutoff, colors):
        pixels = np.ndarray((width, height, 3), dtype=np.uint8)
        _compute.compute_mandelbrot(
            pixels, width, height, x_range, y_range, cutoff, colors, len(colors)
        )

        return pixels
