//
//  SettingNotiSelectModalModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/26.
//

import Foundation

import RxSwift

class SettingNotiSelectModalModel: SettingNotiSelectModalModelProtocol {
    func notiSelectList(loadGroup: SaveStationGroup) -> Single<[SaveStation]>  {
        Observable.create{
            let list = FixInfo.saveStation.filter {
                $0.group == loadGroup
            }
            
            $0.onNext(list)
            $0.onCompleted()
            
            return Disposables.create()
        }
        .asSingle()
    }
    
    func saveStationToSectionData(data: [SaveStation], id: String) -> Single<[SettingNotiSelectModalSectionData]> {
        let checkedRow = self.checkedCellIndex(data: data, id: id)
        
        let cellData = data.enumerated().map {
            let isChecked = $0.offset == checkedRow
            
            return SettingNotiSelectModalCellData(id: $0.element.id, stationName: $0.element.stationName, updnLine: $0.element.updnLine, line: $0.element.line, useLine: $0.element.useLine, isChecked: isChecked)
        }
        
        return Observable.just([SettingNotiSelectModalSectionData(id: UUID().uuidString, items: cellData)])
            .asSingle()
    }
    
    private func checkedCellIndex(data: [SaveStation], id: String) -> Int? {
        var row: Int? = nil
        
        for item in data.enumerated() {
            if item.element.id == id {
                row = item.offset
                break
            }
        }
        return row
    }
}
