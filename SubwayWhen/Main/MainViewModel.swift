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
    let model = MainModel()
    let mainTableViewModel = MainTableViewModel()
    let groupViewModel = GroupViewModel()
    
    let bag = DisposeBag()
    
    // 현재 데이터
    private let totalData = BehaviorRelay<[MainTableViewCellData]>(value: [])
    
    // INPUT
    let reloadData = PublishRelay<Void>()
    
    // OUTPUT
    let stationPlusBtnClick : Driver<Void>
    
    init(){
        // view 다시 들어올 때 리프레시
        self.reloadData
            .bind(to: self.mainTableViewModel.refreshOn)
            .disposed(by: self.bag)
        
        // footer 버튼 클릭 시
        self.stationPlusBtnClick = self.mainTableViewModel.mainTableViewFooterViewModel.plusBtnClick
            .asDriver(onErrorDriveWith: .empty())
        
        // 리프레시 할 때 데이터 로드
        self.mainTableViewModel.refreshOn
            .flatMap{
                self.model.totalLiveDataLoad()
            }
            .bind(to: self.totalData)
            .disposed(by: self.bag)
        
        // 모든 데이터를 받은 후 그룹에 맞춰서 return
        let groupData = Observable.combineLatest(self.totalData, self.groupViewModel.groupSeleted){ data, group in
            return data.filter{
                $0.group == group.rawValue
            }
        }
        
        groupData
            .bind(to: self.mainTableViewModel.resultData)
            .disposed(by: self.bag)
        
        // 데이터 삭제
        self.mainTableViewModel.cellDelete
            .map{ data in
                for x in FixInfo.saveStation.enumerated(){
                    if x.element.id == data.id {
                        FixInfo.saveStation.remove(at: x.offset)
                    }
                }
                
                return Void()
            }
            .bind(to: self.mainTableViewModel.refreshOn)
            .disposed(by: self.bag)
        
        // 시간표 버튼 클릭 시
        let clickCellRow = self.mainTableViewModel.mainTableViewCellModel.cellTimeChangeBtnClick
            .map{ id -> Int? in
                for x in FixInfo.saveStation.enumerated() {
                    if x.element.id == id{
                        return x.offset
                    }
                }
                return nil
            }
            .filter{$0 != nil}
            .map{$0!}
        
        let scheduleData = clickCellRow
            .map{ id -> ScheduleSearch in
                let nowData = FixInfo.saveStation[id]
                return ScheduleSearch(stationCode: nowData.stationCode, upDown: nowData.updnLine, exceptionLastStation: nowData.exceptionLastStation, line: nowData.line)
            }
            .flatMap{
                self.model.nowScheduleStationLoad(scheduleSearch: $0)
            }
        
        
        scheduleData
            .withLatestFrom(clickCellRow){ data, row in
                let nowData = self.totalData.value[row]
                let newData = MainTableViewCellData(upDown: data.upDown, arrivalTime: data.startTime, previousStation: data.startTime, subPrevious: "\(data.scheduleTime)분", code: "", subWayId: nowData.subWayId, stationName: nowData.stationName, lastStation: "\(data.lastStation)행", lineNumber: nowData.lineNumber, isFast: "", useLine: nowData.useLine, group: nowData.group, id: nowData.id, stationCode: nowData.stationCode)
                
                var now = self.totalData.value
                now[row] = newData
                
                return now
            }
            .bind(to: self.totalData)
            .disposed(by: self.bag)
        
    }
}
