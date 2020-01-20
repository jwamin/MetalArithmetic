//
//  ComputeShaders.metal
//  MetalArithmetic
//
//  Created by Joss Manger on 1/20/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

kernel void kernel_main(const device float* left [[buffer(0)]], const device float* right [[buffer(1)]], device float* results){
  
  *results = *right + *left;
  
}
