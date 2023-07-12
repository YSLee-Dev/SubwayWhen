//
//  ModalVCActionProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/04.
//

import Foundation

protocol ModalVCActionProtocol: AnyObject {
    func stationSave()
    func disposableDetailPush(data : DetailLoadData)
    func didDisappear()
    func overlap()
    func dismiss()
}
