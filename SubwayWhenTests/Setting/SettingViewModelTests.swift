//
//  SettingViewModelTests.swift
//  SubwayWhenTests
//
//  Created by 이윤수 on 2023/03/29.
//

import XCTest

import RxSwift
import RxCocoa
import RxTest
import RxBlocking
import RxOptional
import Nimble

@testable import SubwayWhen

class SettingViewModelTests : XCTestCase{
    var model : SettingModelProtocol!
    let bag = DisposeBag()
    
    override func setUp() {
        self.model = SettingModel()
    }
    
    func testSettingTableViewList(){
        // GIVEN
        let scheduler = TestScheduler(initialClock: 0)
        let settingList = BehaviorRelay<[SettingTableViewCellSection]>(value: [])
        let observer = scheduler.createObserver([SettingTableViewCellSection].self)
        
        settingList
            .subscribe(observer)
            .disposed(by: self.bag)
        
        let settingData =  [
            SettingTableViewCellSection(sectionName: "홈", items: [
                .init(settingTitle: "혼잡도 이모지", defaultData: "이모지" ,inputType: .TextField, groupType: .Main),
                .init(settingTitle: "특정 그룹 시간", defaultData: "", inputType: .NewVC, groupType: .Main)
            ]),
            SettingTableViewCellSection(sectionName: "상세화면", items: [
                .init(settingTitle: "자동 새로 고침",defaultData: "false", inputType: .Switch, groupType: .Detail),
                .init(settingTitle: "시간표 자동 정렬",defaultData: "false", inputType: .Switch, groupType: .Detail)
            ]),
            SettingTableViewCellSection(sectionName: "검색", items: [
                .init(settingTitle: "중복 저장 방지",defaultData: "false", inputType: .Switch, groupType: .Detail)
            ]),
            SettingTableViewCellSection(sectionName: "기타", items: [
                .init(settingTitle: "오픈 라이선스", defaultData: "", inputType: .NewVC, groupType: .Other),
                .init(settingTitle: "기타", defaultData: "", inputType: .NewVC, groupType: .Other)
            ])
        ]
        
        // WHEN
        scheduler.createHotObservable([
            .next(1, settingData)
        ])
        .bind(to: settingList)
        .disposed(by: self.bag)
      
        let autoRefreshEvent = scheduler.createColdObservable([
            .next(3, true),
            .next(6, false)
        ])
        let autoRefresh = PublishSubject<Bool>()
        autoRefreshEvent
            .subscribe(autoRefresh)
            .disposed(by: self.bag)
        
        let autoIndexEvent = scheduler.createColdObservable([
            .next(3, IndexPath(row: 0, section: 1)),
            .next(6, IndexPath(row: 0, section: 1))
        ])
        let autoIndex = PublishSubject<IndexPath>()
        autoIndexEvent
            .subscribe(autoIndex)
            .disposed(by: self.bag)
        
        autoIndex
            .withLatestFrom(autoRefresh){ index, refresh in
                var now = settingList.value
                now[1].items[0].defaultData = "\(refresh)"
                
                return now
            }
            .bind(to: settingList)
            .disposed(by: self.bag)
        
        scheduler.start()
        
        // THEN
        expect(observer.events).to(
            equal([
                .next(0, []),
                .next(1, [
                    SettingTableViewCellSection(sectionName: "홈", items: [
                        .init(settingTitle: "혼잡도 이모지", defaultData: "이모지" ,inputType: .TextField, groupType: .Main),
                        .init(settingTitle: "특정 그룹 시간", defaultData: "", inputType: .NewVC, groupType: .Main)
                    ]),
                    SettingTableViewCellSection(sectionName: "상세화면", items: [
                        .init(settingTitle: "자동 새로 고침",defaultData: "false", inputType: .Switch, groupType: .Detail),
                        .init(settingTitle: "시간표 자동 정렬",defaultData: "false", inputType: .Switch, groupType: .Detail)
                    ]),
                    SettingTableViewCellSection(sectionName: "검색", items: [
                        .init(settingTitle: "중복 저장 방지",defaultData: "false", inputType: .Switch, groupType: .Detail)
                    ]),
                    SettingTableViewCellSection(sectionName: "기타", items: [
                        .init(settingTitle: "오픈 라이선스", defaultData: "", inputType: .NewVC, groupType: .Other),
                        .init(settingTitle: "기타", defaultData: "", inputType: .NewVC, groupType: .Other)
                    ])
                ]),
                .next(3, [
                    SettingTableViewCellSection(sectionName: "홈", items: [
                        .init(settingTitle: "혼잡도 이모지", defaultData: "이모지" ,inputType: .TextField, groupType: .Main),
                        .init(settingTitle: "특정 그룹 시간", defaultData: "", inputType: .NewVC, groupType: .Main)
                    ]),
                    SettingTableViewCellSection(sectionName: "상세화면", items: [
                        .init(settingTitle: "자동 새로 고침",defaultData: "true", inputType: .Switch, groupType: .Detail),
                        .init(settingTitle: "시간표 자동 정렬",defaultData: "false", inputType: .Switch, groupType: .Detail)
                    ]),
                    SettingTableViewCellSection(sectionName: "검색", items: [
                        .init(settingTitle: "중복 저장 방지",defaultData: "false", inputType: .Switch, groupType: .Detail)
                    ]),
                    SettingTableViewCellSection(sectionName: "기타", items: [
                        .init(settingTitle: "오픈 라이선스", defaultData: "", inputType: .NewVC, groupType: .Other),
                        .init(settingTitle: "기타", defaultData: "", inputType: .NewVC, groupType: .Other)
                    ])
                ]),
                .next(6, [
                    SettingTableViewCellSection(sectionName: "홈", items: [
                        .init(settingTitle: "혼잡도 이모지", defaultData: "이모지" ,inputType: .TextField, groupType: .Main),
                        .init(settingTitle: "특정 그룹 시간", defaultData: "", inputType: .NewVC, groupType: .Main)
                    ]),
                    SettingTableViewCellSection(sectionName: "상세화면", items: [
                        .init(settingTitle: "자동 새로 고침",defaultData: "false", inputType: .Switch, groupType: .Detail),
                        .init(settingTitle: "시간표 자동 정렬",defaultData: "false", inputType: .Switch, groupType: .Detail)
                    ]),
                    SettingTableViewCellSection(sectionName: "검색", items: [
                        .init(settingTitle: "중복 저장 방지",defaultData: "false", inputType: .Switch, groupType: .Detail)
                    ]),
                    SettingTableViewCellSection(sectionName: "기타", items: [
                        .init(settingTitle: "오픈 라이선스", defaultData: "", inputType: .NewVC, groupType: .Other),
                        .init(settingTitle: "기타", defaultData: "", inputType: .NewVC, groupType: .Other)
                    ])
                ])
            ])
            )
    }
         
}
