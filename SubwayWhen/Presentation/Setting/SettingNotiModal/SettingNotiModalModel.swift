//
//  SettingNotiModalModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/26.
//

import Foundation

import RxSwift

class SettingNotiModalModel: SettingNotiModalModelProtocol{
    func alertIDListSave(data: [String]) {
        FixInfo.saveSetting.alertGroupOneID = data.first ?? ""
        FixInfo.saveSetting.alertGroupTwoID = data.last ?? ""
    }
}
