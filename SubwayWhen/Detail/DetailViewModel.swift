//
//  DetailViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/02.
//

import Foundation

import RxSwift
import RxCocoa

struct DetailViewModel{
    // INPUT
    let detailViewData = PublishRelay<MainTableViewCellData>()
    
    // OUTPUT
    let cellData : Driver<[DetailTableViewSectionData]>
    
    let bag = DisposeBag()
    
    init(){
        self.cellData = self.detailViewData
            .map{
                [DetailTableViewSectionData(sectionName: "", items: [DetailTableViewCellData(id: $0.id, stationCode: $0.stationCode, exceptionLastStation: $0.exceptionLastStation, subWayId: $0.subWayId, upDown: $0.upDown, lineNumber: $0.lineNumber, useLine: $0.useLine, stationName: $0.stationName)])]
            }
            .asDriver(onErrorDriveWith: .empty())
    }
}
