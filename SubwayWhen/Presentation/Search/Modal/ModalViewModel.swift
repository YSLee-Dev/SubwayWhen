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

import FirebaseAnalytics

class ModalViewModel : ModalViewModelProtocol{
    deinit{
        print("ModalViewModel DEINIT")
    }
    
    // OUTPUT
    let modalData : Driver<ResultVCCellData>
    let modalClose : Driver<Void>
    let alertShow : Driver<Void>
    let saveComplete : Driver<Void>
    let disposableDetailMove : Driver<DetailLoadData>
    
    // INPUT
    let overlapOkBtnTap = PublishRelay<Void>()
    let clickCellData = PublishRelay<ResultVCCellData>()
    let upDownBtnClick = PublishRelay<Bool>()
    let notService = PublishRelay<Void>()
    let groupClick = BehaviorRelay<SaveStationGroup>(value: .one)
    let exceptionLastStationText = BehaviorRelay<String?>(value: "")
    let disposableBtnTap = PublishRelay<Bool>()
    
    let bag = DisposeBag()
    
    // DATA
    private let modalCloseEvent = PublishRelay<Bool>()
    private let mainCellData = PublishRelay<DetailLoadData>()
    
    // MODEL
    private let model : ModalModelProtocol
    
    init(
        model : ModalModel = .init()
    ){
        self.model = model
        
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
                self.modalCloseEvent.filter{$0 == true}.map{_ in Void()},
                self.overlapOkBtnTap.asObservable()
            )
            .asDriver(onErrorDriveWith: .empty())
        
        // 전체 데이터를 합친 후, 저장
        Observable
            .combineLatest(clickCellData, self.groupClick, self.exceptionLastStationText, self.upDownBtnClick) {[weak self] cellData, group, exception, updown -> Bool in
                
                let updownLine = self?.model.updownFix(updown: updown, line: cellData.useLine) ?? ""
                let brand = self?.model.useLineTokorailCode(cellData.useLine) ?? ""
                
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
        
        // 구글 애널리틱스
        self.upDownBtnClick
            .withLatestFrom(self.clickCellData)
            .subscribe(onNext: {
                Analytics.logEvent("SerachVC_Modal_Save", parameters: [
                    "Save_Station" : $0.stationName
                ])
            })
            .disposed(by: self.bag)
        
        self.disposableBtnTap
            .withLatestFrom(self.clickCellData){[weak self] updown, data in
                let updownFix = self?.model.updownFix(updown: updown, line: data.useLine) ?? ""
                let korail = self?.model.useLineTokorailCode(data.useLine) ?? ""
                
                return DetailLoadData(upDown: updownFix, subWayId: data.lineCode, stationName: data.stationName, lastStation: "", lineNumber: data.lineNumber, useLine: "", id: data.identity, stationCode: data.stationCode, exceptionLastStation: "", backStationId: "", nextStationId: "", korailCode: korail)
            }
            .bind(to: self.mainCellData)
            .disposed(by: self.bag)
    }
}
