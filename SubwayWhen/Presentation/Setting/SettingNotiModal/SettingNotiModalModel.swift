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
        guard let one = self.idMatching(id: oneID) else {return Observable<[SettingNotiModalData]>.just([])}
        let oneData = self.saveStationToSettingNotiModalData(data: one)
        
        let twoID = FixInfo.saveSetting.alertGroupTwoID
        guard let two = self.idMatching(id: twoID) else {return Observable<[SettingNotiModalData]>.just([])}
        let twoData = self.saveStationToSettingNotiModalData(data: two)
        
        return Observable.just([oneData, twoData])
    }
}

private extension SettingNotiModalModel {
    func idMatching(id: String) -> SaveStation? {
        FixInfo.saveStation.filter {
            $0.id == id
        }
        .first
    }
    
    func saveStationToSettingNotiModalData(data: SaveStation) -> SettingNotiModalData {
        SettingNotiModalData(
            id: data.id, stationName: data.stationName, useLine: data.useLine, line: data.line, group: data.group
        )
    }
}
