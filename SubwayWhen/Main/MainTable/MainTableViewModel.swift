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
    let cellData : Driver<[MainTableViewCellData]>
    
    // MODEL
    let mainTableViewFooterViewModel = MainTableViewFooterViewModel()
    
    // INPUT
    let cellClick = PublishRelay<IndexPath>()
    let cellDelete = PublishRelay<MainTableViewCellData>()
    let cellTimeChangeBtnClick = PublishRelay<MainTableViewCellData>()
    
    let resultData = PublishRelay<[MainTableViewCellData]>()
    let refreshOn = BehaviorRelay<Void>(value: Void())
    let editBtnClick = PublishRelay<Bool>()
    
    init(){
        self.cellData = self.resultData
            .asDriver(onErrorDriveWith: .empty())
    }
}
