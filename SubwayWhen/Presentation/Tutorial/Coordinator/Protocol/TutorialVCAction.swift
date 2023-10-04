//
//  TutorialVCAction.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/10/04.
//

import Foundation

protocol TutorialVCAction: AnyObject {
    func didDisappear()
    func lastBtnTap()
}
