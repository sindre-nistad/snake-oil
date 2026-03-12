
The Swift class MetalCompute provides an easy to use interface for passing calculations to a Metal
compute kernel.

# Swift part
## Create a MetalCompute object

Enclose all statements in a do block to handle exceptions.

```
do {
   // Input argument buffers have 10000 elements
   let cnt: Int = 10000

   // Create the MetalCompute object, pass name of compute kernel functions and number of
   // input buffers elements as parameters
   let mc = try MetalCompute("myKernelFnc", cnt)
   
   ... // Pass parameters and execute Metal compute kernel
}
catch {
   print(error)
}
```

## Pass parameters to Metal compute kernel function

```
do {
   // Create an array of 64 bit floating point values as input to the compute function
   let cnt: Int = 10
   let arr: [Float2] = Array(repeating: Float2(Double.pi), cnt)

   // A Float2 value to be added to the array by the compute function
   let x: Float2 = 2.0

   // Create the MetalCompute object, pass name of compute kernel functions and number of
   // input buffers elements as parameters
   let mc = try MetalCompute("myKernelFnc", cnt)

   // Add input buffer and a single value to the MetalCompute object
   try mc.AddBuffer(arr);
   mc.AddValue(x)

   // Execute compute kernel. The compute() method creates a result buffer and initializes it with Float2(0.0)
   if let result = mc.compute(Float2(0.0)) {
      print("Success! Results:")
      for element in result {
         print(element)
      }
   }
   else {
      print("Execution of compute kernel failed")
   }
}
catch {
   print("Error")
}
```

# Metal part

The compute kernel function adds a Float2 value to each element of an Float2 input buffer.

```
#include <metal_stdlib>
#include "f64.h"

using namespace metal;

// The compute kernel function, name must match name specified in MetalCompute(), see Swift part
kernel void myKernelFnc(device const float2 arr, 
                        device const float2& val,
                        device float2 *result,
                        uint index [[ thread_position_in_grid ]])
{
   // Convert input parameters from float2 to f64
   // Add f64 values
   // Write float2 value of result into result buffer
   result[index] = (f64(arr[index]) + f64(val)).v;
}
```


