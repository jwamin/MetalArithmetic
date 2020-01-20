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

enum KernelType {
  case metal
  case cpu
}

enum OperandState {
  case lhs
  case rhs
  case done
}

protocol CalculatorKernel : ObservableObject {
  
  var outputString: String {
    get
  }
  
  var type: KernelType {
    get
  }
  
}

class GPUComputeCalcKernel : CalculatorKernel, ObservableObject {
  
  var device:MTLDevice?
  var computePipelineState: MTLComputePipelineState!
  var commandQueue: MTLCommandQueue!
  
  var type: KernelType = .metal
  
  
  var lhs: String? = nil
  var rhs: String? = nil
  var operation: ArithmeticOperator?
  var operandState: OperandState = .lhs
  
  @Published var outputString: String = "0"
  
  func addToOperand(value:String){
    
    guard let _ = Int(value) else {
      return
    }
    
    switch operandState {
    case .lhs:
      (lhs != nil) ? lhs!.append(value) : (lhs = value);
    case .rhs:
      (rhs != nil) ? rhs!.append(value) : (rhs = value);
    case .done:
      return
    }
    
  }
  
  func addOperation(rawValue:Int){
    let operation = ArithmeticOperator(UInt32(rawValue))
    
    self.operation = operation
    
  }
  
  func run(){

    guard let gotlhs = lhs, let gotrhs = rhs, let gotOperation = operation else {
      return
    }
    
    var answerString = ""
    
    switch gotOperation.rawValue{
    case 0:
      answerString = "\(Int(gotlhs)!+Int(gotrhs)!)"
    default:
      reset()
      return
    }
    
    //cpu to test
    outputString = answerString
    
    operandState = .done
    
  }
  
  func reset(){
    rhs = nil
    lhs = nil
    operation = nil
    operandState = .lhs
    outputString = "0"
  }
  
  init(device:MTLDevice?){
    
    guard let device = device else {
      type = .cpu
      performAddition()
      return
    }
    
    self.device = device
    commandQueue = device.makeCommandQueue()
    let metalLibrary = device.makeDefaultLibrary()
    let kFunction = metalLibrary?.makeFunction(name: "kernel_main")!
    
    computePipelineState = try! device.makeComputePipelineState(function: kFunction!)
    
    performAddition()
    
  }
  
  private func performAddition(){
    switch(type){
    case .cpu:
      outputString = "\(4+6) on CPU"
    case .metal:
      commitMetalCompute()
    }
  }
  
  private func commitMetalCompute(){
    
    var commandBuffer = commandQueue?.makeCommandBuffer()
    
    let encoder = commandBuffer?.makeComputeCommandEncoder()
    
    encoder?.setComputePipelineState(computePipelineState)
    
    var lhs: UnsafeRawPointer = Float(4).pointer
    
    encoder?.setBytes(lhs, length: MemoryLayout<Float>.stride, index: 0)
    
    var rhs: UnsafeRawPointer = Float(6).pointer
    
    encoder?.setBytes(rhs, length: MemoryLayout<Float>.stride, index: 1)

    var outBuffer = device!.makeBuffer(length: MemoryLayout<Float>.size, options: .storageModeShared)!
    
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
        self.outputString = "Answer from gpu: \(fl)"
      }
    })
    commandBuffer?.commit()
    commandBuffer?.waitUntilCompleted()

    
  }
  
}

class CPUComputeKernel : CalculatorKernel, ObservableObject {
  
  @Published var outputString: String = "0"
  let type: KernelType = .cpu
  init () { }
  
}


class ComputeController : ObservableObject {
  
  //refactor to use opaque return type, surely
  @ObservedObject var kernel: GPUComputeCalcKernel

  var answerString: String {
    return self.kernel.outputString
  }
  
  init() {
    
    kernel = ComputeController.getKernel()
    


    var op: ArithmeticOperator = ArithmeticOperator(rawValue:0)
    
    switch op.rawValue {
    case 0:
      print("addition")
    default:
      print("something else")
    }

    kernel.objectWillChange.sink { _ in
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

