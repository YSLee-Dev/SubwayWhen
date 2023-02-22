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
    let checkModalViewModel : Driver<ReportCheckModalViewModel>
    let popVC : Driver<Void>
    
    // INPUT
    
    // DATA
    let nowData = BehaviorRelay<[ReportTableViewCellSection]>(value: [])
    let nowStep = PublishRelay<Int>()
    let msgData = PublishRelay<ReportMSGData>()
    
    // MODEL
    let lineCellModel = ReportTableViewLineCellModel()
    let textFieldCellModel = ReportTableViewTextFieldCellModel()
    let twoBtnCellModel = ReportTableViewTwoBtnCellModel()
    
    let bag = DisposeBag()
    
    init(){
        // LAZY CheckModalViewModel
        lazy var checkModalViewModel = ReportCheckModalViewModel()
        
        self.msgData
            .bind(to: checkModalViewModel.msgData)
            .disposed(by: self.bag)
        
        self.checkModalViewModel = self.msgData
            .map{ _ in
                checkModalViewModel
            }
            .asDriver(onErrorDriveWith: .empty())
        
        self.cellData = self.nowData
            .asDriver(onErrorDriveWith: .empty())
        
        self.scrollSction = self.nowStep
            .asDriver(onErrorDriveWith: .empty())
        
        self.popVC = checkModalViewModel.close
            .asDriver(onErrorDriveWith: .empty())
        
        Observable<[ReportTableViewCellSection]>.create{
            $0.onNext([ReportTableViewCellSection(sectionName: "민원 호선", items: [.init(cellTitle: "몇호선 민원을 접수하시겠어요?", cellData: "", type: .Line)])])
            $0.onCompleted()
            return Disposables.create()
        }
        .delay(.milliseconds(250), scheduler: MainScheduler.asyncInstance)
        .bind(to: self.nowData)
        .disposed(by: self.bag)
        
        self.keyboardClose = Observable<Void>.merge(
            self.lineCellModel.doneBtnClick.asObservable(),
            self.textFieldCellModel.doenBtnClick.map{_ in Void()}.asObservable()
        )
        .asDriver(onErrorDriveWith: .empty())
        
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
        
        // 두 번째 행 출력
        let twoStep = self.lineCellModel.doneBtnClick
            .withLatestFrom(self.lineCellModel.lineSeleted)
            .withUnretained(self)
            .map{ cell, data in
                let value = cell.nowData.value
                let first = value.first!
                
                var two = ReportTableViewCellSection(sectionName: "호선 정보", items: [
                    .init(cellTitle: "상하행 정보를 입력해주세요.", cellData: "", type: .TwoBtn),
                    .init(cellTitle: "현재 역을 입력해주세요.", cellData: "", type: .TextField)
                ])
                
                if data == ReportBrandData.one {
                    two.items.insert((.init(cellTitle: "현재 역이 청량리 ~ 서울역 안에 있나요?", cellData: "", type: .TwoBtn)), at: 1)
                }else if data == ReportBrandData.three{
                    two.items.insert((.init(cellTitle: "현재 역이 지축 ~ 대화 안에 있나요?", cellData: "", type: .TwoBtn)), at: 1)
                }else if data == ReportBrandData.four{
                    two.items.insert((.init(cellTitle: "현재 역이 오이도 ~ 선바위 안에 있나요?", cellData: "", type: .TwoBtn)), at: 1)
                }
                
                return [first, two]
            }
            .share()
        
        twoStep
            .bind(to: self.nowData)
            .disposed(by: self.bag)
        
        twoStep
            .map{_ in 1}
            .bind(to: self.nowStep)
            .disposed(by: self.bag)
        
        
        let updownClick = self.twoBtnCellModel.identityIndex
            .withLatestFrom(self.twoBtnCellModel.updownClick){index, updown -> String? in
                if index.section == 1, index.row == 0{
                    return updown
                }else{
                    return nil
                }
            }
            .filterNil()
            .share()
        
        let nowStation = self.textFieldCellModel.identityIndex
            .withLatestFrom(self.textFieldCellModel.doenBtnClick){index, now -> String?  in
                if index.section == 1{
                    return now
                }else{
                    return nil
                }
            }
            .filterNil()
            .share()
        
        let brand = self.twoBtnCellModel.identityIndex
            .withLatestFrom(self.twoBtnCellModel.updownClick){[weak self] index, brand -> String? in
                let now = self?.nowData.value
                if index.section == 1, index.row == 1{
                    return brand
                }else if now![1].items.count == 2{
                    return "N"
                }else{
                    return nil
                }
            }
            .filterNil()
            .share()
        
        // 세 번째 행 출력
        let threeStep = Observable.zip(updownClick, nowStation, brand)
            .withUnretained(self)
            .map{cell, _ in
                var now = cell.nowData.value
                now.append(.init(sectionName: "상세 정보", items: [
                    .init(cellTitle: "편성(고유번호)을 입력해주세요.", cellData: "", type: .TextField),
                    .init(cellTitle: "칸 위치를 입력해주세요.", cellData: "", type: .TextField),
                    .init(cellTitle: "민원 내용을 입력해주세요.", cellData: "", type: .TextField)
                ]))
                
                return now
            }
            .share()
        
        threeStep
            .bind(to: self.nowData)
            .disposed(by: self.bag)
        
        threeStep
            .map{_ in 2}
            .bind(to: self.nowStep)
            .disposed(by: self.bag)
        
        let trianNumber = self.textFieldCellModel.identityIndex
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
        trianNumber
            .map{[weak self] data in
                var now = self?.nowData.value
                now?[2].items[0].cellData = data
                
                return now ?? []
            }
            .bind(to: self.nowData)
            .disposed(by: self.bag)
        
        let trainCar = self.textFieldCellModel.identityIndex
            .withLatestFrom(self.textFieldCellModel.doenBtnClick){index, now -> String?  in
                if index.section == 2, index.row == 1{
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
                now?[2].items[1].cellData = data
                
                return now ?? []
            }
            .bind(to: self.nowData)
            .disposed(by: self.bag)
        
        let contents = self.textFieldCellModel.identityIndex
            .withLatestFrom(self.textFieldCellModel.doenBtnClick){index, now -> String?  in
                if index.section == 2, index.row == 2{
                    return now
                }else{
                    return nil
                }
            }
            .filterNil()
            .share()
        
        // 셀 재사용으로 인한 데이터 미리 저장
        contents
            .map{[weak self] data in
                var now = self?.nowData.value
                now?[2].items[2].cellData = data
                
                return now ?? []
            }
            .bind(to: self.nowData)
            .disposed(by: self.bag)
        
        Observable.combineLatest(self.lineCellModel.lineSeleted, updownClick, nowStation, trianNumber, trainCar, contents, brand){
            ReportMSGData(line: $0, updown: $1, nowStation: $2, trainNumber: $3, trainCar: $4, contants: $5, brand: $6)
        }
        .bind(to: self.msgData)
        .disposed(by: self.bag)
    }
    
    deinit{
        print("REPORTVIEWMODEL DEINIT")
    }
}
