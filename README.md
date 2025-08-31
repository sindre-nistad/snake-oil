# Snake Oil

Presentation and code for "Snake Oil"

A version of this demonstration was first given in [October 2023 at BouvetOne](https://github.com/sindre-nistad/bouvet-one-2023-oktober-slange-olje) and has since been expanded.

This version is more refined and polished and in English rather than Norwegian.

## Setup

### Demonstration

To run the `mandelbrot` program, you will need
* [`mise`](https://mise.jdx.dev/getting-started.htmlvfox) (or [`vfox`](https://vfox.dev/guides/quick-start.html) or [`asdf`](https://asdf-vm.com/guide/getting-started.html)) to install and manage the runtimes used
* A C compiler
  * Windows
    * [Visual Studio Community 2022](https://visualstudio.microsoft.com/vs/community/)
  * Linux
    * [`gcc`](https://gcc.gnu.org/) or [`llvm`](https://llvm.org/)
  * macOS
    * [`llvm`](https://llvm.org/)

      **NOTE**: The Cython example uses [OpenMP](https://www.openmp.org/) for parallelization which is not supported on the version of Clang Apple ships with the OS.

      Instead, use Homebrew's LLVM; `brew install llvm` and
      ```bash
      export CC=$(brew --prefix llvm)/bin/clang
      export CXX=$(brew --prefix llvm)/bin/clang++
      ```
* [CUDA Toolkit](https://developer.nvidia.com/cuda-toolkit) for the GPU example
  * The demonstration was given using version 12.9 Update 1 for Windows
  * Nvidia have more [information on CUDA and Python](https://developer.nvidia.com/how-to-cuda-python)

```bash
mise trust .
mise install
```

To run the demonstration, I recommend using [`uv`](https://docs.astral.sh/uv/getting-started/installation/) (installed when using `mise`).
The main reason for that, is that some of the demonstration (e.g. Cython and Rust) requires compilation which `uv` is configured to handle "automagically".

```bash
uv run python -m mandelbrot
```

**NOTE**: This will compile _every_ implementation, which may take a little while.
If you want to use a single implementation, you may have to manually adjust `pyproject.toml` to remove the implementation(s) you don't want to use.

#### macOS
Part of the demonstration uses Cython with OpenMP for parallelization.

macOS' LLVM toolchain does not support `-fopenmp`, so we use Homebrew's LLVM toolchain instead.

```bash
brew install llvm
export CC=$(brew --prefix llvm)/bin/clang
export CXX=$(brew --prefix llvm)/bin/clang++
```

#### Debian

```bash
sudo apt-get install -y libpomp-dev
```

#### Using `pip`
Assuming a [virtual environment](https://docs.python.org/3/library/venv.html#creating-virtual-environments) is set up,
running the demonstration can be done by executing

```bash
pip install -e .
python3 -m mandelbrot
```

This will (likely) use pre-compiled packages of the various implementations, which are available on PyPi.

#### Non-CPython implementations

Since `pygame-ce` is currently only pre-compiled for CPython, it will be compiled from source on other implementations of Python.

You will need to install the necessary dependencies as described for [Linux](https://github.com/pygame-community/pygame-ce/wiki/Compiling-on-Linux#1-install-the-dependencies), [macOS](https://github.com/pygame-community/pygame-ce/wiki/Compiling-on-macOS), or [Windows](https://github.com/pygame-community/pygame-ce/wiki/Compiling-on-Windows) on [`pygame-ce`'s wiki](https://github.com/pygame-community/pygame-ce/wiki).


### Presentation

The slides use [Reveal.js](https://revealjs.com) and [`vite`](https://vite.dev) for building / bundling.

To show them locally, run
```bash
cd src/presentation
corepack enable
yarn install
yarn start
```

They are also [served via GitHub Pages](https://sindre-nistad.github.io/snake-oil/).
