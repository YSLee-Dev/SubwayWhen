//
//  MainTableViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/30.
//

import Foundation

import RxSwift
import RxCocoa

struct MainTableViewModel{
    // OUTPUT
    let cellData : Driver<[MainTableViewSection]>
    
    // MODEL
    let mainTableViewHeaderViewModel = MainTableViewHeaderCellModel()
    let mainTableViewCellModel = MainTableViewCellModel()
    let mainTableViewGroupModel = MainTableViewGroupCellModel()
    
    // INPUT
    let cellClick = PublishRelay<MainTableViewCellData>()
    let resultData = BehaviorRelay<[MainTableViewSection]>(value: [])
    let refreshOn = PublishRelay<Void>()
    let plusBtnClick = PublishRelay<Void>()
    
    init(){
        self.cellData = self.resultData
            .asDriver(onErrorDriveWith: .empty())
    }
}
