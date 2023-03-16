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

class SettingViewModel {
    // OUTPUT
    let cellData : Driver<[SettingTableViewCellSection]>
    let keyboardClose : Driver<Void>
    let modalPresent : Driver<SettingTableViewCellData>
    
    // INPUT
    let cellClick = PublishRelay<SettingTableViewCellData>()
    
    // MODEL
    let settingTableViewCellModel = SettingTableViewCellModel()
    
    let bag = DisposeBag()
    
    init(){
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
        self.cellData = Observable<[SettingTableViewCellSection]>.create{
            $0.onNext(
                [
                    SettingTableViewCellSection(sectionName: "홈", items: [
                        .init(settingTitle: "혼잡도 이모지", defaultData: FixInfo.saveSetting.mainCongestionLabel ,inputType: .TextField, groupType: .Main),
                        .init(settingTitle: "특정 그룹 시간", defaultData: "", inputType: .NewVC, groupType: .Main)
                    ]),
                    SettingTableViewCellSection(sectionName: "상세화면", items: [
                        .init(settingTitle: "자동 새로 고침",defaultData: "\(FixInfo.saveSetting.detailAutoReload)", inputType: .Switch, groupType: .Detail),
                        .init(settingTitle: "시간표 자동 정렬",defaultData: "\(FixInfo.saveSetting.detailScheduleAutoTime)", inputType: .Switch, groupType: .Detail)
                    ]),
                    SettingTableViewCellSection(sectionName: "검색", items: [
                        .init(settingTitle: "중복 저장 방지",defaultData: "\(FixInfo.saveSetting.searchOverlapAlert)", inputType: .Switch, groupType: .Detail)
                    ]),
                    SettingTableViewCellSection(sectionName: "기타", items: [
                        .init(settingTitle: "오픈 라이선스", defaultData: "", inputType: .NewVC, groupType: .Other),
                        .init(settingTitle: "기타", defaultData: "", inputType: .NewVC, groupType: .Other)
                    ])
                ]
            )
            $0.onCompleted()
            
            return Disposables.create()
        }
        .asDriver(onErrorDriveWith: .empty())
        
        // 자동 새로고침 여부
        self.settingTableViewCellModel.cellIndex
            .withLatestFrom(self.settingTableViewCellModel.switchValue){ index, value -> Bool? in
                if index == IndexPath(row: 0, section: 1){
                    return value
                }else{
                    return nil
                }
            }
            .filterNil()
            .subscribe(onNext: {
                FixInfo.saveSetting.detailAutoReload = $0
            })
            .disposed(by: self.bag)
        
        // 시간표 정렬
        self.settingTableViewCellModel.cellIndex
            .withLatestFrom(self.settingTableViewCellModel.switchValue){ index, value -> Bool? in
                if index == IndexPath(row: 1, section: 1){
                    return value
                }else{
                    return nil
                }
            }
            .filterNil()
            .subscribe(onNext: {
                FixInfo.saveSetting.detailScheduleAutoTime = $0
            })
            .disposed(by: self.bag)
        
        // 중복 저장 방지
        self.settingTableViewCellModel.cellIndex
            .withLatestFrom(self.settingTableViewCellModel.switchValue){ index, value -> Bool? in
                if index == IndexPath(row: 0, section: 2){
                    return value
                }else{
                    return nil
                }
            }
            .filterNil()
            .subscribe(onNext: {
                FixInfo.saveSetting.searchOverlapAlert = $0
            })
            .disposed(by: self.bag)
        
        // 메인 혼잡도 이모지 변경
       self.settingTableViewCellModel.cellIndex
            .withLatestFrom(self.settingTableViewCellModel.tfValue){ index, tf -> String? in
                if index == IndexPath(row: 0, section: 0){
                    return tf
                }else{
                    return nil
                }
            }
            .filterNil()
            .subscribe(onNext: {
                let label = $0 == "" ? "😵" : $0
                FixInfo.saveSetting.mainCongestionLabel = label
                print("바꿈")
            })
            .disposed(by: self.bag)
    }
}
