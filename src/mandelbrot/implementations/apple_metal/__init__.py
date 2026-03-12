import struct
import subprocess
from pathlib import Path

import Metal
import numpy as np
import pymetal as pm
from pymetal.compute import ComputeCommandEncoder
from pymetal.shader import ShaderPreprocessor

from mandelbrot.domain import ColorMap, MandelbrotComputerInterface, Pixels
from mandelbrot.implementations.pure import apply_colormap


class MetalDevice:
    def __init__(self):
        module_root = Path(__file__).parent
        preprocessor = ShaderPreprocessor()
        preprocessor.add_include_path(module_root)
        preprocessor.add_include_path(
            "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
        )
        # self.device = Metal.MTLCreateSystemDefaultDevice()
        self.device = pm.create_system_default_device()
        self.queue = self.device.new_command_queue()
        # self.queue = self.device.newCommandQueue()

        # source = preprocessor.process('#include <f64.h>\n#include <f64fnc.h>\n#include <c64.h>\n')
        # print(source)
        # with open(Path(__file__).parent / 'c64.metal') as f:
        #     # source = preprocessor.process(f.read())
        #     library = self.device.newLibraryWithSource(f.read())
        with open(Path(__file__).parent / "mandelbrot.metal") as f:
            # source = preprocessor.process(f.read())
            library = self.device.new_library_with_source(f.read())
        # print(source)
        function = library.new_function("mandelbrot")
        self.pipeline = self.device.new_compute_pipeline_state(function)


class AppleGPU:
    def __init__(self):
        self.device = Metal.MTLCreateSystemDefaultDevice()

    def new_buffer(self, size: int):
        return self.device.newBufferWithLength_options_(
            size, Metal.MTLResourceStorageModeShared
        )


class MandelbrotShader:
    def __init__(self, device):
        self.device = device
        self.library, err = device.newLibraryWithURL_error_(self.compile_shader(), None)
        if err:
            raise err
        self.compute_mandelbrot = self.create_pipeline("compute_mandelbrot")
        self.apply_colormap = self.create_pipeline("apply_colormap")

    def create_pipeline(self, function_name: str):
        func = self.library.newFunctionWithName_(function_name)
        pipeline, err = self.device.newComputePipelineStateWithFunction_error_(
            func, None
        )
        if err:
            raise err
        return pipeline

    @staticmethod
    def compile_shader():
        vendor_path = Path(__file__).parent / "vendor" / "Metal64" / "Metal64" / "Metal"
        module_root = Path(__file__).parent

        library_name = "mandelbrot.metallib"
        result = subprocess.run(
            [
                # "echo",
                "xcrun",
                "-sdk",
                "macosx",
                "metal",
                # "-dynamiclib",
                "-I",
                vendor_path,
                # "./vendor/Metal64/Metal64/Metal/*.metal",
                *vendor_path.glob("*.metal"),
                module_root / "mandelbrot.metal",
                "-o",
                module_root / library_name,
                "-install_name",
                library_name,
                "-fdollars-in-identifiers",
                "-fmetal-enable-logging",  # TODO: Remove
            ],
            check=True,
        )
        # if result.returncode != 0:
        #     raise subprocess.CalledProcessError(result.returncode, result.stdout, result.stderr)
        return module_root / library_name

    @staticmethod
    def thread_size_configuration(array_length: int, func):
        grid_size = Metal.MTLSizeMake(array_length, 1, 1)

        thread_group_size = func.maxTotalThreadsPerThreadgroup()
        if thread_group_size > array_length:
            thread_group_size = array_length
        thread_group_size = Metal.MTLSizeMake(thread_group_size, 1, 1)
        return grid_size, thread_group_size


# xcrun -sdk macosx metal -dynamiclib *.metal -o mandelbrot.metallib -install_name mandelbrot.metallib
#  xcrun -sdk macosx metal -dynamiclib -I ./vendor/Metal64/Metal64/Metal mandelbrot.metal ./vendor/Metal64/Metal64/Metal/*.metal  -o mandelbrot.metallib -install_name mandelbrot.metallib

# xcrun -sdk macosx metal -c *.metal
#  xcrun -sdk macosx metal -o mandelbrot.metallib *.air


def double_to_f64_bytes(value: float) -> bytes:
    """Convert a Python float to the f64 (double-float) representation: two float32s."""
    hi = np.float32(value)
    lo = np.float32(value - float(hi))  # residual
    return struct.pack("ff", hi, lo)  # float2 = two floats = 8 bytes


class MandelbrotComputer(MandelbrotComputerInterface):
    def __init__(self):
        self.gpu = AppleGPU()
        self.shader = MandelbrotShader(self.gpu.device)
        # self.gpu = MetalDevice()
        self.queue = self.gpu.device.newCommandQueue()

        self._buffer_divergence = None
        self._divergence = None

    def to_be_continued(self):
        # Create GPU buffers
        a_buffer = device.new_buffer(a.nbytes, pm.ResourceStorageModeShared)
        b_buffer = device.new_buffer(b.nbytes, pm.ResourceStorageModeShared)
        c_buffer = device.new_buffer(a.nbytes, pm.ResourceStorageModeShared)

        # Upload data (zero-copy)
        np.copyto(np.frombuffer(a_buffer.contents(), dtype=np.float32), a)
        np.copyto(np.frombuffer(b_buffer.contents(), dtype=np.float32), b)

        # Execute on GPU
        cmd_buffer = self.queue.command_buffer()
        encoder = cmd_buffer.compute_command_encoder()
        encoder.set_compute_pipeline_state(pipeline)
        encoder.set_buffer(a_buffer, 0, 0)
        encoder.set_buffer(b_buffer, 0, 1)
        encoder.set_buffer(c_buffer, 0, 2)
        encoder.dispatch_threadgroups(16, 1, 1, 64, 1, 1)
        encoder.end_encoding()
        cmd_buffer.commit()
        cmd_buffer.wait_until_completed()

        # Read result
        result = np.frombuffer(c_buffer.contents(), dtype=np.float32, count=size)
        print(f"First 5 results: {result[:5]}")

    def compute(
        self,
        width: int,
        height: int,
        x_range: tuple[float, float],
        y_range: tuple[float, float],
        cutoff: int,
        colors: ColorMap,
    ) -> Pixels:
        size = width * height

        divergence = self._compute_mandelbrot(width, height, x_range, y_range, cutoff)
        pixels = apply_colormap(divergence.reshape((width, height)), cutoff, colors)
        return pixels

    def _compute_mandelbrot(
        self,
        width: int,
        height: int,
        x_range: tuple[float, float],
        y_range: tuple[float, float],
        cutoff: int,
    ):
        size = width * height
        if self._divergence is None:
            self._divergence = np.empty(size, dtype=np.uint32)

        if self._buffer_divergence is None:
            self._buffer_divergence = self.gpu.new_buffer(self._divergence.nbytes)

        command_buffer = self.queue.commandBuffer()
        encoder = command_buffer.computeCommandEncoder()
        encoder.setComputePipelineState_(self.shader.compute_mandelbrot)

        # int (4 bytes) — matches `device const int&` in the shader
        encoder.setBytes_length_atIndex_(struct.pack("i", width), 4, 0)
        encoder.setBytes_length_atIndex_(struct.pack("i", height), 4, 1)

        # f64 (8 bytes = float2) — matches `device const f64&`
        encoder.setBytes_length_atIndex_(double_to_f64_bytes(x_range[0]), 8, 2)
        encoder.setBytes_length_atIndex_(double_to_f64_bytes(x_range[1]), 8, 3)
        encoder.setBytes_length_atIndex_(double_to_f64_bytes(y_range[0]), 8, 4)
        encoder.setBytes_length_atIndex_(double_to_f64_bytes(y_range[1]), 8, 5)

        # unsigned int (4 bytes) — matches `device const unsigned int&`
        encoder.setBytes_length_atIndex_(struct.pack("I", cutoff), 4, 6)

        # encoder.setBuffer_offset_atIndex_(width, 0, 0)
        # encoder.setBuffer_offset_atIndex_(height, 0, 1)
        # encoder.setBuffer_offset_atIndex_(x_range[0], 0, 2)
        # encoder.setBuffer_offset_atIndex_(x_range[1], 0, 3)
        # encoder.setBuffer_offset_atIndex_(y_range[0], 0, 4)
        # encoder.setBuffer_offset_atIndex_(y_range[1], 0, 5)
        # encoder.setBuffer_offset_atIndex_(cutoff, 0, 6)
        encoder.setBuffer_offset_atIndex_(self._buffer_divergence, 0, 7)
        # encoder.setBuffer_offset_atIndex_(np.uint32(size), 0, 8)
        # size_t (8 bytes) — matches `device const size_t&`
        encoder.setBytes_length_atIndex_(struct.pack("Q", size), 8, 8)
        encoder.dispatchThreadgroups_threadsPerThreadgroup_(
            *self.shader.thread_size_configuration(
                self._divergence.nbytes, self.shader.compute_mandelbrot
            )
        )
        encoder.endEncoding()
        command_buffer.commit()
        command_buffer.waitUntilCompleted()

        return np.frombuffer(
            self._buffer_divergence.contents().as_buffer(count=self._divergence.nbytes),
            dtype=np.uint32,
        )
