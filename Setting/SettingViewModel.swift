//
//  SettingViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/16.
//

import Foundation

import RxSwift
import RxCocoa

class SettingViewModel {
    // OUTPUT
    let cellData : Driver<[SettingTableViewCellSection]>
    
    // MODEL
    let settingTableViewCellModel = SettingTableViewCellModel()
    
    let bag = DisposeBag()
    
    init(){
        self.cellData = Observable<[SettingTableViewCellSection]>.create{
            $0.onNext(
                [
                    SettingTableViewCellSection(sectionName: "메인", items: [
                        .init(settingTitle: "혼잡도 이모지", defaultData: FixInfo.saveSetting.mainCongestionLabel ,inputType: .TextField, groupType: .Main),
                        .init(settingTitle: "특정 그룹 시간", defaultData: "\(FixInfo.saveSetting.mainGroupTime)분", inputType: .NewVC, groupType: .Main)
                    ]),
                    SettingTableViewCellSection(sectionName: "상세화면", items: [
                        .init(settingTitle: "자동 새로 고침",defaultData: "\(FixInfo.saveSetting.detailAutoReload)", inputType: .Switch, groupType: .Detail)
                    ])
                ]
            )
            $0.onCompleted()
            
            return Disposables.create()
        }
        .asDriver(onErrorDriveWith: .empty())
        
        // 자동 새로고침 여부
        self.settingTableViewCellModel.switchValue
            .subscribe(onNext: {
                FixInfo.saveSetting.detailAutoReload = $0
            })
            .disposed(by: self.bag)
        
        // 메인 혼잡도 이모지 변경
        self.settingTableViewCellModel.tfValue
            .subscribe(onNext: {
                let label = $0 ?? "😵"
                FixInfo.saveSetting.mainCongestionLabel = label
                print(FixInfo.saveSetting)
            })
            .disposed(by: self.bag)
    }
}
