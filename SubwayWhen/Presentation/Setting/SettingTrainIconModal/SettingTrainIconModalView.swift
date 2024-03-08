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
        VStack(alignment: .center, spacing: 15) {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 15, style: .circular)
                    .fill(Color.init(uiColor: UIColor(named: "MainColor") ?? .lightGray))
                    .frame(height: 80)
                
                Rectangle()
                    .fill(Color.init(uiColor: UIColor(named: "AppIconColor") ?? .blue))
                    .frame(height: 5)
                    .padding(.horizontal, 10)
                    .offset(x: 0, y: -5)
            
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .center) {
                        Circle()
                            .stroke(Color.init(uiColor: UIColor(named: "AppIconColor") ?? .blue), lineWidth: 1.0)
                            .background {
                                Circle()
                                    .fill(.white)
                            }
                            .frame(width: 15, height: 15)
                          
                        Spacer()
                        
                        Circle()
                            .stroke(Color.init(uiColor: UIColor(named: "AppIconColor") ?? .blue), lineWidth: 1.0)
                            .background {
                                Circle()
                                    .fill(.white)
                            }
                            .frame(width: 15, height: 15)
                            .overlay {
                                Text(self.viewModel.tappedIcon.rawValue)
                                    .frame(width: 40, height: 40)
                                    .offset(x: 0, y: -12.5)
                            }
                    }
                    .padding(.horizontal, 10)
                    
                    HStack(alignment: .center) {
                        Text("도착역")
                            .font(.system(size: ViewStyle.FontSize.smallSize, weight: .medium))
                        
                        Spacer()
                        
                        Text("전역")
                            .font(.system(size: ViewStyle.FontSize.smallSize, weight: .medium))
                    }
                    .padding(.horizontal, 10)
                }
                .offset(x: 0, y: 5)
            }
            
            HStack(alignment: .center, spacing: 20) {
                ForEach(self.viewModel.trainIcon, id: \.self) { data in
                    Button(action: {
                        self.viewModel.tappedIcon = data
                        
                    }, label: {
                        SettingTrainIconModalSubView(trainIcon: data.rawValue, isTapped: data == viewModel.tappedIcon)
                    })
                }
            }
        }
        Spacer()
    }
}

#Preview {
    SettingTrainIconModalView(viewModel: SettingTrainIconModalSubViewModel())
}
