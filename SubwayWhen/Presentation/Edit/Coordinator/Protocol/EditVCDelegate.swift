//
//  EditVCDelegate.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import Foundation

protocol EditVCDelegate: AnyObject {
    func pop()
    func disappear()
    func notSaveCheck()
}
