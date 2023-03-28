//
//  ReportViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/21.
//

import Foundation

import RxSwift
import RxCocoa
import RxOptional

class ReportViewModel {
    // OUTPUT
    let cellData : Driver<[ReportTableViewCellSection]>
    let keyboardClose : Driver<Void>
    let scrollSction : Driver<Int>
    let checkModalViewModel : Driver<ReportContentsModalViewModel>
    let popVC : Driver<Void>
    
    // DATA
    let nowData = BehaviorRelay<[ReportTableViewCellSection]>(value: [])
    let nowStep = PublishRelay<Int>()
    let msgData = PublishRelay<ReportMSGData>()
    
    // MODEL
    let lineCellModel : ReportTableViewLineCellModelProtocol
    let textFieldCellModel : ReportTableViewTextFieldCellModelProtocol
    let twoBtnCellModel : ReportTableViewTwoBtnCellModelProtocol
    let model : ReportModelProtocol
    let contentsModalViewModel : ReportContentsModalViewModelProtocol
    
    let bag = DisposeBag()
    
    init(
        model : ReportModel = .init(),
        textField : ReportTableViewTextFieldCellModel = .init(),
        twoBtn : ReportTableViewTwoBtnCellModel = .init(),
        lineCell : ReportTableViewLineCellModel = .init(),
        contentsModelViewModel : ReportContentsModalViewModel = .init()
        
    ){
        self.model = model
        self.textFieldCellModel = textField
        self.twoBtnCellModel = twoBtn
        self.lineCellModel = lineCell
        self.contentsModalViewModel = contentsModelViewModel
        
        // LAZY contentsModalViewModel
        lazy var contentsModalViewModel = ReportContentsModalViewModel()
        
        self.msgData
            .bind(to: contentsModalViewModel.msgData)
            .disposed(by: self.bag)
        
        self.checkModalViewModel = self.msgData
            .map{ _ in
                contentsModalViewModel
            }
            .asDriver(onErrorDriveWith: .empty())
        
        self.cellData = self.nowData
            .asDriver(onErrorDriveWith: .empty())
        
        self.scrollSction = self.nowStep
            .asDriver(onErrorDriveWith: .empty())
        
        self.popVC = contentsModalViewModel.close
            .asDriver(onErrorDriveWith: .empty())
        
        self.keyboardClose = Observable<Void>.merge(
            self.lineCellModel.lineFix.asObservable(),
            self.textFieldCellModel.doenBtnClick.map{_ in Void()}.asObservable()
        )
        .asDriver(onErrorDriveWith: .empty())
        
        // DefaultLineCell Data / delay 3s
        Observable<[String]>.create{
            $0.onNext(Array(Set(FixInfo.saveStation.map{$0.line}).filter{$0 != "우이신설경전철"}))
            $0.onCompleted()
            return Disposables.create()
        }
        .delay(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
        .bind(to: self.lineCellModel.defaultLineViewModel.defaultCellData)
        .disposed(by: self.bag)
        
        // 호선 리스트
        self.model.lineListData()
        .bind(to: self.lineCellModel.lineInfo)
        .disposed(by: self.bag)
        
        // 첫 번째 질문
        self.model.oneStepQuestionData()
        .delay(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
        .bind(to: self.nowData)
        .disposed(by: self.bag)
        
        let shareDefaultLine =  self.lineCellModel.defaultLineViewModel.cellClick
            .asObserver()
            .share()
        
        // DefaultLineCell, lineSeleted
        let lineData = Observable<ReportBrandData>.merge(
            self.lineCellModel.lineSeleted.asObservable(),
            shareDefaultLine
        )
        
        // lineSeleted
        let lineSeleted = Observable<Void>.merge(
            self.lineCellModel.lineFix.asObservable(),
            shareDefaultLine.map{_ in Void()}
        )
        
        // 두 번째 행 출력
        let twoStep = lineSeleted
            .withLatestFrom(lineData)
            .withUnretained(self)
            .map{ cell, data in
                let value = cell.nowData.value
                let first = value.first!
                
                var two = cell.model.twoStepQuestionData()
                
                if let exception = cell.model.twoStepSideException(data) {
                    two.items.append(exception)
                }
                
                return [first, two]
            }
            .delay(.milliseconds(400), scheduler: MainScheduler.asyncInstance)
            .share()
        
        twoStep
            .bind(to: self.nowData)
            .disposed(by: self.bag)
        
        twoStep
            .map{_ in 1}
            .bind(to: self.nowStep)
            .disposed(by: self.bag)
        
        
        let brand = self.twoBtnCellModel.identityIndex
            .withLatestFrom(self.twoBtnCellModel.updownClick){ index, brand -> String? in
                if index.section == 1, index.row == 2{
                    return brand
                }else if index == IndexPath(row: 9, section: 9){
                    return "N/A"
                }else{
                    return nil
                }
            }
            .filterNil()
        
        let destination = self.textFieldCellModel.identityIndex
            .withLatestFrom(self.textFieldCellModel.doenBtnClick){[weak self] index, destination -> String? in
                self?.model.cellDataMatching(index: index, matchIndex: IndexPath(row: 0, section: 1), data: destination)
            }
            .filterNil()
            .share()
        
        
        // 셀 재사용으로 인한 데이터 미리 저장
        destination
            .map{[weak self] data in
                var now = self?.nowData.value
                now = self?.model.cellDataSave(nowData: now ?? [], data: data, index: IndexPath(row: 0, section: 1))
                
                if now?[1].items[1].cellData == ""{
                    now?[1].items[1].focus = true
                }
                
                return now ?? []
            }
            .bind(to: self.nowData)
            .disposed(by: self.bag)
        
        
        let nowStation = self.textFieldCellModel.identityIndex
            .withLatestFrom(self.textFieldCellModel.doenBtnClick){[weak self]index, now -> String?  in
                self?.model.cellDataMatching(index: index, matchIndex: IndexPath(row: 1, section: 1), data: now)
            }
            .filterNil()
            .share()
        
        nowStation
            .map{[weak self] data in
                var now = self?.nowData.value
                
                now = self?.model.cellDataSave(nowData: now ?? [], data: data, index: IndexPath(row: 1, section: 1))
                
                return now ?? []
            }
            .bind(to: self.nowData)
            .disposed(by: self.bag)
        
        // 세 번째 행 출력
        let threeStep = Observable.combineLatest(destination, nowStation, brand)
            .withUnretained(self)
            .map{cell, value -> [ReportTableViewCellSection] in
                var now = cell.nowData.value
     
                if now[1].items.count == 3 && value.2 == "N/A"{
                    return []
                }else if value.2 != "N/A"{
                    now[1].items[2].cellData = value.2
                }
                
                now.append(cell.model.theeStepQuestion())
                
                return now
                
            }
            .filterEmpty()
            .share()
        
        threeStep
            .bind(to: self.nowData)
            .disposed(by: self.bag)
        
        threeStep
            .map{_ in 2}
            .bind(to: self.nowStep)
            .disposed(by: self.bag)
        
        let trainCar = self.textFieldCellModel.identityIndex
            .withLatestFrom(self.textFieldCellModel.doenBtnClick){[weak self]index, now -> String?  in
                self?.model.cellDataMatching(index: index, matchIndex: IndexPath(row: 0, section: 2), data: now)
            }
            .filterNil()
            .share()
        
        // 셀 재사용으로 인한 데이터 미리 저장
        trainCar
            .map{[weak self] data in
                var now = self?.nowData.value
                now = self?.model.cellDataSave(nowData: now ?? [], data: data, index: IndexPath(row: 0, section: 2))
                
                return now ?? []
            }
            .bind(to: self.nowData)
            .disposed(by: self.bag)
        
        
        Observable.combineLatest(lineData, nowStation, destination, trainCar, brand){ line, station, de, train, subwayBrand in
            var brand = subwayBrand
            if line != .one || line != .three || line != .four{
                if subwayBrand == "N/A"{
                    brand = "N"
                }
            }
            
            return ReportMSGData(line: line, nowStation: station, destination: de, trainCar: train, contants: "", brand: brand)
        }
        .bind(to: self.msgData)
        .disposed(by: self.bag)
    }
    
    deinit{
        print("REPORTVIEWMODEL DEINIT")
    }
}
