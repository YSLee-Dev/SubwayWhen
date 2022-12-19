//
//  EditViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/19.
//

import Foundation

import RxSwift
import RxCocoa

struct EditViewModel{
    
    // INPUT
    // let deleteCell = PublishRelay<EditViewCell>()
    // let moveCell = PublishRelay<IndexPath>()
    
    // OUTPUT
    let cellData : Driver<[EditViewCellData]>
    
    init(){
        self.cellData = Observable.from(FixInfo.saveStation)
            .map{
                EditViewCellData(id: $0.id, stationName: $0.stationName, updnLine: $0.updnLine, line: $0.line)
            }
            .toArray()
            .asDriver(onErrorDriveWith: .empty())
    }
}
