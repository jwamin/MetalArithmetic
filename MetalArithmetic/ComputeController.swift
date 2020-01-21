//
//  ComputeController.swift
//  MetalArithmetic
//
//  Created by Joss Manger on 1/20/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

import Metal
import SwiftUI
import Combine

class ComputeController : ObservableObject {
  
  //refactor to use opaque return type, surely
  @ObservedObject var kernel: GPUComputeCalcKernel

  var answerString: String {
    return self.kernel.outputString
  }
  
  var watcher:AnyCancellable!
  
  init() {
    
    kernel = ComputeController.getKernel()

    watcher = kernel.objectWillChange.sink { _ in
      self.objectWillChange.send()
    }
    
  }
  
  var answer:Float!
  
  static func getKernel() -> GPUComputeCalcKernel {

      guard let device = MTLCreateSystemDefaultDevice(), device.supportsFeatureSet(.iOS_GPUFamily4_v2) else {
         print("no metal")
         let kernel = GPUComputeCalcKernel(device: nil)
         return kernel
       }
       
       return GPUComputeCalcKernel(device: device)
       
  }
  
}



