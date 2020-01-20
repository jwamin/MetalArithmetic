//
//  ComputeController.swift
//  MetalArithmetic
//
//  Created by Joss Manger on 1/20/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

import Metal
import Combine

protocol CalculatorKernel {
  
  var outputString: String {
    get
  }
  
}


class ComputeController : CalculatorKernel, ObservableObject {
  
  var device:MTLDevice?
  var computePipelineState: MTLComputePipelineState!
  
  var op: ArithmeticOperator = ArithmeticOperator(rawValue:0)
  
  @Published var outputString: String = "0" {
    didSet {
      print("we updated \(outputString)")
    }
  }
  
  init() {
    
    guard let device = MTLCreateSystemDefaultDevice(), device.supportsFeatureSet(.iOS_GPUFamily4_v2) else {
      outputString = "No Metal"
      return
    }
    
    self.device = device
    
    switch op.rawValue {
    case 0:
      print("addition")
    default:
      print("something else")
    }
    
    let commandQueue = device.makeCommandQueue()
    let metalLibrary = device.makeDefaultLibrary()
    let kFunction = metalLibrary?.makeFunction(name: "kernel_main")!
    
    computePipelineState = try! device.makeComputePipelineState(function: kFunction!)
    
    var commandBuffer = commandQueue?.makeCommandBuffer()
    
    let encoder = commandBuffer?.makeComputeCommandEncoder()
    
    encoder?.setComputePipelineState(computePipelineState)
    
    var lhs: UnsafeRawPointer = Float(4).pointer
    
    encoder?.setBytes(lhs, length: MemoryLayout<Float>.stride, index: 0)
    
    var rhs: UnsafeRawPointer = Float(6).pointer
    
    encoder?.setBytes(rhs, length: MemoryLayout<Float>.stride, index: 1)

    var outBuffer = device.makeBuffer(length: MemoryLayout<Float>.size, options: .storageModeShared)!
    
    encoder?.setBuffer(outBuffer, offset: 0, index: 2)
    
    encoder?.dispatchThreads(MTLSizeMake(1, 1, 1), threadsPerThreadgroup: MTLSizeMake(1, 1, 1))
    
    encoder?.endEncoding()
    commandBuffer?.addCompletedHandler({ [weak self] (buffer) in
      
      guard let self = self else {
        return
      }
      
      print(buffer.status == .completed)
      let contents = outBuffer.contents()
      let fl = Float(contents.bindMemory(to: Float.self, capacity: 1).pointee)
      DispatchQueue.main.async {
        self.answer = fl
        self.outputString = "Answer from gpu: \(fl)"
      }
    })
    commandBuffer?.commit()
    commandBuffer?.waitUntilCompleted()


    
  }
  
  var answer:Float!
  
}


extension Float {
  var pointer: UnsafeRawPointer {
    let mutable = UnsafeMutablePointer<Float>.allocate(capacity: 1)
    mutable.initialize(to: self)
    return UnsafeRawPointer(mutable)
  }
  
  var mutablePointer: UnsafeMutableRawPointer {
    let mutable = UnsafeMutablePointer<Float>.allocate(capacity: 1)
    mutable.initialize(to: self)
    return UnsafeMutableRawPointer(mutable)
  }
  
}

