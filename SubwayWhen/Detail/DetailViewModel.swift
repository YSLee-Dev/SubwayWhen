//
//  DetailViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/02.
//

import Foundation

import RxSwift
import RxCocoa

class DetailViewModel{
    // MODEL
    let detailModel = DetailModel()
    
    // INPUT
    let detailViewData = PublishRelay<MainTableViewCellData>()
    
    // OUTPUT
    let cellData : Driver<[DetailTableViewSectionData]>
    
    // DATA
    let nowData = PublishRelay<[DetailTableViewSectionData]>()
    
    let bag = DisposeBag()
    
    init(){
        self.cellData = self.nowData
            .asDriver(onErrorDriveWith: .empty())
        
        self.detailViewData
            .map{
                let backNext = self.detailModel.nextAndBackStationSearch(backId: $0.backStationId, nextId: $0.nextStationId)
                return [DetailTableViewSectionData(sectionName: "", items: [DetailTableViewCellData(id: $0.id, stationCode: $0.stationCode, exceptionLastStation: $0.exceptionLastStation, subWayId: $0.subWayId, upDown: $0.upDown, lineNumber: $0.lineNumber, useLine: $0.useLine, stationName: $0.stationName, backStationName: backNext[0], nextStationName: backNext[1])])]
            }
            .bind(to: self.nowData)
            .disposed(by: self.bag)
    }
}
