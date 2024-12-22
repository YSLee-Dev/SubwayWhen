//
//  LocationModalViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/05.
//

import Foundation

import RxSwift
import RxCocoa

class LocationModalViewModel {
    private let vicinityList: [VicinityTransformData]
    weak var delegate: LocationModalVCActionProtocol?
    
    private let modalDismissAction = PublishSubject<Void>()
    private let auth = BehaviorRelay<Bool>(value:  false)
    private let vcinitySectionList = BehaviorSubject<[LocationModalSectionData]>(value: [])
    
    private let bag = DisposeBag()
    
    struct Input {
        let modalCompletion: Observable<Void>
        let okBtnTap: Observable<Void>
        let didDisappear: Observable<Void>
        let stationTap: Observable<Int>
    }
    
    struct Output {
        let modalDismissAnimation: Driver<Void>
        let locationAuthStatus: Driver<Bool>
        let vcinityStations: Driver<[LocationModalSectionData]>
    }
    
    func transform(input: Input) -> Output {
        self.vcFlow(input: input)
        self.authCheck()
        self.locationRequest()
        
        return Output(
            modalDismissAnimation: self.modalDismissAction
                .asDriver(onErrorDriveWith: .empty()),
            locationAuthStatus: self.auth
                .skip(1) //BehaviorRelay의 초기값 무시
                .asDriver(onErrorDriveWith: .empty()),
            vcinityStations: self.vcinitySectionList
                .asDriver(onErrorDriveWith: .empty())
        )
    }
    
    init(
        vicinityList: [VicinityTransformData]
    ) {
        self.vicinityList = vicinityList
    }
}

extension LocationModalViewModel {
    func vcFlow(input: Input) {
        input.okBtnTap
            .bind(to: self.modalDismissAction)
            .disposed(by: self.bag)
        
        input.modalCompletion
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                viewModel.delegate?.dismiss(auth: self.auth.value)
            })
            .disposed(by: self.bag)
        
        input.didDisappear
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                viewModel.delegate?.didDisappear()
            })
            .disposed(by: self.bag)
        
        input.stationTap
            .withUnretained(self)
            .filter { viewModel, index in
                viewModel.vicinityList[index].name != "정보없음"
            }
            .subscribe(onNext: { viewModel, index in
                viewModel.delegate?.stationTap(index: index)
            })
            .disposed(by: self.bag)
    }
    
    func authCheck() {
        Observable<Bool>.of(LocationManager.shared.locationAuthCheck())
            .delay(.microseconds(300), scheduler: MainScheduler.asyncInstance)
            .bind(to: self.auth)
            .disposed(by: self.bag)
    }
    
    func locationRequest() {
        self.auth
            .filter {$0}
            .withUnretained(self)
            .map { viewModel, _ in
                let cellData = viewModel.vicinityList.map {
                    LocationModalCellData(
                        id: $0.distance + $0.name,
                        name: $0.name,
                        line: $0.line,
                        distance: $0.distance,
                        lineColorName: $0.lineColorName,
                        lineName: $0.lineName
                    )
                }
                
                return [LocationModalSectionData(id: UUID().uuidString, items: cellData)]
            }
            .bind(to: self.vcinitySectionList)
            .disposed(by: self.bag)
    }
}
