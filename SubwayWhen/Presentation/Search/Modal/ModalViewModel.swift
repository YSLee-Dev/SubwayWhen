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
    let saveComplete : Driver<Void>
    let disposableDetailMove : Driver<MainTableViewCellData>
    
    // INPUT
    let overlapOkBtnTap = PublishRelay<Void>()
    let clickCellData = PublishRelay<ResultVCCellData>()
    let upDownBtnClick = PublishRelay<Bool>()
    let notService = PublishRelay<Void>()
    let groupClick = BehaviorRelay<SaveStationGroup>(value: .one)
    let exceptionLastStationText = BehaviorRelay<String?>(value: "")
    let disposableBtnTap = PublishRelay<Bool>()
    
    let bag = DisposeBag()
    
    let modalCloseEvent = PublishRelay<Bool>()
    let mainCellData = PublishRelay<MainTableViewCellData>()
    
    init(){
        self.disposableDetailMove = self.mainCellData
            .asDriver(onErrorDriveWith: .empty())
        
        self.modalData = self.clickCellData
            .asDriver(onErrorDriveWith: .empty())
        
        self.alertShow = self.modalCloseEvent
            .filter{!$0}
            .map{_ in Void()}
            .asDriver(onErrorDriveWith: .empty())
        
        self.saveComplete = self.modalCloseEvent
            .filter{$0}
            .map{_ in Void()}
            .asDriver(onErrorDriveWith: .empty())
        
        self.modalClose = Observable
            .merge(
                self.notService.asObservable(),
                self.modalCloseEvent.map{_ in Void()}.asObservable(),
                self.overlapOkBtnTap.asObservable()
            )
            .asDriver(onErrorDriveWith: .empty())
        
        // 전체 데이터를 합친 후, 저장
        Observable
            .combineLatest(clickCellData, self.groupClick, self.exceptionLastStationText, self.upDownBtnClick) {[weak self] cellData, group, exception, updown -> Bool in
                
                let updownLine = self?.updownFix(updown: updown, line: cellData.useLine) ?? ""
                let brand = self?.useLineTokorailCode(cellData.useLine) ?? ""
                
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
            .bind(to: self.modalCloseEvent)
            .disposed(by: self.bag)
        
        self.disposableBtnTap
            .withLatestFrom(self.clickCellData){[weak self] updown, data in
                let updownFix = self?.updownFix(updown: updown, line: data.useLine) ?? ""
                let korail = self?.useLineTokorailCode(data.useLine) ?? ""
                
                return MainTableViewCellData(upDown: updownFix, arrivalTime: "", previousStation: "", subPrevious: "", code: "", subWayId: data.lineCode, stationName: data.stationName, lastStation: "", lineNumber: data.lineNumber, isFast: "", useLine: "", group: "", id: data.identity, stationCode: data.stationCode, exceptionLastStation: "", type: .real, backStationId: "-", nextStationId: "-", korailCode: korail)
            }
            .bind(to: self.mainCellData)
            .disposed(by: self.bag)
    }
    
    func useLineTokorailCode(_ useLine : String) -> String{
        var brand = ""
        if useLine == "경의중앙"{
            brand = "K4"
        }else if useLine == "수인분당"{
            brand = "K1"
        }else if useLine == "경춘"{
            brand = "K2"
        }else if useLine == "우이"{
            brand = "UI"
        }else if useLine == "신분당"{
            brand = "D1"
        }else if useLine == "공항"{
            brand = "A1"
        }else{
            brand = ""
        }
        
        return brand
    }
    
    func updownFix(updown : Bool, line : String) -> String{
        var updownLine = ""
        if line ==  "2호선" {
            updownLine = updown ? "내선" : "외선"
        }else{
            updownLine = updown ? "상행" : "하행"
        }
        return updownLine
    }
}
