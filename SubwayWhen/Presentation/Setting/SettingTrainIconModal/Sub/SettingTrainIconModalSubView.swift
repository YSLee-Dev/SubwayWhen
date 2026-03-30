//
//  SettingTrainIconModalSubView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2/25/24.
//

import SwiftUI

struct SettingTrainIconModalSubView: View {
    let trainIcon: String
    let isTapped: Bool
    
    var body: some View {
        Text(self.trainIcon)
            .font(.system(size: 30))
            .padding(10)
            .overlay {
                Circle()
                    .stroke(self.isTapped ? .init(uiColor: UIColor(named: "AppIconColor") ?? .blue) : Color.clear, lineWidth: self.isTapped ? 1.0 : 0.0)
            }
            .background {
                Circle()
                    .foregroundColor(.init(uiColor: UIColor(named: "MainColor") ?? .lightGray))
            }
    }
}

#Preview {
    SettingTrainIconModalSubView(trainIcon: "🚃", isTapped: true)
}
