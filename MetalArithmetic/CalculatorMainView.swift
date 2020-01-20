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
      VStack(spacing: 0){
        Text(controller.answerString).multilineTextAlignment(.trailing).font(.title).foregroundColor(.white).padding().frame(maxWidth: .infinity, maxHeight: 100,alignment: .trailing)
        HStack{
          Text("Metal:").foregroundColor(.gray)
          Text((controller.kernel.type == .metal) ? "Enabled" : "Disabled").foregroundColor((controller.kernel.type == .metal) ? .green : .gray)
        }
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
              CalcButton(action: { self.controller.kernel.addToOperand(value: "7") }, label:"7")
              CalcButton(action: { self.controller.kernel.addToOperand(value: "7") }, label:"8")
              CalcButton(action: { self.controller.kernel.addToOperand(value: "7") }, label:"9")
              CalcButton(action: {}, label:"÷", color: .brown)
            }
            HStack(alignment: .center){
              CalcButton(action: {}, label:"√", color: .brown)
              CalcButton(action: { self.controller.kernel.addToOperand(value: "7") }, label:"4")
              CalcButton(action: { self.controller.kernel.addToOperand(value: "7") }, label:"5")
              CalcButton(action: { self.controller.kernel.addToOperand(value: "7") }, label:"6")
              CalcButton(action: {}, label:"×", color: .brown)
            }
            HStack(alignment: .center){
              CalcButton(action: {}, label:"%", color: .brown)
              CalcButton(action: { self.controller.kernel.addToOperand(value: "7") }, label:"1")
              CalcButton(action: { self.controller.kernel.addToOperand(value: "7") }, label:"2")
              CalcButton(action: { self.controller.kernel.addToOperand(value: "7") }, label:"3")
              CalcButton(action: {}, label:"-",color: .brown)
            }
            HStack(alignment: .center){
              CalcButton(action: {self.controller.kernel.reset()}, label:"CE C", color: .brown)
              CalcButton(action: { self.controller.kernel.addToOperand(value: "7") }, label:"0")
              CalcButton(action: {}, label:".", color: .brown)
              CalcButton(action: {self.controller.kernel.run()}, label:"=", color: .orange)
              CalcButton(action: {}, label:"+", color: .brown)
            }
          }.padding()
        }
      }.background(Color.black)
      }
  }
}

struct CalcButton : View {
  
  var action:()->Void
  var label: String
  var color: Color = .black
  
  var body: some View {
    GeometryReader { reader in
      Button(action: self.action, label: { Text(self.label).foregroundColor(.white).font(.title).frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity,maxHeight: reader.size.width) }).background(Circle().fill(self.color)).frame(maxHeight:reader.size.width)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorMainView()
    }
}

extension Color {
  static var brown: Color {
    return Color(UIColor.brown)
  }
  static var darkGreen: Color {
    return Color(#colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1))
  }
}
