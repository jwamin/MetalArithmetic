//
//  ContentView.swift
//  MetalArithmetic
//
//  Created by Joss Manger on 1/20/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

import SwiftUI

struct CalculatorMainView: View {
  
  @ObservedObject var controller: ComputeController = ComputeController();
  
    var body: some View {
      ZStack{
        Rectangle().fill(Color.black).frame( maxWidth: .infinity, maxHeight: .infinity).edgesIgnoringSafeArea(.all)
        VStack(alignment:.leading,spacing: 0){
        Text(controller.answerString).multilineTextAlignment(.trailing).font(.largeTitle).foregroundColor(.white).padding().frame(maxWidth: .infinity, maxHeight: 100,alignment: .trailing)
        HStack{
          Text("Metal:").foregroundColor(.gray)
          Text((controller.kernel.type == .metal) ? "ENABLED" : "Disabled").foregroundColor((controller.kernel.type == .metal) ? .green : .gray)
          }.frame(maxWidth: .infinity,alignment: .trailing).padding()
        HStack(alignment: .center,spacing: 0){
          
          VStack(alignment: .center, spacing: 0){
            Spacer()
            HStack(alignment: .top){
              CalcButton(action: {}, label:"M+", color: .darkGreen)
              CalcButton(action: {}, label:"M-", color: .darkGreen)
              CalcButton(action: {}, label:"MR", color: .darkGreen)
              CalcButton(action: {}, label:"MC", color: .darkGreen)
              CalcButton(action: {}, label:"±", color: .darkGreen)
            }
            HStack(alignment: .center){
              CalcButton(action: {}, label:"∆%", color: .brown)
              CalcButton(action: { self.controller.kernel.addToOperand(value: "7") }, label:"7", isEnabled: true)
              CalcButton(action: { self.controller.kernel.addToOperand(value: "8") }, label:"8", isEnabled: true)
              CalcButton(action: { self.controller.kernel.addToOperand(value: "9") }, label:"9", isEnabled: true)
              CalcButton(action: {}, label:"÷", color: .brown)
            }
            HStack(alignment: .center){
              CalcButton(action: {}, label:"√", color: .brown)
              CalcButton(action: { self.controller.kernel.addToOperand(value: "4") }, label:"4", isEnabled: true)
              CalcButton(action: { self.controller.kernel.addToOperand(value: "5") }, label:"5", isEnabled: true)
              CalcButton(action: { self.controller.kernel.addToOperand(value: "6") }, label:"6", isEnabled: true)
              CalcButton(action: {}, label:"×", color: .brown)
            }
            HStack(alignment: .center){
              CalcButton(action: {}, label:"%", color: .brown)
              CalcButton(action: { self.controller.kernel.addToOperand(value: "1") }, label:"1", isEnabled: true)
              CalcButton(action: { self.controller.kernel.addToOperand(value: "2") }, label:"2", isEnabled: true)
              CalcButton(action: { self.controller.kernel.addToOperand(value: "3") }, label:"3", isEnabled: true)
              CalcButton(action: {}, label:"-",color: .brown)
            }
            HStack(alignment: .center){
              CalcButton(action: {self.controller.kernel.reset()}, label:"CE C", color: .brown, isEnabled: true)
              CalcButton(action: { self.controller.kernel.addToOperand(value: "0") }, label:"0", isEnabled: true)
              CalcButton(action: { self.controller.kernel.addToOperand(value: ".") }, label:".", color: .brown, isEnabled: true)
              CalcButton(action: {self.controller.kernel.run()}, label:"=", color: .orange, isEnabled: true)
              CalcButton(action: { self.controller.kernel.addOperation(rawValue: 0) }, label:"+", color: .brown, isEnabled: true)
            }
          }.padding()
        }
      }.background(Color.black)
      }
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorMainView()
    }
}

