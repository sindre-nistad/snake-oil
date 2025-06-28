use ::pyo3::prelude::*;
use ::pyo3::Python;
use ndarray::{Array2, Array3};
use num::complex::{Complex, ComplexFloat};
use numpy::{IntoPyArray, PyArray2, PyArray3, PyArrayMethods};

/// Compute the margins of the mandelbrot set
fn mandelbrot(x: f64, y: f64, cutoff: u32) -> u32 {
    let mut z: Complex<f64> = Complex::new(0.0, 0.0);
    let c = Complex::new(x, y);
    let mut iterations = 0;
    while iterations < cutoff && z.abs() <= 2.0 {
        z = (z * z) + c;
        iterations += 1;
    }
    // The first iteration could be considered the zeroth, as z will always be 0
    // in that iteration, so the loop will be executed at least once.
    iterations - 1
}

#[pyfunction]
fn compute_mandelbrot<'py>(
    py: Python<'py>,
    width: usize,
    height: usize,
    x: (f64, f64),
    y: (f64, f64),
    cutoff: u32,
) -> PyResult<Bound<'py, numpy::PyArray2<u32>>> {
    let mut pixels = Array2::<u32>::zeros((width, height));
    let x_scale = num::abs(x.0 - x.1) / (width as f64);
    let y_scale = num::abs(y.0 - y.1) / (height as f64);

    for i in 0..width {
        for j in 0..height {
            pixels[[i, j]] = mandelbrot(
                x.0 + (i as f64) * x_scale,
                y.0 + (j as f64) * y_scale,
                cutoff,
            )
        }
    }
    Ok(pixels.into_pyarray(py))
}

#[pyfunction]
fn apply_colormap<'py>(
    py: Python<'py>,
    divergence: Bound<'py, PyArray2<u32>>,
    cutoff: u32,
    colormap: Vec<(u8, u8, u8)>,
) -> PyResult<Bound<'py, PyArray3<u8>>> {
    let conv = divergence
        .readonly()
        .as_array()
        .map(|num| (*num as f64 / (cutoff as f64) * (colormap.len() as f64)) as u8);
    let [n, m] = conv.shape() else {
        panic!("Empty divergence matrix")
    };
    let mut pixels = Array3::<u8>::zeros([*n, *m, usize::from(3u8)]);
    for ((i, j), color_index) in conv.indexed_iter() {
        let color = colormap[usize::from(*color_index)];
        pixels[[i, j, 0]] = color.0;
        pixels[[i, j, 1]] = color.1;
        pixels[[i, j, 2]] = color.2;
    }
    Ok(pixels.into_pyarray(py))
}

#[pymodule]
fn _rust_native(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(compute_mandelbrot, m)?)?;
    m.add_function(wrap_pyfunction!(apply_colormap, m)?)?;
    Ok(())
}
