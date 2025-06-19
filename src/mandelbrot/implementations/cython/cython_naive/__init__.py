from mandelbrot.domain import MandelbrotComputerInterface

try:
    import _compute as _compute
except ImportError:
    from cython_naive import _compute


class CythonMandelbrotComputer(MandelbrotComputerInterface):
    def compute(self, width, height, x_range, y_range, cutoff, colors):
        divergence = _compute.compute_mandelbrot(
            width, height, x_range, y_range, cutoff
        )

        pixels = _compute.apply_colormap(divergence, cutoff, colors)
        return pixels
