cmake_minimum_required(VERSION 3.31)
project(mandelbrot C)

set(CMAKE_C_STANDARD 17)


find_package(
        Python REQUIRED COMPONENTS Interpreter Development NumPy
)

include_directories(${Python_INCLUDE_DIRS} ${Python_NumPy_INCLUDE_DIRS})
add_library(mandelbrot STATIC _compute.c)

target_include_directories(mandelbrot PRIVATE ${Python_INCLUDE_DIRS})
