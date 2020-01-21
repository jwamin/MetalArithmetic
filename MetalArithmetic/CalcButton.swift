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
  var color: Color = .black
  @State var isEnabled: Bool = false
  
  var body: some View {
    GeometryReader { reader in
      Button(action: self.action, label: { Text(self.label).foregroundColor(.white).font(.title)
        .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity,maxHeight: reader.size.width) }).disabled(!self.isEnabled)
        .background( (self.color != .black) ? AnyView(Circle().fill(self.color)) : AnyView(Circle().stroke(style: StrokeStyle(lineWidth: 1)).stroke(Color.white)))
        .frame(maxHeight:reader.size.width).overlay( (!self.isEnabled) ? AnyView(Cross().stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round)).fill(Color.red).opacity(0.5)) : AnyView(EmptyView()))
    }
  }
}

struct CalcButton_Previews: PreviewProvider {
    static var previews: some View {
      CalcButton(action: {}, label: "B",color: .darkGreen)
    }
}
