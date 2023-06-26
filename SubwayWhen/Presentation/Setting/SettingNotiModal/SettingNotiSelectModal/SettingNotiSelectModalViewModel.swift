//
//  SettingNotiSelectModalViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/21.
//

import Foundation

import RxSwift
import RxCocoa

class SettingNotiSelectModalViewModel {
    weak var delegate: SettingNotiSelectModalVCAction?
    let group: SaveStationGroup
    
    let bag = DisposeBag()
    let model: SettingNotiSelectModalModelProtocol
    
    struct Input {
        let didDisappearAction: PublishSubject<Void>
        let popAction: Observable<Void>
        let stationTap: Observable<SettingNotiSelectModalCellData>
    }
    
    struct Output {
        let stationList: Driver<[SettingNotiSelectModalSectionData]>
    }
    
    func transform(input: Input) -> Output {
        input.didDisappearAction
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                viewModel.delegate?.didDisappear()
            })
            .disposed(by: self.bag)
        
        input.popAction
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                viewModel.delegate?.pop()
            })
            .disposed(by: self.bag)
        
        input.stationTap
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                viewModel.delegate?.stationTap(item: data, group: viewModel.group)
            })
            .disposed(by: self.bag)
        
        return Output(
            stationList: self.model.notiSelectList(loadRroup: self.group)
                .asObservable()
                .withUnretained(self)
                .flatMap { viewModel, data in
                    viewModel.model.saveStationToSectionData(data: data)
                }
                .delay(.microseconds(250), scheduler: MainScheduler.asyncInstance)
                .startWith([SettingNotiSelectModalSectionData(id: "startWith", items: [])])
                .asDriver(onErrorDriveWith: .empty())
        )
    }
    
    init (
        settingNotiSelectModalModel: SettingNotiSelectModalModelProtocol,
        group: SaveStationGroup
    ) {
        self.model = settingNotiSelectModalModel
        self.group = group
    }
}
