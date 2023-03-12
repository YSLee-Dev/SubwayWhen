//
//  Coordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import Foundation

protocol Coordinator : AnyObject{
    var childCoordinator : [Coordinator] {get set}
    
    func start()
}
