//
//  ModalViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import Foundation

import RxSwift
import RxCocoa
import RxOptional

class ModalViewModel {
    // MODEL
    let model = ModalModel()
    
    // OUTPUT
    let modalData : Driver<ResultVCCellData>
    let modalClose : Driver<Void>
    
    // INPUT
    let clickCellData = PublishRelay<ResultVCCellData>()
    let upDownBtnClick = PublishRelay<Bool>()
    let grayBgClick = PublishRelay<Void>()
    let groupClick = BehaviorRelay<SaveStationGroup>(value: .one)
    let exceptionLastStationText = BehaviorRelay<String?>(value: "")
    
    // NOW MODAL CLOSE
    let totalModalClose = PublishRelay<Void>()
    
    let bag = DisposeBag()
    
    init(){
        self.modalData = self.clickCellData
            .asDriver(onErrorDriveWith: .empty())
        
        // 전체 데이터를 합친 후, 저장
       Observable
            .combineLatest(clickCellData, self.groupClick, self.exceptionLastStationText, self.upDownBtnClick){ cellData, group, exception, updown -> Void in
                
                var updownLine = ""
                if cellData.useLine ==  "2호선" {
                    updownLine = updown ? "내선" : "외선"
                }else{
                    updownLine = updown ? "상행" : "하행"
                }
                
                var brand = ""
                if cellData.useLine == "경의중앙"{
                    brand = "K4"
                }else if cellData.useLine == "수인분당"{
                    brand = "K1"
                }else if cellData.useLine == "경춘"{
                    brand = "K2"
                }else if cellData.useLine == "우이"{
                    brand = "UI"
                }else if cellData.useLine == "신분당"{
                    brand = "D1"
                }else if cellData.useLine == "공항"{
                    brand = "A1"
                }else{
                    brand = ""
                }
                
                FixInfo.saveStation.append(SaveStation(id: UUID().uuidString, stationName: cellData.useStationName, stationCode: cellData.stationCode, updnLine: updownLine, line: cellData.lineNumber, lineCode: cellData.lineCode, group: group, exceptionLastStation: exception ?? "", korailCode: brand))
                
                return Void()
            }
            .bind(to: self.totalModalClose)
            .disposed(by: self.bag)
      
        self.modalClose = Observable
            .merge(
                self.grayBgClick.asObservable(),
                self.totalModalClose.asObservable()
            )
            .asDriver(onErrorDriveWith: .empty())
    }
}
