//
//  SettingViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/16.
//

import Foundation

import RxSwift
import RxCocoa
import RxOptional

class SettingViewModel : SettingViewModelProtocol{
    // OUTPUT
    let cellData : Driver<[SettingTableViewCellSection]>
    let keyboardClose : Driver<Void>
    let modalPresent : Driver<SettingTableViewCellData>
    
    // INPUT
    let cellClick = PublishRelay<SettingTableViewCellData>()
    
    // MODEL
    let model : SettingModelProtocol
    let settingTableViewCellModel : SettingTableViewCellModelProtocol
    
    let settingList = BehaviorRelay<[SettingTableViewCellSection]>(value: [])
    
    let bag = DisposeBag()
    
    init(
        model : SettingModel = .init(),
        cellModel : SettingTableViewCellModel = .init()
    ){
        self.model = model
        self.settingTableViewCellModel = cellModel
        
        // 모달 present
        self.modalPresent = self.cellClick
            .filter{
                $0.inputType == .NewVC
            }
            .asDriver(onErrorDriveWith: .empty())
        
        // 키보드 닫기
        self.keyboardClose = self.settingTableViewCellModel.keyboardClose
            .asDriver(onErrorDriveWith: .empty())
        
        // 설정 셀 구성
        self.cellData = self.settingList
            .asDriver(onErrorDriveWith: .empty())
        
        // FixInfo 불러오는 시간 대기
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){[weak self] in
            self?.model.createSettingList()
                .bind(to: self?.settingList ?? BehaviorRelay<[SettingTableViewCellSection]>(value: []))
                .dispose()
        }
        // 자동 새로고침 여부
        self.settingTableViewCellModel.cellIndex
            .withLatestFrom(self.settingTableViewCellModel.switchValue){ [weak self] index, value -> Bool? in
                self?.model.indexMatching(index: index, matchIndex: IndexPath(row: 0, section: 1), data: value)
            }
            .filterNil()
            .subscribe(onNext: {
                FixInfo.saveSetting.detailAutoReload = $0
            })
            .disposed(by: self.bag)
        
        // 시간표 정렬
        self.settingTableViewCellModel.cellIndex
            .withLatestFrom(self.settingTableViewCellModel.switchValue){[weak self] index, value -> Bool? in
                self?.model.indexMatching(index: index, matchIndex: IndexPath(row: 1, section: 1), data: value)
            }
            .filterNil()
            .subscribe(onNext: {
                FixInfo.saveSetting.detailScheduleAutoTime = $0
            })
            .disposed(by: self.bag)
        
        // 중복 저장 방지
        self.settingTableViewCellModel.cellIndex
            .withLatestFrom(self.settingTableViewCellModel.switchValue){ [weak self] index, value -> Bool? in
                self?.model.indexMatching(index: index, matchIndex: IndexPath(row: 0, section: 2), data: value)
            }
            .filterNil()
            .subscribe(onNext: {
                FixInfo.saveSetting.searchOverlapAlert = $0
            })
            .disposed(by: self.bag)
        
        // 메인 혼잡도 이모지 변경
       self.settingTableViewCellModel.cellIndex
            .withLatestFrom(self.settingTableViewCellModel.tfValue){[weak self] index, tf -> String? in
                self?.model.indexMatching(index: index, matchIndex: IndexPath(row: 0, section: 0), data: tf ?? "")
            }
            .filterNil()
            .subscribe(onNext: {
                let label = $0 == "" ? "☹️" : $0
                FixInfo.saveSetting.mainCongestionLabel = label
            })
            .disposed(by: self.bag)
    }
}
