from pathlib import Path

import cupy as cp
import numpy as np
from cuda.core.experimental import Device, LaunchConfig, Program, ProgramOptions, launch

from mandelbrot.domain import ColorMap, MandelbrotComputerInterface, Pixels


class NvidiaGPU:
    def __init__(self):
        self.device = Device()
        self.device.set_current()

    def compile(
        self,
        program: str,
        methods: tuple[str, ...],
    ):
        arch = "".join(f"{i}" for i in self.device.compute_capability)
        program_options = ProgramOptions(
            std="c++17",
            arch=f"sm_{arch}",
            include_path=[
                cp.cuda.get_cuda_path() + "/include",
            ],
        )
        prog = Program(program, code_type="c++", options=program_options)
        module = prog.compile(
            "cubin",
            name_expressions=methods,
        )
        return module


class MandelbrotComputer(MandelbrotComputerInterface):
    def __init__(self):
        self.gpu = NvidiaGPU()
        self.stream = self.gpu.device.create_stream()
        # Tell cuPy to use our GPU stream
        cp.cuda.ExternalStream(int(self.stream.handle), self.gpu.device.device_id).use()

        with open(Path(__file__).parent / "mandelbrot.cu") as f:
            code = f.read()
        module = self.gpu.compile(code, ("compute_mandelbrot", "apply_colormap"))

        self.ker_compute_mandelbrot = module.get_kernel("compute_mandelbrot")
        self.ker_apply_colormap = module.get_kernel("apply_colormap")

    def compute(
        self,
        width: int,
        height: int,
        x_range: tuple[float, float],
        y_range: tuple[float, float],
        cutoff: int,
        colors: ColorMap,
    ) -> Pixels:
        divergence = self._compute_mandelbrot(width, height, x_range, y_range, cutoff)
        pixels = self._apply_colormap(width, height, cutoff, colors, divergence)
        return cp.asnumpy(pixels).reshape((width, height, 3), order="F")

    def _compute_mandelbrot(
        self,
        width: int,
        height: int,
        x_range: tuple[float, float],
        y_range: tuple[float, float],
        cutoff: int,
    ):
        size = width * height

        divergence = cp.empty(size, dtype=cp.uint32)

        launch(
            self.stream,
            self._configuration(size),
            self.ker_compute_mandelbrot,
            width,
            height,
            x_range[0],
            x_range[1],
            y_range[0],
            y_range[1],
            cutoff,
            divergence.data.ptr,
            cp.uint64(size),
        )
        self.stream.sync()
        return divergence

    def _apply_colormap(
        self,
        width: int,
        height: int,
        cutoff: int,
        colors: ColorMap,
        divergence: cp.ndarray,
    ):
        size = len(divergence)

        _colormap = cp.asarray(colors, dtype=cp.uint8).reshape(
            np.prod(colors.shape), order="F"
        )
        pixels = cp.empty(size * 3, dtype=cp.uint8)
        launch(
            self.stream,
            self._configuration(size),
            self.ker_apply_colormap,
            divergence.data.ptr,
            cutoff,
            _colormap.data.ptr,
            cp.uint64(len(colors)),
            pixels.data.ptr,
            cp.uint64(size),
        )
        self.stream.sync()
        return pixels

    @staticmethod
    def _configuration(size: int) -> LaunchConfig:
        block = 256
        grid = (size + block - 1) // block
        return LaunchConfig(grid=grid, block=block)
