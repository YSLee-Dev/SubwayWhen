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
        Circle()
            .foregroundColor(isTapped ? .init(uiColor: UIColor(named: "ButtonTappedColor") ?? .lightGray) : .init(uiColor: UIColor(named: "MainColor") ?? .lightGray))
            .overlay {
                Text(trainIcon)
                    .font(.system(size: 30))
            }
            .padding(10)
        
    }
}

#Preview {
    SettingTrainIconModalSubView(trainIcon: "🚃", isTapped: true)
}
