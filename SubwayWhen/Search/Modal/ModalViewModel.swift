//
//  ModalViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import Foundation

import RxSwift
import RxCocoa

class ModalViewModel {
    // OUTPUT
    let modalData : Driver<ResultVCCellData>
    let modalClose : Driver<Void>
    
    // INPUT
    let clickCellData = BehaviorRelay<ResultVCCellData>(value: .init(stationName: "X", lineNumber: "", stationCode: "", useLine: "", lineCode: ""))
    let upDownBtnClick = PublishRelay<Bool>()
    let grayBgClick = PublishRelay<Void>()
    let groupClick = BehaviorRelay<SaveStationGroup>(value: .one)
    let exceptionLastStationText = BehaviorRelay<String?>(value: "")
    
    init(){
        self.modalData = self.clickCellData
            .asDriver(onErrorDriveWith: .empty())
        
        let saveStationInfo = Observable
            .combineLatest(clickCellData, self.groupClick, self.exceptionLastStationText){
                SaveStation(id: UUID().uuidString, stationName: $0.stationName, stationCode: $0.stationCode, updnLine: "", line: $0.lineNumber, lineCode: $0.lineCode, group: $1, exceptionLastStation: $2 ?? "")
            }
        
        let saveStation = self.upDownBtnClick
            .withLatestFrom(saveStationInfo){
                var updown = ""
                if $1.useLine ==  "2호선" {
                    updown = $0 ? "내선" : "외선"
                }else{
                    updown = $0 ? "상행" : "하행"
                }
                FixInfo.saveStation.append(SaveStation(id: $1.id, stationName: $1.stationName, stationCode: $1.stationCode ,updnLine: updown, line: $1.line, lineCode: $1.lineCode, group: $1.group, exceptionLastStation: $1.exceptionLastStation))
                return Void()
            }
        
        self.modalClose = Observable
            .merge(
                self.grayBgClick.asObservable(),
                saveStation
            )
            .asDriver(onErrorDriveWith: .empty())
    }
}
