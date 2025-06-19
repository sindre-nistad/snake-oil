import glob
import platform
from pathlib import Path

import numpy as np
from Cython.Build import cythonize
from setuptools import Extension, setup


def setup_builder(name: str):
    sources = glob.glob("*.pyx", recursive=True)
    is_windows = platform.system() == "Windows"

    ext_modules = [
        Extension(
            "*",
            sources,
            extra_compile_args=[
                "/openmp:llvm",
            ]
            if is_windows
            else [
                "-fopenmp",
                "-ffast-math",
            ],
            extra_link_args=[
                "/openmp",
            ]
            if is_windows
            else [
                "-lomp",
                "-fopenmp",
            ],
            include_dirs=[
                np.get_include(),
            ],
            define_macros=[
                ("NPY_NO_DEPRECATED_API", "NPY_1_7_API_VERSION"),
            ],
        )
    ]

    setup(
        name=f"mandelbrot.implementations.{name}",
        ext_modules=cythonize(
            ext_modules,
            annotate=True,
        ),
        sources=sources + glob.glob("*.py", recursive=True),
    )


_path = Path(__file__).parent

setup_builder(_path.name)
