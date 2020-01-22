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
        VStack(alignment:.leading){
          Text(controller.answerString).multilineTextAlignment(.trailing).font(.largeTitle).foregroundColor(.white).frame(maxWidth: .infinity,alignment: .trailing).padding()
        HStack{
          Text("Metal:").foregroundColor(.gray)
          Text((controller.kernel.type == .metal) ? "ENABLED" : "Disabled").foregroundColor((controller.kernel.type == .metal) ? .green : .gray)
        }.frame(maxWidth: .infinity,alignment: .trailing).padding(.trailing)
        HStack{
          
          VStack(alignment: .center){
            Spacer()
            HStack(alignment: .top){
              CalcButton(action: {}, label:"M+", color: .darkGreen, isEnabled: false)
              CalcButton(action: {}, label:"M-", color: .darkGreen, isEnabled: false)
              CalcButton(action: {}, label:"MR", color: .darkGreen, isEnabled: false)
              CalcButton(action: {}, label:"MC", color: .darkGreen, isEnabled: false)
              CalcButton(action: {}, label:"±", color: .darkGreen, isEnabled: false)
            }
            HStack(alignment: .center){
              CalcButton(action: {}, label:"∆%", color: .brown, isEnabled: false)
              CalcButton(action: { self.controller.kernel.addToOperand(value: "7") }, label:"7")
              CalcButton(action: { self.controller.kernel.addToOperand(value: "8") }, label:"8")
              CalcButton(action: { self.controller.kernel.addToOperand(value: "9") }, label:"9")
              CalcButton(action: { self.controller.kernel.addOperation(rawValue: 3) }, label:"÷", color: .brown)
            }
            HStack(alignment: .center){
              CalcButton(action: {}, label:"√", color: .brown, isEnabled: false)
              CalcButton(action: { self.controller.kernel.addToOperand(value: "4") }, label:"4")
              CalcButton(action: { self.controller.kernel.addToOperand(value: "5") }, label:"5")
              CalcButton(action: { self.controller.kernel.addToOperand(value: "6") }, label:"6")
              CalcButton(action: { self.controller.kernel.addOperation(rawValue: 2) }, label:"×", color: .brown)
            }
            HStack(alignment: .center){
              CalcButton(action: {}, label:"%", color: .brown, isEnabled: false)
              CalcButton(action: { self.controller.kernel.addToOperand(value: "1") }, label:"1")
              CalcButton(action: { self.controller.kernel.addToOperand(value: "2") }, label:"2")
              CalcButton(action: { self.controller.kernel.addToOperand(value: "3") }, label:"3")
              CalcButton(action: { self.controller.kernel.addOperation(rawValue: 1) }, label:"-",color: .brown)
            }
            HStack(alignment: .center){
              CalcButton(action: { self.controller.kernel.reset() }, label:"CE C", color: .brown)
              CalcButton(action: { self.controller.kernel.addToOperand(value: "0") }, label:"0")
              CalcButton(action: { self.controller.kernel.addToOperand(value: ".") }, label:".", color: .brown)
              CalcButton(action: { self.controller.kernel.run() }, label:"=", color: .orange)
              CalcButton(action: { self.controller.kernel.addOperation(rawValue: 0) }, label:"+", color: .brown)
            }
          }.padding()
        }
      }.background(Color.black)
      }
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
      Group{
        CalculatorMainView().environment(\.horizontalSizeClass, .compact)
        CalculatorMainView().previewLayout(.fixed(width: 568, height: 320)) 
        CalculatorMainView().previewDevice(PreviewDevice(rawValue: "iPhone SE")).previewDisplayName("iPhone SE")
      }
    }
}

