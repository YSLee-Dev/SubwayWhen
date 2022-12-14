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
    let modalData : Driver<ResultVCCellData>
    let modalClose : Driver<Void>
    
    // INPUT
    let clickCellData = BehaviorRelay<ResultVCCellData>(value: .init(stationName: "X", lineNumber: "", stationCode: "", useLine: "", lineCode: ""))
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
