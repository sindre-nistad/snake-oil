from _rust_native import apply_colormap, compute_mandelbrot

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
        return apply_colormap(divergence, cutoff, [tuple(color) for color in colors])
