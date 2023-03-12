//
//  ReportCoordinatorDelegate.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import Foundation

protocol ReportCoordinatorDelegate{
    func pop()
    func disappear(reportCoordinator : ReportCoordinator)
}
