# Snake Oil

Presentation and code for "Snake Oil"

A version of this demonstration was first given in [October 2023 at BouvetOne](https://github.com/sindre-nistad/bouvet-one-2023-oktober-slange-olje) and has since been expanded.

This version is more refined and polished and in English rather than Norwegian.

## Setup

Uses [`mise`](https://mise.jdx.dev/getting-started.html) and [`uv`](https://docs.astral.sh/uv/getting-started/installation/)

CUDA: https://developer.nvidia.com/cuda-toolkit

### Demonstration

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

### Presentation

The slides use [Reveal.js](https://revealjs.com) and [`vite`](https://vite.dev) for building / bundling.

To show them locally, run
```bash
cd src/presentation
corepack enable
yarn install
yarn start
```
