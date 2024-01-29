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
    func fixDataToGroupData(_ data : [SaveStation]) -> Single<[EditViewCellSection]>{
        var groupOne = EditViewCellSection(sectionName: "출근", items: [])
        var groupTwo = EditViewCellSection(sectionName: "퇴근", items: [])

        for x in data {
            if x.group == .one{
                groupOne.items.append(x)
            }else{
                groupTwo.items.append(x)
            }
        }
        
        return .just([groupOne, groupTwo])
    }
}
