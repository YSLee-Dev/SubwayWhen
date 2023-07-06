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
    weak var delegate: LocationModalVCActionProtocol?
    let model: LocationModalModelProtocol
    
    private let modalDismissAction = PublishSubject<Void>()
    private let auth = PublishSubject<Bool>()
    private let vcinityStationList = BehaviorSubject<[LocationModalSectionData]>(value: [])
    
    private let bag = DisposeBag()
    
    struct Input {
        let modalCompletion: Observable<Void>
        let okBtnTap: Observable<Void>
        let didDisappear: Observable<Void>
        let stationTap: Observable<LocationModalCellData>
    }
    
    struct Output {
        let modalDismissAnimation: Driver<Void>
        let locationAuthStatus: Driver<Bool>
        let vcinityStations: Driver<[LocationModalSectionData]>
        let loadingStop: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        self.vcFlow(input: input)
        self.authCheck()
        self.locationRequest()
        
        return Output(
            modalDismissAnimation: self.modalDismissAction
                .asDriver(onErrorDriveWith: .empty()),
            locationAuthStatus: self.auth
                .asDriver(onErrorDriveWith: .empty()),
            vcinityStations: self.vcinityStationList
                .asDriver(onErrorDriveWith: .empty()),
            loadingStop: self.vcinityStationList
                .filter { !$0.isEmpty }
                .map {_ in Void()}
                .asDriver(onErrorDriveWith: .empty())
        )
    }
    
    init(
        model: LocationModalModelProtocol = LocationModalModel()
    ) {
        self.model = model
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
                viewModel.delegate?.dismiss()
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
            .subscribe(onNext: { viewModel, data in
                viewModel.delegate?.stationTap(stationName: data.name)
            })
            .disposed(by: self.bag)
    }
    
    func authCheck() {
        self.model.locationAuthCheck()
            .delay(.microseconds(300), scheduler: MainScheduler.asyncInstance)
            .bind(to: self.auth)
            .disposed(by: self.bag)
    }
    
    func locationRequest() {
        self.auth
            .filter {$0}
            .withUnretained(self)
            .flatMapLatest{ viewModel, _ in
                viewModel.model.locationRequest()
            }
            .flatMapLatest{ [weak self] data in
                self?.model.locationToVicinityStationRequest(locationData: data) ?? .empty()
            }
            .bind(to: self.vcinityStationList)
            .disposed(by: self.bag)
            
    }
}
