//
//  SettingModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

import RxSwift

class SettingModel : SettingModelProtocol{
    func createSettingList() -> Observable<[SettingTableViewCellSection]>{
        Observable<[SettingTableViewCellSection]>.create{
            $0.onNext(
                [
                    SettingTableViewCellSection(sectionName: "홈", items: [
                        .init(settingTitle: "혼잡도 이모지", defaultData: FixInfo.saveSetting.mainCongestionLabel ,inputType: .TextField, groupType: .Main),
                        .init(settingTitle: SettingNewVCType.groupModal.rawValue, defaultData: "", inputType: .NewVC, groupType: .Main),
                        .init(settingTitle: SettingNewVCType.notiModal.rawValue, defaultData: "", inputType: .NewVC, groupType: .Main)
                    ]),
                    SettingTableViewCellSection(sectionName: "상세화면", items: [
                        .init(settingTitle: "자동 새로 고침",defaultData: "\(FixInfo.saveSetting.detailAutoReload)", inputType: .Switch, groupType: .Detail),
                        .init(settingTitle: "시간표 자동 정렬",defaultData: "\(FixInfo.saveSetting.detailScheduleAutoTime)", inputType: .Switch, groupType: .Detail),
                        .init(settingTitle: "Live Activity (잠금화면)",defaultData: "\(FixInfo.saveSetting.liveActivity)", inputType: .Switch, groupType: .Detail),
                        .init(settingTitle: SettingNewVCType.trainIcon.rawValue, defaultData: "\(FixInfo.saveSetting.detailVCTrainIcon)", inputType: .NewVC, groupType: .Detail)
                    ]),
                    SettingTableViewCellSection(sectionName: "검색", items: [
                        .init(settingTitle: "중복 저장 방지",defaultData: "\(FixInfo.saveSetting.searchOverlapAlert)", inputType: .Switch, groupType: .Search)
                    ]),
                    SettingTableViewCellSection(sectionName: "기타", items: [
                        .init(settingTitle: SettingNewVCType.licenseModal.rawValue, defaultData: "", inputType: .NewVC, groupType: .Other),
                        .init(settingTitle: SettingNewVCType.contentsModal.rawValue, defaultData: "", inputType: .NewVC, groupType: .Other)
                    ])
                ]
            )
            $0.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func indexMatching<T>(index : IndexPath, matchIndex : IndexPath, data : T) -> T?{
        if index == matchIndex{
            return data
        }else{
            return nil
        }
    }
}
