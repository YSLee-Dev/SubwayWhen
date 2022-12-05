//
//  ModalViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import Foundation

import RxSwift
import RxCocoa

struct ModalViewModel {
    // OUTPUT
    let modalData : Driver<searchStationInfo>
    let modalClose : Driver<Void>
    
    // INPUT
    let clickCellData = BehaviorRelay<searchStationInfo>(value: searchStationInfo(stationName: "NOT", lineNumber: .not, stationCode: ""))
    let upDownBtnClick = PublishRelay<Bool>()
    let grayBgClick = PublishRelay<Void>()
    let groupClick = BehaviorRelay<SaveStationGroup>(value: .one)
    let exceptionLastStationText = PublishRelay<String?>()
    
    init(){
        self.modalData = self.clickCellData
            .asDriver(onErrorDriveWith: .empty())
        
        self.modalClose = Observable
            .merge(
                self.upDownBtnClick.map{_ in Void()},
                self.grayBgClick.asObservable()
            )
            .asDriver(onErrorDriveWith: .empty())
    }
}
