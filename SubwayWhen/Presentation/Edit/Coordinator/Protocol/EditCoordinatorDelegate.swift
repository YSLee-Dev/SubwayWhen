//
//  EditCoordinatorDelegate.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import Foundation

protocol EditCoordinatorDelegate{
    func pop()
    func disappear(editCoordinatorDelegate : EditCoordinator)
}
