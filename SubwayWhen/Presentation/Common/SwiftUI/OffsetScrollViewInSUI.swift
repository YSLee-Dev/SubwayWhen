//
//  OffsetScrollViewInSUI.swift
//  SubwayWhen
//
//  Created by 이윤수 on 8/26/24.
//

import SwiftUI

struct OffsetScrollViewInSUI<Contents>: View where Contents: View {
    private let contentsView:  () -> Contents
    
    init(@ViewBuilder  content: @escaping () -> Contents) {
        self.contentsView = content
    }
    
    var body: some View {
        ScrollView {
            self.scrollObservableView
            self.contentsView()
        }
    }
    
    private var scrollObservableView: some View {
        GeometryReader { geo in
            let offsetY = geo.frame(in: .global).origin.y
            Color.clear
                .preference(key: ScrollOffsetKey.self, value: offsetY)
        }
        .frame(height: 0)
    }
}

struct ScrollOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = 0.0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

