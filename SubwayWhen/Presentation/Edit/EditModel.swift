//
//  EditModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/21.
//

import Foundation

import RxSwift

class EditModel : EditModelProtocol{
    // FixInfo에서 그룹별 데이터로 변환
    func fixDataToGroupData() -> Single<[EditViewCellSection]>{
        let fixData = FixInfo.saveStation
        var groupOne = EditViewCellSection(sectionName: "출근", items: [])
        var groupTwo = EditViewCellSection(sectionName: "퇴근", items: [])

        for x in fixData {
            if x.group == .one{
                groupOne.items.append(.init(id: x.id, stationName: x.stationName, updnLine: x.updnLine, line: x.line, useLine: x.useLine))
            }else{
                groupTwo.items.append(.init(id: x.id, stationName: x.stationName, updnLine: x.updnLine, line: x.line, useLine: x.useLine))
            }
        }
        
        return .just([groupOne, groupTwo])
    }
}
