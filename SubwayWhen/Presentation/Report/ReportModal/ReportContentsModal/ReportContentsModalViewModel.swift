//
//  ReportContentsModalViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/07.
//

import Foundation

import RxSwift
import RxCocoa

class ReportContentsModalViewModel{
    let bag = DisposeBag()
    
    // INPUT
    let msgData = BehaviorSubject<ReportMSGData>(value: .init(line: .not, nowStation: "", destination: "", trainCar: "", contants: "", brand: ""))
    let close = PublishRelay<Void>()
    let contentsTap = PublishRelay<String>()
    
    // OUTPUT
    let cellData : Driver<[ReportContentsModalSection]>
    let nextStep : Driver<ReportCheckModalViewModel>
    let twoStepClose : Driver<Void>
    
    // MODEL
    let model : ReportContentsModalModelProtocol
    let tfViewModel : ReportContentsModalTFViewModelProtocol
    let checkModel : ReportCheckModalViewModelProtocol
    
    init(
        tfViewModel : ReportContentsModalTFViewModel = .init(),
        model : ReportContentsModalModel = .init(),
        checkModel : ReportCheckModalViewModel = .init()
    ){
        self.tfViewModel = tfViewModel
        self.model = model
        self.checkModel = checkModel
        
        self.cellData = self.model.reportList()
        .asDriver(onErrorDriveWith: .empty())
        
        let contents = Observable<String>.merge(
            self.contentsTap.asObservable(),
            self.tfViewModel.inputText.asObservable()
        )
        
        contents
            .withLatestFrom(self.msgData){ contents, msgData in
                ReportMSGData(line: msgData.line, nowStation: msgData.nowStation, destination: msgData.destination, trainCar: msgData.trainCar, contants: contents, brand: msgData.brand)
            }
            .bind(to: checkModel.msgData)
            .disposed(by: self.bag)
        
        self.nextStep = contents
            .map{ _ in
                checkModel
            }
            .asDriver(onErrorDriveWith: .empty())
        
        self.twoStepClose = checkModel.msgSeedDismiss
            .asDriver(onErrorDriveWith: .empty())
    }
}
