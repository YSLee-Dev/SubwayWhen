//
//  NavigationBarScrollViewInSUI.swift
//  SubwayWhen
//
//  Created by 이윤수 on 8/26/24.
//

import SwiftUI

struct NavigationBarScrollViewInSUI<Contents>: View where Contents: View {
    private let title: String
    private let contentsView:  () -> Contents
    private let backBtnTapped: (() -> ())?
    @State private var isSubTitleShow: Bool = false
    @State private var isFirstValue: CGFloat? = nil
    
    init(title: String, @ViewBuilder content: @escaping () -> Contents, backBtnTapped: (() -> ())? = nil) {
        self.contentsView = content
        self.title = title
        self.backBtnTapped = backBtnTapped
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if backBtnTapped != nil {
                    Button(action: {
                        
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.init(uiColor: .label))
                        
                    }
                }
                
                Text(self.title)
                    .font(.system(size: ViewStyle.FontSize.largeSize, weight: .bold))      .padding(.leading, 1)
                    .opacity(self.isSubTitleShow ? 1 : 0)
                    .offset(y: self.isSubTitleShow ? 0 : 10)
                    .animation(.spring(response: 0.35, dampingFraction: 0.75, blendDuration: 0), value: self.isSubTitleShow)
                
                Spacer()
            }
            .padding(.top, 10)
            
            OffsetScrollViewInSUI {
                VStack(spacing: 0) {
                    HStack {
                        Text(self.title)
                            .font(.system(size: ViewStyle.FontSize.mainTitleSize, weight: .heavy))
                        
                        Spacer()
                    }
                    self.contentsView()
                }
            }
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                if isFirstValue == nil {
                    self.isFirstValue = value
                } else {
                    self.isSubTitleShow =  isFirstValue! - 32 >= value
                }
            }
        }
        .padding(.horizontal, ViewStyle.padding.mainStyleViewLR)
    }
}

#Preview {
    NavigationBarScrollViewInSUI(title: "홈") {
        Text("123")
    }
}
