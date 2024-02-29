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
            .stroke(isTapped ? .init(uiColor: UIColor(named: "AppIconColor") ?? .blue) : Color.clear, lineWidth: isTapped ? 1.0 : 0.0)
            .background {
                Circle()
                    .foregroundColor(.init(uiColor: UIColor(named: "MainColor") ?? .lightGray))
            }
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
