//
//  SearchVCActionProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/04.
//

import Foundation

protocol SearchVCActionProtocol: AnyObject {
    func modalPresent(data: searchStationInfo)
    func locationPresent(data: [VicinityTransformData])
    func disposableDetailPush(data: DetailSendModel)
}
