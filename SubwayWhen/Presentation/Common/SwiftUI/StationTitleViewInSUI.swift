//
//  StationTitleViewInSUI.swift
//  SubwayWhen
//
//  Created by 이윤수 on 12/2/24.
//

import SwiftUI

struct StationTitleViewInSUI: View {
    let title: String
    let lineColor: String
    let size: CGFloat
    let isFill: Bool
    var fontSize: CGFloat = ViewStyle.FontSize.mediumSize
    
    var body: some View {
        Circle()
            .stroke(Color.init(self.lineColor))
            .fill(self.isFill ? Color.init(self.lineColor) : Color.white)
            .frame(width: self.size, height: self.size)
            .overlay {
                HStack {
                    Spacer()
                    Text(self.title)
                        .foregroundColor(self.isFill ? .white : .black)
                        .multilineTextAlignment(.center)
                        .font(.system(size: self.fontSize, weight: .bold))
                        .lineLimit(3)
                    Spacer()
                }
            }
    }
}


#Preview {
    StationTitleViewInSUI(title: "교대", lineColor: "03호선", size: 75, isFill: false)
}
