//
//  NavigationBarScrollViewInSUI.swift
//  SubwayWhen
//
//  Created by 이윤수 on 8/26/24.
//

import SwiftUI

struct NavigationBarScrollViewInSUI<Contents>: View where Contents: View {

    // MARK: - Properties

    private let title: String
    private let contentsView: () -> Contents
    private let backBtnTapped: (() -> ())?
    private let backBtnIcon: String?
    private var isLargeTitleHidden: Bool = false
    @State private var isSubTitleShow: Bool = false
    @State private var isFirstValue: CGFloat? = nil

    init(title: String, isLargeTitleHidden: Bool = false, backBtnTapped: (() -> ())? = nil, backBtnIcon: String? = nil, @ViewBuilder content: @escaping () -> Contents) {
        self.contentsView = content
        self.title = title
        self.isLargeTitleHidden = isLargeTitleHidden
        self.backBtnTapped = backBtnTapped
        self.backBtnIcon = backBtnIcon
    }

    // MARK: - View

    var body: some View {
        VStack(spacing: 0) {
            NavigationBarInSUI(
                title: self.title,
                isSubTitleShow: self.$isSubTitleShow,
                backBtnIcon: self.backBtnIcon,
                backBtnTapped: self.backBtnTapped
            )

            OffsetScrollViewInSUI {
                VStack(spacing: 0) {
                    if !self.isLargeTitleHidden {
                        HStack {
                            Text(self.title)
                                .font(.system(size: ViewStyle.FontSize.mainTitleSize, weight: .heavy))

                            Spacer()
                        }
                        .offset(y: -7.5)
                    }
                    self.contentsView()
                }
                .padding(.horizontal, ViewStyle.padding.mainStyleViewLR)
            }
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                if self.isFirstValue == nil {
                    self.isFirstValue = value
                } else {
                    if (!self.isSubTitleShow && self.isFirstValue! - 25 >= value) || (self.isSubTitleShow && self.isFirstValue! - 25 < value) {
                        self.isSubTitleShow = !self.isSubTitleShow
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationBarScrollViewInSUI(title: "상세화면", backBtnTapped: {}) {
        Text("123")
    }
}
