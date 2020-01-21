//
//  Extensions.swift
//  MetalArithmetic
//
//  Created by Joss Manger on 1/20/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

import SwiftUI

//Helpers

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

//Extensions

extension Color {
  static var brown: Color {
    return Color(UIColor.brown)
  }
  static var darkGreen: Color {
    return Color(#colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1))
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


struct Cross : Shape {
  
  func path(in rect: CGRect) -> Path {
    var path = Path()
    
    let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
    
    let topRight = CGPoint(x: rect.maxX, y: 0)
    let bottomLeft = CGPoint(x: 0, y: rect.maxY)
    
    path.move(to: .zero)
    path.addLine(to:bottomRight)
    
    path.move(to: topRight)
    path.addLine(to: bottomLeft)
    path.stroke(Color.red)
    return path
    
  }
  
}
