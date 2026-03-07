import distutils.compilers.C.msvc
import glob
import os
import platform
import sysconfig
from distutils.compilers.C.msvc import Compiler
from pathlib import Path

import numpy as np
from Cython.Build import cythonize
from setuptools import Extension, setup
from setuptools.command.build_ext import build_ext


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
    # # print('sysconfig', sysconfig)
    PLAT_TO_TARGET = {
        "win32": "x86",
        "win-amd64": "x64",
        "win-arm32": "arm",
        "win-arm64": "arm64",
    }
    suffix = PLAT_TO_TARGET[sysconfig.get_platform()]
    os.environ["DISTUTILS_USE_SDK"] = "1"

    # TODO: Find root of project
    os.environ["path"] = os.path.join(
        r"C:\Users\sindr\PycharmProjects\snake-oil\msvc\autoenv", suffix
    )
    # TODO: Add the appropriate lib and include (small letters) as well from the msvc/vcvars-*.bat file
    #       '%~dp0' can be replaced with the absolute path to the msvc directory

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
