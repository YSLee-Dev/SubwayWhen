//
//  DetailResultScheduleCoorinatorDelegate.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import Foundation

protocol DetailResultScheduleCoorinatorDelegate{
    func pop()
    func disappear(detailResultScheduleCoordinator : DetailResultScheduleCoordinator)
    func exceptionBtnTap(detailResultScheduleCoordinator : DetailResultScheduleCoordinator)
}
