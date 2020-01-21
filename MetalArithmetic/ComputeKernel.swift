//
//  ComputeKernel.swift
//  MetalArithmetic
//
//  Created by Joss Manger on 1/20/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

import Metal
import SwiftUI
import Combine

class GPUComputeCalcKernel : CalculatorKernel, ObservableObject {
  
  var device:MTLDevice?
  var computePipelineState: MTLComputePipelineState!
  var commandQueue: MTLCommandQueue!
  
  var type: KernelType = .metal
  
  
  var lhs: String? = nil
  var rhs: String? = nil
  var operation: ArithmeticOperator?
  var operandState: OperandState = .lhs
  
  @Published var outputString: String = "0" {
    didSet{
      print("updated")
      self.objectWillChange.send()
    }
  }
  
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
    print("that worked")
    debug()
  }
  
  func debug(){
    print("debug:")
    print("\(lhs) \(rhs) \(operation) \(operandState) \(outputString)")
  }
  
  func addOperation(rawValue:Int){
    let operation = ArithmeticOperator(UInt32(rawValue))
    
    self.operation = operation
    operandState = .rhs
    debug()
  }
  
  func run(){
    
    guard let gotlhs = lhs, let gotrhs = rhs, let gotOperation = operation else {
      return
    }

    switch gotOperation.rawValue{
    case 0:
      performAddition()
    default:
      reset()
      return
    }
    
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
      operandState = .done
      debug()
    case .metal:
      commitMetalCompute()
    }
  }
  
  private func commitMetalCompute(){
    
    guard let gotlhs = lhs, let gotrhs = rhs, let gotOperation = operation, var lhs = Float(gotlhs), var rhs = Float(gotrhs) else {
      print("some error")
      return
    }
    
    var commandBuffer = commandQueue?.makeCommandBuffer()
    
    let encoder = commandBuffer?.makeComputeCommandEncoder()
    
    encoder?.setComputePipelineState(computePipelineState)
    
    encoder?.setBytes(&lhs, length: MemoryLayout<Float>.stride, index: 0)
    
    encoder?.setBytes(&rhs, length: MemoryLayout<Float>.stride, index: 1)

    var outBuffer = device!.makeBuffer(length: MemoryLayout<Float>.size, options: .storageModeShared)!
    
    encoder?.setBuffer(outBuffer, offset: 0, index: 2)
    
    encoder?.dispatchThreads(MTLSizeMake(1, 1, 1), threadsPerThreadgroup: MTLSizeMake(1, 1, 1))
    
    encoder?.endEncoding()
    
    commandBuffer?.addCompletedHandler({ [weak self] (buffer) in
      
      guard let self = self else {
        return
      }

      let contents = outBuffer.contents()
      let fl = Float(contents.bindMemory(to: Float.self, capacity: 1).pointee)
      DispatchQueue.main.async {
        self.outputString = "Answer from gpu: \(fl)"
        self.operandState = .done
        self.debug()
      }
      
    })
    
    commandBuffer?.commit()
    commandBuffer?.waitUntilCompleted()

    
  }
  
}
