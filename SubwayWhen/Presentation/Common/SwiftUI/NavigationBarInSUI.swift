//
//  NavigationBarInSUI.swift
//  SubwayWhen
//
//  Created by 이윤수 on 4/11/26
//

import SwiftUI

struct NavigationBarInSUI: View {

    // MARK: - Properties

    private let title: String
    private let backBtnTapped: (() -> ())?
    private let backBtnIcon: String?
    @Binding private var isSubTitleShow: Bool

    init(title: String, isSubTitleShow: Binding<Bool>, backBtnIcon: String? = nil,  backBtnTapped: (() -> ())? = nil) {
        self.title = title
        self._isSubTitleShow = isSubTitleShow
        self.backBtnTapped = backBtnTapped
        self.backBtnIcon = backBtnIcon
    }

    // MARK: - View

    var body: some View {
        HStack {
            if self.backBtnTapped != nil {
                Button(action: {
                    self.backBtnTapped!()
                }) {
                    Image(systemName: "\(self.backBtnIcon ?? "")")
                        .foregroundColor(.init(uiColor: .label))
                }
            }

            Text(self.title)
                .font(.system(size: ViewStyle.FontSize.largeSize, weight: .bold))
                .padding(.leading, 1)
                .opacity(self.isSubTitleShow ? 1 : 0)
                .offset(y: self.isSubTitleShow ? 0 : 7.5)
                .animation(.smooth(duration: 0.25), value: self.isSubTitleShow)

            Spacer()
        }
        .frame(height: 45)
        .padding(.horizontal, ViewStyle.padding.mainStyleViewLR)
    }
}

#Preview {
    @Previewable @State var isShow = false
    NavigationBarInSUI(title: "상세화면", isSubTitleShow: $isShow, backBtnTapped: {})
}
