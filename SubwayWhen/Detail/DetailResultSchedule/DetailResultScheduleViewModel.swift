//
//  DetailResultScheduleViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/25.
//

import Foundation

import RxSwift
import RxCocoa

struct DetailResultScheduleViewModel{
    // INPUT
    let scheduleData = PublishRelay<[ResultSchdule]>()
}
