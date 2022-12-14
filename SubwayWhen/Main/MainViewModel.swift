//
//  MainViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/30.
//

import Foundation

import RxSwift
import RxCocoa

class MainViewModel{
    // MODEL
    let model = LoadModel()
    let mainTableViewModel = MainTableViewModel()
    let groupViewModel = GroupViewModel()
    
    let bag = DisposeBag()
    
    // 현재 데이터
    private let groupData = BehaviorRelay<[MainTableViewSection]>(value: [MainTableViewSection(section: "", stationID: "", items: [])])
    
    // INPUT
    let reloadData = PublishRelay<Void>()
    
    // OUTPUT
    let stationPlusBtnClick : Driver<Void>
    let editBtnClick : Driver<Void>
    let clickCellData : Driver<MainTableViewCellData>
    
    init(){
        // view 다시 들어올 때 리프레시
        self.reloadData
            .bind(to: self.mainTableViewModel.refreshOn)
            .disposed(by: self.bag)
        
        // footer 버튼 클릭 시
        self.stationPlusBtnClick = self.mainTableViewModel.mainTableViewFooterViewModel.plusBtnClick
            .asDriver(onErrorDriveWith: .empty())
        
        // edit 버튼 클릭 시
        self.editBtnClick = self.mainTableViewModel.mainTableViewFooterViewModel.editBtnClick
            .asDriver(onErrorDriveWith: .empty())
        
        self.clickCellData = self.mainTableViewModel.cellClick
            .asDriver(onErrorDriveWith: .empty())
        
        // 리프레시 할 때 데이터 로드
        let totalData = self.mainTableViewModel.refreshOn
            .flatMap{
                self.model.totalLiveDataLoad()
            }
        
        // 모든 데이터를 받은 후 그룹에 맞춰서 return
       Observable.combineLatest(totalData, self.groupViewModel.groupSeleted){ data, group in
            return data.filter{
                $0.section == group.rawValue
            }
        }
       .bind(to: self.groupData)
       .disposed(by: self.bag)
        
        self.groupData
            .bind(to: self.mainTableViewModel.resultData)
            .disposed(by: self.bag)
        
        // 시간표 불러오기
        let clickCellRow = self.mainTableViewModel.mainTableViewCellModel.cellTimeChangeBtnClick
            .withLatestFrom(self.groupData){ id, data in
                data[id.section].items[id.row]
            }
        
        let scheduleData = clickCellRow
            .map{ item -> ScheduleSearch? in
                if item.type == .real{
                    return ScheduleSearch(stationCode: item.stationCode, upDown: item.upDown, exceptionLastStation: item.exceptionLastStation, line: item.lineNumber)
                }else{
                    return nil
                }
            }
            .filter{$0 != nil}
            .flatMap{
                self.model.nowScheduleStationLoad(scheduleSearch: $0!)
            }
        
        
        scheduleData
            .withLatestFrom(self.mainTableViewModel.mainTableViewCellModel.cellTimeChangeBtnClick){ data, index in
                let nowData = self.groupData.value[index.section].items[index.row]
                let newData = MainTableViewCellData(upDown: data.upDown, arrivalTime: data.startTime, previousStation: "⏱️\(data.startTime)", subPrevious: "\(data.scheduleTime)분", code: "", subWayId: nowData.subWayId, stationName: nowData.stationName, lastStation: "\(data.lastStation)행", lineNumber: nowData.lineNumber, isFast: "", useLine: nowData.useLine, group: nowData.group, id: nowData.id, stationCode: nowData.stationCode, exceptionLastStation: nowData.exceptionLastStation, type: .schedule, backStationId: nowData.backStationId, nextStationId: nowData.nextStationId)
                
                var now = self.groupData.value
                now[index.section].items[index.row] = newData
                
                return now
            }
            .bind(to: self.groupData)
            .disposed(by: self.bag)
        
    }
}
