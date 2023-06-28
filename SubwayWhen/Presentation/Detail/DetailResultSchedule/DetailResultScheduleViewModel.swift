//
//  DetailResultScheduleViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/25.
//

import Foundation

import RxSwift
import RxCocoa

class DetailResultScheduleViewModel : DetailResultScheduleViewModelProtocol{
    // INPUT
    let scheduleData = BehaviorRelay<[ResultSchdule]>(value: [])
    let cellData = BehaviorRelay<DetailLoadData>(value: .init(upDown: "", stationName: "", lineNumber: "", lineCode: "", useLine: "", stationCode: "", exceptionLastStation: "", backStationId: "", nextStationId: "", korailCode: ""))
    let scheduleVCExceptionStationRemove = PublishRelay<Void>()
    
    // OUTPUT
    let resultDefaultData : Driver<DetailLoadData>
    let groupScheduleData : Driver<[DetailResultScheduleViewSectionData]>
    let nowHourSectionSelect : Driver<Int>
    let scheduleVCExceptionLastStationBtnClick : Driver<Void>
    
    // MODEL
    let detailResultScheduleTopViewModel : DetailResultScheduleTopViewProtocol
    private let detailResultScheduleModel : DetailResultScheduleModelProtocol
    
    private let nowData = BehaviorRelay<[DetailResultScheduleViewSectionData]>(value: [])
    private let sectionNumber = BehaviorRelay<Int>(value: 0)
    
    let bag = DisposeBag()
    
    deinit{
        print("DetailResultScheduleViewModel DEINIT")
    }
    
    init(
        resultModel : DetailResultScheduleModel = .init(),
        topViewModel : DetailResultScheduleTopViewModel = .init()
    ){
        self.detailResultScheduleTopViewModel = topViewModel
        self.detailResultScheduleModel = resultModel
        
        self.resultDefaultData = self.cellData
            .asDriver(onErrorDriveWith: .empty())
        
        self.scheduleVCExceptionLastStationBtnClick = self.detailResultScheduleTopViewModel.exceptionLastStationBtnClick
            .asDriver(onErrorDriveWith: .empty())
        
        self.nowHourSectionSelect = self.sectionNumber
            .asDriver(onErrorDriveWith: .empty())
        
        self.groupScheduleData = self.nowData
            .asDriver(onErrorDriveWith: .empty())
        
        self.nowData
            .map{[weak self] data in
                if FixInfo.saveSetting.detailScheduleAutoTime{
                    let nowHour = Calendar.current.component(.hour, from: Date())
                    return self?.detailResultScheduleModel.nowTimeMatching(data, nowHour: nowHour) ?? 0
                }
                return 0
            }
            .bind(to: self.sectionNumber)
            .disposed(by: self.bag)
        
        
       self.scheduleData
            .map{[weak self] data -> [DetailResultScheduleViewSectionData] in
                self?.detailResultScheduleModel.resultScheduleToDetailResultSection(data) ?? []
            }
            .map{data in
                data.filter{
                    !($0.items.first!.minute.isEmpty)
                }
            }
            .bind(to: self.nowData)
            .disposed(by: self.bag)
    }
}
