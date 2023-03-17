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
    // OUTPUT
    let modalData : Driver<ResultVCCellData>
    let modalClose : Driver<Void>
    let alertShow : Driver<Void>
    
    // INPUT
    let overlapOkBtnTap = PublishRelay<Void>()
    let clickCellData = PublishRelay<ResultVCCellData>()
    let upDownBtnClick = PublishRelay<Bool>()
    let notService = PublishRelay<Void>()
    let groupClick = BehaviorRelay<SaveStationGroup>(value: .one)
    let exceptionLastStationText = BehaviorRelay<String?>(value: "")
    
    let bag = DisposeBag()
    
    init(){
        self.modalData = self.clickCellData
            .asDriver(onErrorDriveWith: .empty())
        
        // 전체 데이터를 합친 후, 저장
       let save = Observable
            .combineLatest(clickCellData, self.groupClick, self.exceptionLastStationText, self.upDownBtnClick){ cellData, group, exception, updown -> Bool in
                
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
                
                if FixInfo.saveSetting.searchOverlapAlert{
                    // 중복 지하철은 저장 X
                    for x in FixInfo.saveStation{
                        if x.stationName == cellData.stationName && x.updnLine == updownLine && x.lineCode == cellData.lineCode{
                            return false
                        }
                    }
                }
                
                FixInfo.saveStation.append(SaveStation(id: UUID().uuidString, stationName: cellData.useStationName, stationCode: cellData.stationCode, updnLine: updownLine, line: cellData.lineNumber, lineCode: cellData.lineCode, group: group, exceptionLastStation: exception ?? "", korailCode: brand))
                return true
            }
            .share()
        
        self.alertShow = save
            .filter{!$0}
            .map{_ in Void()}
            .asDriver(onErrorDriveWith: .empty())
      
        self.modalClose = Observable
            .merge(
                self.notService.asObservable(),
                save.filter{$0}.map{_ in Void()},
                self.overlapOkBtnTap.asObservable()
            )
            .asDriver(onErrorDriveWith: .empty())
    }
}
