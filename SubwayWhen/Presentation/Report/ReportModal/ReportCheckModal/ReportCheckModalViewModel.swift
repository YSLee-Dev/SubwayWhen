//
//  ReportCheckModalViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/21.
//

import Foundation

import RxSwift
import RxCocoa

import FirebaseAnalytics

class ReportCheckModalViewModel : ReportCheckModalViewModelProtocol{
    // INPUT
    let msgData = BehaviorSubject<ReportMSGData>(value: .init(line: .not, nowStation: "", destination: "", trainCar: "", contants: "", brand: ""))
    let okBtnClick = PublishRelay<Void>()
    let msgSeedDismiss = PublishRelay<Void>()
    
    // OUTPUT
    let msg : Driver<String>
    let number : Driver<String>
    
    // MODEL
    let model : ReportCheckModalModelProtocol
    
    // DATA
    let createMSG = BehaviorSubject<String>(value: "")
    let matchingNumber = PublishSubject<String>()
    
    let bag = DisposeBag()
    
    init(
        model : ReportCheckModalModel = .init()
    ){
        self.model = model
        
        self.msg = self.createMSG
            .asDriver(onErrorDriveWith: .empty())
        
        self.number = self.matchingNumber
            .asDriver(onErrorDriveWith: .empty())
        
        self.msgData
            .map{ [weak self] data -> String in
                self?.model.createMsg(data: data) ?? ""
            }
            .bind(to: self.createMSG)
            .disposed(by: self.bag)
        
        // 구글 애널리틱스
        self.msgData
            .filter{$0.line != .not}
            .bind(onNext: {
                Analytics.logEvent("ReportVC_Send", parameters: [
                    "Line" : $0.line.rawValue
                ])
            })
            .disposed(by: self.bag)
            
        self.okBtnClick
            .withLatestFrom(self.msgData)
            .map{[weak self] data in
                self?.model.numberMatching(data: data) ?? ""
            }
            .bind(to: self.matchingNumber)
            .disposed(by: self.bag)
    }
    
    deinit{
        print("ReportCheckModalViewModel DEINIT")
    }
}
