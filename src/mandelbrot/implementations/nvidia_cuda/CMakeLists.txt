cmake_minimum_required(VERSION 3.31)
project(mandelbrot CUDA)

set(CMAKE_CUDA_STANDARD 17)

add_library(mandelbrot STATIC mandelbrot.cu)

set_target_properties(mandelbrot PROPERTIES
        CUDA_SEPARABLE_COMPILATION ON)
