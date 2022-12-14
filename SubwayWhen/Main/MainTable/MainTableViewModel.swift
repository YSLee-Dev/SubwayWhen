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
    let mainTableViewFooterViewModel = MainTableViewFooterViewModel()
    let mainTableViewCellModel = MainTableViewCellModel()
    
    // INPUT
    let cellClick = PublishRelay<IndexPath>()
    let cellDelete = PublishRelay<IndexPath>()
    
    let resultData = PublishRelay<[MainTableViewSection]>()
    let refreshOn = PublishRelay<Void>()
    let editBtnClick = PublishRelay<Bool>()
    
    init(){
        self.cellData = self.resultData
            .asDriver(onErrorDriveWith: .empty())
    }
}
