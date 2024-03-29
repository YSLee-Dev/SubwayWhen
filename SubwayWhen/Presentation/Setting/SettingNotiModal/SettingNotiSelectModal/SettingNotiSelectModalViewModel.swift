//
//  SettingNotiSelectModalViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/21.
//

import Foundation

import RxSwift
import RxCocoa
import RxOptional

class SettingNotiSelectModalViewModel {
    weak var delegate: SettingNotiSelectModalVCAction?
    let group: SaveStationGroup
    let id: String
    
    let bag = DisposeBag()
    let model: SettingNotiSelectModalModelProtocol
    
    private let cellData = BehaviorSubject<[SettingNotiSelectModalSectionData]>(value: [SettingNotiSelectModalSectionData(id: "startWith", items: [])])
    
    struct Input {
        let didDisappearAction: PublishSubject<Void>
        let popAction: Observable<Void>
        let stationTap: Observable<SettingNotiSelectModalCellData>
        let stationRemoveTap: Observable<Void>
    }
    
    struct Output {
        let stationList: Driver<[SettingNotiSelectModalSectionData]>
        let noLabelListShow: Driver<Bool>
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
        
        input.stationRemoveTap
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                viewModel.delegate?.stationTap(
                    item: .init(id: "", stationName: "역 선택", updnLine: "", line: "", useLine: "", isChecked: false), group: viewModel.group)
            })
            .disposed(by: self.bag)
        
        self.model.notiSelectList(loadGroup: self.group)
            .asObservable()
            .withUnretained(self)
            .flatMap { viewModel, data in
                viewModel.model.saveStationToSectionData(data: data, id: viewModel.id)
            }
            .delay(.microseconds(250), scheduler: MainScheduler.asyncInstance)
            .bind(to: self.cellData)
            .disposed(by: self.bag)
        
            
        
        return Output(
            stationList: self.cellData
                .asDriver(onErrorDriveWith: .empty()),
            noLabelListShow: self.cellData
                .filter {$0.first?.id != "startWith"}
                .map { $0.first?.items.isEmpty ?? false }
                .asDriver(onErrorDriveWith: .empty())
        )
    }
    
    init (
        settingNotiSelectModalModel: SettingNotiSelectModalModelProtocol,
        group: SaveStationGroup,
        id: String
    ) {
        self.model = settingNotiSelectModalModel
        self.group = group
        self.id = id
    }
}
