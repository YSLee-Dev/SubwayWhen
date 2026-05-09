//
//  UpDownExceptionViewInSUI.swift
//  SubwayWhen
//
//  Created by 이윤수 on 4/13/26
//

import SwiftUI

struct UpDownExceptionViewInSUI: View {

    // MARK: - Properties

    private let upDown: String
    private let exceptionLastStation: String
    private let exceptionBtnTapped: () -> Void

    init(upDown: String, exceptionLastStation: String, exceptionBtnTapped: @escaping () -> Void) {
        self.upDown = upDown
        self.exceptionLastStation = exceptionLastStation
        self.exceptionBtnTapped = exceptionBtnTapped
    }

    // MARK: - View

    var body: some View {
        HStack(spacing: 20) {
            MainStyleViewInSUI {
                Text(self.upDown)
                    .foregroundColor(Color(uiColor: .label))
                    .font(.system(size: ViewStyle.FontSize.smallSize, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
            }

            MainStyleViewInSUI {
                Button(action: {
                    self.exceptionBtnTapped()
                }) {
                    HStack {
                        Text(
                            self.exceptionLastStation.isEmpty
                            ? Strings.Detail.noException
                            : "\(self.exceptionLastStation)\(Strings.Detail.exceptionSuffix)"
                        )
                        .foregroundColor(.red)
                        .font(.system(size: ViewStyle.FontSize.smallSize, weight: .medium))

                        if !self.exceptionLastStation.isEmpty {
                            Image(systemName: "arrowtriangle.down")
                                .resizable()
                                .frame(width: 10, height: 10)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(5)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        UpDownExceptionViewInSUI(upDown: "상행", exceptionLastStation: "구파발") {}
        UpDownExceptionViewInSUI(upDown: "하행", exceptionLastStation: "") {}
    }
    .padding()
}
