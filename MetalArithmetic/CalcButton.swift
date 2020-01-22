//
//  CalcButton.swift
//  MetalArithmetic
//
//  Created by Joss Manger on 1/20/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

import SwiftUI

struct CalcButton : View {
  
  var action:()->Void
  var label: String
  var color: UIColor = .black
  @State var isEnabled: Bool = false
  
  var body: some View {


    
    return GeometryReader { reader in

      return Button(action: self.action, label: {
   
        
        return Text(self.label)
        .foregroundColor(.white)
          .font(.title)
        .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity,maxHeight: reader.size.width) })
        .disabled(!self.isEnabled)
        .background( (self.color != .black) ? AnyView(Circle().fill(Color(self.color)).overlay(self.getGradient(color: self.color, size: reader.size))) : AnyView(Circle().stroke(style: StrokeStyle(lineWidth: 1))
          .stroke(Color.white)))
        .frame(maxHeight:reader.size.width)
      .mask(Circle())
        .overlay( (!self.isEnabled) ?
          AnyView(Cross().stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round)).fill(Color.red).opacity(0.5)) : AnyView(EmptyView()))
    }
  }
  

  func getGradient(color:UIColor, size: CGSize) -> some View {
    
    let offsetDvcisor:CGFloat = 10
    let offsetSize = CGSize(width: size.width/offsetDvcisor, height: size.width/offsetDvcisor)
    let sizeMod:CGFloat = 1.4
  
    let mainColor = Color(color)
    let lightened = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
    let lightenedColor = Color(lightened)
    
    let myGradient = Gradient(stops:
      [Gradient.Stop(color: mainColor, location: 0),
       Gradient.Stop(color: mainColor, location: 0.5),
       Gradient.Stop(color: mainColor, location: 0.5),
       Gradient.Stop(color: lightenedColor, location: 0.7),
       Gradient.Stop(color: mainColor, location: 0.8),
       Gradient.Stop(color: mainColor, location: 1)
    ])
    
    return RadialGradient(gradient: myGradient, center: .center, startRadius: 0, endRadius: size.width*0.9).offset(offsetSize).frame(width: size.width * sizeMod, height: size.width * sizeMod)
  }
 
  
}

struct CalcButton_Previews: PreviewProvider {
    static var previews: some View {
      CalcButton(action: {}, label: "B",color: .darkGreen)
        .previewLayout(.fixed(width: 100, height: 100))
    }
}

