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

class ModalViewModel{
    deinit{
        print("ModalViewModel DEINIT")
    }
    
    struct Input {
        let upDownBtnClick: Observable<Bool>
        let notService: Observable<Void>
        let groupClick: Observable<SaveStationGroup>
        let exceptionLastStationText: Observable<String?>
        let disposableBtnTap: Observable<Bool>
        let didDisappear: Observable<Void>
        let modalGesture: Observable<Void>
    }
    
    struct Output {
        let modalData : Driver<ResultVCCellData>
        let modalClose: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        self.stationSave(input: input)
        self.present(input: input)
        
        return Output(
            modalData: self.clickCellData
            .asDriver(onErrorDriveWith: .empty()),
            modalClose: self.modalClose
            .asDriver(onErrorDriveWith: .empty())
        )
    }
    
    let bag = DisposeBag()
    
    // DATA
    private let modalCloseEvent = PublishRelay<Bool>()
    private let mainCellData = PublishRelay<DetailLoadData>()
    private let modalClose = PublishSubject<Void>()
    
    let clickCellData = PublishRelay<ResultVCCellData>()
    let overlapOkBtnTap = PublishSubject<Void>()
    
    // MODEL
    private let model : ModalModelProtocol
    
    weak var delegate: ModalVCActionProtocol?
    
    init(
        model : ModalModel = .init()
    ){
        self.model = model
    }
}

private extension ModalViewModel {
    func stationSave(input: Input) {
        Observable
            .combineLatest(self.clickCellData, input.groupClick, input.exceptionLastStationText, input.upDownBtnClick) {[weak self] cellData, group, exception, updown -> Bool in
                
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
        
        
        input.upDownBtnClick
            .withLatestFrom(self.clickCellData)
            .subscribe(onNext: {
                Analytics.logEvent("SerachVC_Modal_Save", parameters: [
                    "Save_Station" : $0.stationName
                ])
            })
            .disposed(by: self.bag)
    }
    
    func present(input: Input) {
        input.disposableBtnTap
            .withLatestFrom(self.clickCellData){[weak self] updown, data in
                let updownFix = self?.model.updownFix(updown: updown, line: data.useLine) ?? ""
                let korail = self?.model.useLineTokorailCode(data.useLine) ?? ""
                
                return DetailLoadData(upDown: updownFix, stationName: data.stationName, lineNumber: data.lineNumber, lineCode: data.lineCode, useLine: "", stationCode: data.stationCode, exceptionLastStation: "", backStationId: "", nextStationId: "", korailCode: korail)
            }
            .withUnretained(self)
            .delay(.milliseconds(250), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { viewModel, data in
                viewModel.delegate?.disposableDetailPush(data: data)
            })
            .disposed(by: self.bag)
        
        let close = Observable
            .merge(
                input.notService.asObservable(),
                self.modalCloseEvent.filter{$0 == true}.map{_ in Void()},
                self.overlapOkBtnTap.asObservable(),
                input.disposableBtnTap.map{ _ in Void()}
            )
            .share()
        
        close
            .bind(to: self.modalClose)
            .disposed(by: self.bag)
        
        input.modalGesture
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                viewModel.delegate?.dismiss()
            })
            .disposed(by: self.bag)
        
        self.modalCloseEvent
            .filter{!$0}
            .take(1)
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                viewModel.delegate?.overlap()
            })
            .disposed(by: self.bag)
        
        self.modalCloseEvent
            .filter{$0}
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                viewModel.delegate?.stationSave()
            })
            .disposed(by: self.bag)
        
        input.didDisappear
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                viewModel.delegate?.didDisappear()
            })
            .disposed(by: self.bag)
    }
}
