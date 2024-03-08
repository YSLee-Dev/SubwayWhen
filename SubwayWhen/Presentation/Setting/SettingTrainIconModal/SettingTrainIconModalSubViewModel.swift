//
//  SettingTrainIconModalSubViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2/25/24.
//

import SwiftUI

import Combine

class SettingTrainIconModalSubViewModel: ObservableObject {
    @Published var tappedIcon: SaveTrainIcon = .basic // 초기값
    let trainIcon = SaveTrainIcon.allCases
}
