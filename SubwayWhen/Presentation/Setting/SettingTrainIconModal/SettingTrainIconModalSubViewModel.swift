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
    
    let trainIcon: [[SaveTrainIcon]] = SaveTrainIcon.allCases.reduce([]) { result, data in
        var newResult = result
        if newResult.isEmpty || newResult.last?.count == 4 {
            newResult.append([data])
        } else {
            newResult[newResult.count - 1].append(data)
        }
        return newResult
    }
}
