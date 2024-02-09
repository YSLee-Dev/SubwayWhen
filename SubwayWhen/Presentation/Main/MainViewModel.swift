//
//  MainViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/30.
//

import Foundation

import RxSwift
import RxCocoa
import RxOptional

import FirebaseAnalytics

enum MainViewAction {
    case cellTap(IndexPath)
    case scheduleTap(IndexPath)
    case refreshEvent
    case groupTap(SaveStationGroup)
    case reportBtnTap
    case editBtnTap
}

class MainViewModel {
    struct Input {
        let actionList: Observable<MainViewAction>
    }
    
    struct Output {
        let mainTitle: Driver<String>
        let importantData: Driver<ImportantData>
        let tableViewData: Driver<[MainTableViewSection]>
        let peopleData: Driver<Int>
        let groupData: Driver<SaveStationGroup>
        let cellData: Driver<(MainTableViewCellData, Int)>
    }
    
    func trasnform(input: Input) -> Output {
        input.actionList
            .bind(onNext: self.actionProcess)
            .disposed(by: self.bag)
        
        let importantData = self.mainModel.headerImportantDataLoad()
        
        importantData
            .filter {$0.title != ""}
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                // importantData오면 뷰 자체를 다시 그림
                viewModel.tableViewDataSet()
                viewModel.stationLiveDataLoad()
            })
            .disposed(by: self.bag)
        
        return Output(
            mainTitle: self.mainModel.mainTitleLoad()
                .asDriver(onErrorDriveWith: .empty()),
            importantData: importantData
                .asDriver(onErrorDriveWith: .empty()),
            tableViewData: self.nowTableViewCellData
                .filter {$0.1}
                .map {$0.0}
                .asDriver(onErrorDriveWith: .empty()),
            peopleData: self.nowPeopleData
                .asDriver(),
            groupData: self.nowGroupSet
                .filter {!$0.1}
                .map {$0.0}
                .asDriver(onErrorDriveWith: .empty()),
            cellData: self.nowSingleLiveData
                .filterNil()
                .asDriver(onErrorDriveWith: .empty())
        )
    }
    
    // MODEL
    private let mainModel : MainModelProtocol
    
    private let bag = DisposeBag()
    
    // 현재 데이터
    private let nowTableViewCellData = BehaviorRelay<([MainTableViewSection], Bool)>(value: ([], true))
        // false 로 된 데이터는 MainTableView를 재로딩 하지 않고, 값을 저장하는 용도로만 사용함
    private let nowSaveStationEmptyData = BehaviorRelay<[MainTableViewCellData]>(value: [])
    private let nowGroupData = BehaviorRelay<[MainTableViewCellData]>(value: [])
    private let nowGroupSet = BehaviorRelay<(SaveStationGroup, Bool)>(value: (.one, false))
    private let nowPeopleData = BehaviorRelay<Int>(value: 0)
    private let nowSingleLiveData = BehaviorRelay<(MainTableViewCellData, Int)?>(value: nil)
    
    weak var delegate : MainDelegate?
    
    init(
        mainModel : MainModel = .init())
    {
        // Model Init
        self.mainModel = mainModel
    }
}

private extension MainViewModel {
    func actionProcess(type: MainViewAction) {
        switch type {
        case .editBtnTap:
            self.delegate?.pushTap(action: .Edit)
            
        case .reportBtnTap:
            self.delegate?.pushTap(action: .Report)
            
        case .cellTap(let index):
            if index.section != 2 {return}
            
            let nowValue = nowTableViewCellData.value.0[2].items
            if nowValue.count <= index.row {return}
            let cellData = nowValue[index.row]
            
            if cellData.id == "NoData" {
                self.delegate?.plusStationTap()
            } else if cellData.id != "header" && cellData.id != "group" {
                self.delegate?.pushDetailTap(data: cellData)
            }
            
        case .refreshEvent:
            self.mainModel.emptyLiveData(stations: FixInfo.saveStation)
                .bind(to: self.nowSaveStationEmptyData)
                .disposed(by: self.bag)
            
           // 시간에 맞는 그룹 set
           self.mainModel.timeGroup(
               oneTime: FixInfo.saveSetting.mainGroupOneTime,
               twoTime: FixInfo.saveSetting.mainGroupTwoTime,
               nowHour: Calendar.current.component(.hour, from: Date())
               )
           .map {($0, false)}
           .bind(to: self.nowGroupSet)
           .disposed(by: self.bag)
            
            // 혼잡도 세팅
            self.mainModel.congestionDataLoad()
                .bind(to: self.nowPeopleData)
                .disposed(by: self.bag)
            
            // 데이터 로드
            self.tableViewDataSet()
            self.stationLiveDataLoad()
                
        case .scheduleTap(let index):
            scheduleBtnAction(index: index)
            
        case .groupTap(let group):
            self.nowGroupSet.accept((group, true))
            
            // 데이터 로드
            self.tableViewDataSet()
            self.stationLiveDataLoad()
        }
    }
    
    func tableViewDataSet() {
        let data = self.nowSaveStationEmptyData.value.filter {$0.group == self.nowGroupSet.value.0.rawValue}
        self.nowGroupData.accept(data)
        
        self.nowGroupData
            .withUnretained(self)
            .map { viewModel, data in
                (viewModel.mainModel.createMainTableViewSection(data), true)
            }
            .bind(to: self.nowTableViewCellData)
            .disposed(by: self.bag)
    }
    
    func stationLiveDataLoad() {
        let liveData = self.mainModel.arrivalDataLoad(
            stations: FixInfo.saveStation.filter {$0.group ==  self.nowGroupSet.value.0}
        )
            .share()

        liveData
        .bind(to: self.nowSingleLiveData)
        .disposed(by: self.bag)
        
        liveData
            .withUnretained(self)
            .map { viewModel, data -> ([MainTableViewSection], Bool)? in
                var nowSecionData = viewModel.nowTableViewCellData.value.0
                
                if data.0.group != viewModel.nowGroupSet.value.0.rawValue {return nil}
                
                nowSecionData[2].items[data.1] = data.0
                return (nowSecionData, false)
            }
            .filterNil()
            .bind(to: self.nowTableViewCellData)
            .disposed(by: self.bag)
    }
    
    func scheduleBtnAction(index: IndexPath) {
        // 시간표 버튼 클릭
        let clickCellRow = self.nowGroupData.value[index.row]
        
        // 구글 애널리틱스
        Analytics.logEvent("MainVC_cellTimeChangeBtnTap", parameters: [
            "Change" : "BTNTAP"
        ])
        
        // 시간표 검색 구조체로 변환
        guard let searchInfo = self.mainModel.mainCellDataToScheduleData(clickCellRow) else {return}
        
        // 시간표 통신 후 groupData로 바꾸기
        self.mainModel.scheduleLoad(searchInfo)
            .map {[weak self] scheduleData -> [MainTableViewCellData] in
                guard let scheduleData = scheduleData.first else {return []}
                guard let groupData = self?.nowGroupData.value[index.row] else {return []}
                guard let newData = self?.mainModel.scheduleDataToMainTableViewCell(data: scheduleData, nowData: groupData) else {return []}
                
                guard var now = self?.nowGroupData.value else {return []}
                now[index.row] = newData
                return now
            }
            .filterEmpty()
            .bind(to: self.nowGroupData)
            .disposed(by: self.bag)
    }
}
