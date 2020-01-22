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
    
    switch operandState {
    case .lhs:
      (lhs != nil) ? lhs!.append(value) : (lhs = value);
      outputString = lhs!
    case .rhs:
      (rhs != nil) ? rhs!.append(value) : (rhs = value);
      outputString = rhs!
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
      performOperation()
      case 1:
      performOperation()
      case 2:
      performOperation()
      case 3:
      performOperation()
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
      performOperation()
      return
    }
    
    self.device = device
    commandQueue = device.makeCommandQueue()
    let metalLibrary = device.makeDefaultLibrary()
    let kFunction = metalLibrary?.makeFunction(name: "kernel_main")!
    
    computePipelineState = try! device.makeComputePipelineState(function: kFunction!)
    
    performOperation()
    
  }
  
  private func performOperation(){
    switch(type){
    case .cpu:
      commitCPUCompute()
    case .metal:
      commitMetalCompute()
    }
  }
  
  private func commitCPUCompute(){
    
    guard let gotlhs = lhs, let gotrhs = rhs, let gotOperation = operation, var lhs = Float(gotlhs), var rhs = Float(gotrhs) else {
      print("some error")
      return
    }
    
    /*
     addition = 0,
     subtraction = 1,
     multiplication = 2,
     division = 3
     */
    
    var outputFl:Float = 0.0
    switch gotOperation.rawValue{
    case 0:
      outputFl = lhs + rhs;
    case 1:
      outputFl = lhs - rhs;
    case 2:
      outputFl = lhs * rhs;
    case 3:
      outputFl = lhs / rhs;
    default:
      fatalError()
    }
    
    outputString = "\(outputFl)"
    self.lhs = outputString
    self.rhs = ""
    operandState = .done
    debug()
    
  }
  
  private func commitMetalCompute(){
    
    guard let gotlhs = lhs, let gotrhs = rhs, var gotOperation = operation, var lhs = Float(gotlhs), var rhs = Float(gotrhs) else {
      print("some error")
      return
    }
    
    var commandBuffer = commandQueue?.makeCommandBuffer()
    
    let encoder = commandBuffer?.makeComputeCommandEncoder()
    
    var outBuffer = device!.makeBuffer(length: MemoryLayout<Float>.size, options: .storageModeShared)!
    
    encoder?.setComputePipelineState(computePipelineState)
    encoder?.setBytes(&lhs, length: MemoryLayout<Float>.stride, index: 0)
    encoder?.setBytes(&rhs, length: MemoryLayout<Float>.stride, index: 1)
    encoder?.setBuffer(outBuffer, offset: 0, index: 2)
    encoder?.setBytes(&gotOperation, length: MemoryLayout<Int>.stride, index: 3)
    encoder?.dispatchThreads(MTLSizeMake(1, 1, 1), threadsPerThreadgroup: MTLSizeMake(1, 1, 1))
    
    encoder?.endEncoding()
    
    commandBuffer?.addCompletedHandler({ [weak self] (buffer) in
      
      guard let self = self else {
        return
      }

      let contents = outBuffer.contents()
      let fl = Float(contents.bindMemory(to: Float.self, capacity: 1).pointee)
      DispatchQueue.main.async {
        self.outputString = "Answer from GPU: \(fl)"
        self.lhs = "\(fl)"
        self.rhs = ""
        self.operandState = .done
        self.debug()
      }
      
    })
    
    commandBuffer?.commit()
    commandBuffer?.waitUntilCompleted()

    
  }
  
}
