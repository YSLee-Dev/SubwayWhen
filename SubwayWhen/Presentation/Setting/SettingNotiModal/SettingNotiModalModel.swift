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
    
    func alertIDListLoad() -> Observable<[SettingNotiModalData]> {
        let oneID = FixInfo.saveSetting.alertGroupOneID
        let one = self.idMatching(id: oneID, group: .one)
        let oneData = self.saveStationToSettingNotiModalData(data: one, group: .one)
        
        let twoID = FixInfo.saveSetting.alertGroupTwoID
        let two = self.idMatching(id: twoID, group: .two)
        let twoData = self.saveStationToSettingNotiModalData(data: two, group: .two)
        
        return Observable.just([oneData, twoData])
    }
}

private extension SettingNotiModalModel {
    func idMatching(id: String, group: SaveStationGroup) -> SaveStation? {
        FixInfo.saveStation.filter {
            $0.id == id && $0.group == group
        }
        .first
    }
    
    func saveStationToSettingNotiModalData(data: SaveStation?, group: SaveStationGroup) -> SettingNotiModalData {
        if let data = data {
            return SettingNotiModalData(
                id: data.id, stationName: data.stationName, useLine: data.useLine, line: data.line, group: data.group
            )
        } else {
            return SettingNotiModalData(id: "", stationName: "", useLine: "", line: "", group: group)
        }
        
    }
}
