//
//  StationTitleViewInSUI.swift
//  SubwayWhen
//
//  Created by 이윤수 on 12/2/24.
//

import SwiftUI

struct StationTitleViewInSUI: View {
    let stationName: String
    let lineColor: String
    let size: CGFloat
    let isFill: Bool
    
    var body: some View {
        Circle()
            .stroke(Color.init(self.lineColor))
            .fill(self.isFill ? Color.init(self.lineColor) : Color.white)
            .frame(width: self.size, height: self.size)
            .overlay {
                HStack {
                    Spacer()
                    Text(self.stationName)
                        .foregroundColor(self.isFill ? .white : .black)
                        .font(.system(size: ViewStyle.FontSize.mediumSize, weight: .bold))
                        .lineLimit(3)
                    Spacer()
                }
            }
    }
}


#Preview {
    StationTitleViewInSUI(stationName: "교대", lineColor: "03호선", size: 75, isFill: false)
}
