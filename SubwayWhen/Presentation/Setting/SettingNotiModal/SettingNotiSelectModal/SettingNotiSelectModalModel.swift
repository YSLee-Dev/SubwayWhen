//
//  SettingNotiSelectModalModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/26.
//

import Foundation

import RxSwift

class SettingNotiSelectModalModel: SettingNotiSelectModalModelProtocol {
    func notiSelectList(loadRroup: SaveStationGroup) -> Single<[SaveStation]>  {
        Observable.create{
            let list = FixInfo.saveStation.filter {
                $0.group == loadRroup
            }
            
            $0.onNext(list)
            $0.onCompleted()
            
            return Disposables.create()
        }
        .asSingle()
    }
    
    func saveStationToSectionData(data: [SaveStation]) -> Single<[SettingNotiSelectModalSectionData]> {
        let cellData = data.map {
            SettingNotiSelectModalCellData(id: $0.id, stationName: $0.stationName, updnLine: $0.updnLine, line: $0.line, useLine: $0.useLine)
        }
        
        return Observable.just([SettingNotiSelectModalSectionData(id: UUID().uuidString, items: cellData)])
            .asSingle()
    }
}
