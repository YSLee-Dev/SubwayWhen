//
//  MainTableViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/30.
//

import Foundation

import RxSwift
import RxCocoa

class MainTableViewModel : MainTableViewModelProtocol{
    // OUTPUT
    let cellData : Driver<[MainTableViewSection]>
    
    // MODEL
    let mainTableViewHeaderViewModel : MainTableViewHeaderViewModelProtocol
    let mainTableViewCellModel : MainTableViewArrvialCellModelProtocol
    let mainTableViewGroupModel : MainTableViewGroupCellModelProtocol
    
    // INPUT
    let cellClick = PublishRelay<MainTableViewCellData>()
    let resultData = BehaviorRelay<[MainTableViewSection]>(value: [])
    let refreshOn = PublishRelay<Void>()
    let plusBtnClick = PublishRelay<Void>()
    
    init(
        header : MainTableViewHeaderCellModel = .init(),
        arrival : MainTableViewCellModel = .init(),
        group : MainTableViewGroupCellModel = .init()
    ){
        self.mainTableViewHeaderViewModel = header
        self.mainTableViewCellModel = arrival
        self.mainTableViewGroupModel = group
        
        self.cellData = self.resultData
            .asDriver(onErrorDriveWith: .empty())
    }
}
