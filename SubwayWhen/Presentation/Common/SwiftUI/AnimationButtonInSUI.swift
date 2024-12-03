//
//  AnimationButtonInSUI.swift
//  SubwayWhen
//
//  Created by 이윤수 on 12/2/24.
//

import SwiftUI

struct AnimationButtonInSUI<Contents>: View where Contents: View {
    enum alignment {
        case leading
        case center
        case trailing
    }
    
    var bgColor: Color = Color("MainColor")
    var tappedBGColor: Color = Color("ButtonTappedColor")
    var buttonViewAlignment: alignment = .center
    @ViewBuilder let buttonView: () -> Contents
    let tappedAction: () -> Void
    
    @State private var isTapped = false
    
    var body: some View {
        HStack {
            if self.buttonViewAlignment != .leading {
                Spacer()
            }
            self.buttonView()
            if self.buttonViewAlignment != .trailing {
                Spacer()
            }
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onLongPressGesture(
            pressing: {
                    if !self.isTapped && $0  {
                        self.isTapped.toggle()
                    } else if self.isTapped && !$0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.isTapped.toggle()
                            self.tappedAction()
                        }
                    }
                },
                perform: {}
            )
            .background(
                RoundedRectangle(cornerRadius: ViewStyle.Layer.radius)
                    .fill(self.isTapped ? self.tappedBGColor : self.bgColor)
            )
            .scaleEffect(self.isTapped ? ViewStyle.AnimateView.size : 1)
            .animation(.easeInOut(duration: ViewStyle.AnimateView.speed), value: self.isTapped)
    }
}

#Preview {
    AnimationButtonInSUI(bgColor: Color("MainColor"), tappedBGColor: Color("ButtonTappedColor"), buttonView: {Text("버튼").foregroundStyle(.black)}) {}
}
