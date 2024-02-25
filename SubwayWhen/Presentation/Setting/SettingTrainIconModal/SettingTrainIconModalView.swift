//
//  SettingTrainIconModalView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2/25/24.
//

import SwiftUI

struct SettingTrainIconModalView: View {
    @ObservedObject var viewModel: SettingTrainIconModalSubViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack(alignment: .center, spacing: 20) {
                ForEach(Array(self.viewModel.trainIcon.enumerated()), id: \.element.self) { index, data in
                    Button(action: {
                        self.viewModel.isTappedIndex = index
                        
                    }, label: {
                        SettingTrainIconModalSubView(trainIcon: data, isTapped: index == viewModel.isTappedIndex)
                    })
                }
            }
        }
    }
}

#Preview {
    SettingTrainIconModalView(viewModel: SettingTrainIconModalSubViewModel())
}
