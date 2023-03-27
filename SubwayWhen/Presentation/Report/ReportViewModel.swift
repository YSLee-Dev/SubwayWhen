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
    
    let bag = DisposeBag()
    
    init(
        model : ReportModel = .init(),
        textField : ReportTableViewTextFieldCellModel = .init(),
        twoBtn : ReportTableViewTwoBtnCellModel = .init(),
        lineCell : ReportTableViewLineCellModel = .init()
    ){
        self.model = model
        self.textFieldCellModel = textField
        self.twoBtnCellModel = twoBtn
        self.lineCellModel = lineCell
        
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
        
        Observable<[ReportTableViewCellSection]>.create{
            $0.onNext(
                [ReportTableViewCellSection(sectionName: "민원 호선", items: [.init(cellTitle: "몇호선 민원을 접수하시겠어요?", cellData: "", type: .Line, focus: false)])
                ])
            $0.onCompleted()
            return Disposables.create()
        }
        .delay(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
        .bind(to: self.nowData)
        .disposed(by: self.bag)
        
        
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
        Observable<[String]>.create{
            $0.onNext([
                ReportBrandData.not.rawValue,
                ReportBrandData.one.rawValue,
                ReportBrandData.two.rawValue,
                ReportBrandData.three.rawValue,
                ReportBrandData.four.rawValue,
                ReportBrandData.five.rawValue,
                ReportBrandData.six.rawValue,
                ReportBrandData.seven.rawValue,
                ReportBrandData.eight.rawValue,
                ReportBrandData.nine.rawValue,
                ReportBrandData.gyeongui.rawValue,
                ReportBrandData.airport.rawValue,
                ReportBrandData.gyeongchun.rawValue,
                ReportBrandData.suinbundang.rawValue,
                ReportBrandData.shinbundang.rawValue,
            ])
            $0.onCompleted()
            return Disposables.create()
        }
        .bind(to: self.lineCellModel.lineInfo)
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
                
                var two = ReportTableViewCellSection(sectionName: "호선 정보", items: [
                    .init(cellTitle: "열차의 행선지를 입력해주세요.", cellData: "", type: .TextField, focus: true),
                    .init(cellTitle: "현재 역을 입력해주세요.", cellData: "", type: .TextField, focus: false)
                ])
                
                if data == ReportBrandData.one {
                    two.items.insert((.init(cellTitle: "현재 역이 청량리 ~ 서울역 안에 있나요?", cellData: "", type: .TwoBtn, focus: false)), at: 2)
                }else if data == ReportBrandData.three{
                    two.items.insert((.init(cellTitle: "현재 역이 지축 ~ 대화 안에 있나요?", cellData: "", type: .TwoBtn, focus: false)), at: 2)
                }else if data == ReportBrandData.four{
                    two.items.insert((.init(cellTitle: "현재 역이 오이도 ~ 선바위 안에 있나요?", cellData: "", type: .TwoBtn, focus: false)), at: 2)
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
            .withLatestFrom(self.textFieldCellModel.doenBtnClick){index, destination -> String? in
                if index.section == 1, index.row == 0{
                    return destination
                }else{
                    return nil
                }
            }
            .filterNil()
            .share()
        
        
        // 셀 재사용으로 인한 데이터 미리 저장
        destination
            .map{[weak self] data in
                var now = self?.nowData.value
                now?[1].items[0].cellData = data
                
                // 포커스 조정
                now?[1].items[0].focus = false
                if now?[1].items[1].cellData == ""{
                    now?[1].items[1].focus = true
                }
                
                return now ?? []
            }
            .bind(to: self.nowData)
            .disposed(by: self.bag)
        
        
        let nowStation = self.textFieldCellModel.identityIndex
            .withLatestFrom(self.textFieldCellModel.doenBtnClick){index, now -> String?  in
                if index.section == 1, index.row == 1{
                    return now
                }else{
                    return nil
                }
            }
            .filterNil()
            .share()
        
        nowStation
            .map{[weak self] data in
                var now = self?.nowData.value
                now?[1].items[1].cellData = data
                
                // 포커스 조정
                now?[1].items[1].focus = false
                
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
                }else{
                    now.append(.init(sectionName: "상세 정보", items: [
                        .init(cellTitle: "칸 위치나 열차번호를 입력해주세요.", cellData: "", type: .TextField, focus: true)
                    ]))
                    
                    return now
                }
                
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
            .withLatestFrom(self.textFieldCellModel.doenBtnClick){index, now -> String?  in
                if index.section == 2, index.row == 0{
                    return now
                }else{
                    return nil
                }
            }
            .filterNil()
            .share()
        
        // 셀 재사용으로 인한 데이터 미리 저장
        trainCar
            .map{[weak self] data in
                var now = self?.nowData.value
                now?[2].items[0].cellData = data
                
                // 포커스 조정
                now?[2].items[0].focus = false
                
                return now ?? []
            }
            .bind(to: self.nowData)
            .disposed(by: self.bag)
        
        
        Observable.combineLatest(lineData, nowStation, destination, trainCar, brand){[weak self] line, station, de, train, subwayBrand in
            let now = self?.nowData.value
            
            var brand = subwayBrand
            if now?[1].items.count == 2 && subwayBrand == "N/A"{
                brand = "N"
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
