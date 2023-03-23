//
//  DetailViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/02.
//

import Foundation

import RxSwift
import RxCocoa
import RxOptional

typealias schduleResultData = (scheduleData : [ResultSchdule], cellData: MainTableViewCellData)

class DetailViewModel{
    // MODEL
    let detailModel : DetailModelProtocol
    let headerViewModel : DetailTableHeaderViewModelProtocol
    let arrivalCellModel : DetailTableArrivalCellModelProtocol
    let scheduleCellModel : DetailTableScheduleCellModelProtocol
    
    // INPUT
    let detailViewData = BehaviorRelay<MainTableViewCellData>(value: .init(upDown: "", arrivalTime: "", previousStation: "", subPrevious: "", code: "지원하지 않는 호선이에요.", subWayId: "", stationName: "", lastStation: "", lineNumber: "", isFast: "", useLine: "", group: "", id: "", stationCode: "", exceptionLastStation: "", type: .real, backStationId: "", nextStationId: "",  korailCode: ""))
    let exceptionLastStationRemoveReload = PublishRelay<Void>()
    
    // OUTPUT
    let cellData : Driver<[DetailTableViewSectionData]>
    let moreBtnClickData : Driver<schduleResultData>
    let exceptionLastStationRemoveBtnClick : Driver<MainTableViewCellData>
    
    // DATA
    let nowData = BehaviorRelay<[DetailTableViewSectionData]>(value: [])
    let scheduleData = PublishRelay<[ResultSchdule]>()
    
    var bag = DisposeBag()
    var timerBag = DisposeBag()
    
    deinit{
        print("DetailViewModel DEINIT")
    }
    
    init(
        headerViewModel : DetailTableHeaderViewModel = .init(),
        arrivalCellModel : DetailTableArrivalCellModel = .init(),
        scheduleCellModel : DetailTableScheduleCellModel = .init(),
        detailModel : DetailModel = .init()
    ){
        // Model Init
        self.detailModel = detailModel
        self.headerViewModel = headerViewModel
        self.arrivalCellModel = arrivalCellModel
        self.scheduleCellModel = scheduleCellModel
        
        self.cellData = self.nowData
            .asDriver(onErrorDriveWith: .empty())
        
        self.scheduleData
            .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: self.scheduleCellModel.scheduleData)
            .disposed(by: self.bag)
        
        let showData = self.scheduleData
            .withLatestFrom(self.detailViewData){ schedule, cell -> schduleResultData in
                schduleResultData(scheduleData: schedule, cellData: cell)
            }
        
        self.moreBtnClickData = self.scheduleCellModel.moreBtnClick
            .withLatestFrom(showData)
            .map{ data -> schduleResultData? in
                if data.scheduleData.first?.startTime == "정보없음" || data.scheduleData.isEmpty{
                    return nil
                }else{
                    return data
                }
            }
            .filterNil()
            .asDriver(onErrorDriveWith: .empty())
        
        self.exceptionLastStationRemoveBtnClick = self.headerViewModel.exceptionLastStationBtnClick
            .withLatestFrom(self.detailViewData)
            .asDriver(onErrorDriveWith: .empty())
        
        // 재로딩 버튼 클릭 시 exception Station 제거
        self.exceptionLastStationRemoveReload
            .withLatestFrom(self.detailViewData)
            .map{
                var now = $0
                now.exceptionLastStation = ""
                return now
            }
            .bind(to: self.detailViewData)
            .disposed(by: self.bag)
        
        // 15초 타이머 초기화
        self.exceptionLastStationRemoveReload
            .withUnretained(self)
            .subscribe(onNext:{ viewModel, _ in
                viewModel.timerBag = DisposeBag()
            })
            .disposed(by: self.bag)
        
        // 15초 타이머 / 처음에만 / 설정 값이 켜져있을때만
        if FixInfo.saveSetting.detailAutoReload{
            Observable<Int>.timer(.seconds(1),period: .seconds(1), scheduler: MainScheduler.instance)
                .bind(to: self.arrivalCellModel.superTimer)
                .disposed(by: self.timerBag)
        }
        
        // 기본 셀 구성
        self.detailViewData
            .withUnretained(self)
            .map{viewModel, data in
                viewModel.detailModel.mainCellDataToDetailSection(data)
            }
            .bind(to: self.nowData)
            .disposed(by: self.bag)
        
        // 시간표 데이터 불러오기
        self.detailViewData
            .withUnretained(self)
            .map{viewModel ,item -> ScheduleSearch in
                viewModel.detailModel.mainCellDataToScheduleSearch(item)
            }
            .withUnretained(self)
            .skip(1)
            .flatMap{ viewModel, data -> Observable<[ResultSchdule]> in
                viewModel.detailModel.scheduleLoad(data)
            }
            .bind(to: self.scheduleData)
            .disposed(by: self.bag)
        
        // 실시간 새로고침 버튼 클릭 시
        let onRefresh = self.arrivalCellModel.refreshBtnClick
            .withLatestFrom(self.detailViewData)
        
        // 실시간 데이터 불러오기
        let realTimeData = onRefresh
            .withUnretained(self)
            .flatMapLatest{ viewModel, data in
                viewModel.detailModel.arrvialDataLoad(data.stationName)
            }
        
        Observable.combineLatest(self.detailViewData, realTimeData){[weak self] station, realTime -> [RealtimeStationArrival] in
            self?.detailModel.arrivalDataMatching(station: station, arrivalData: realTime) ?? []
        }
        .bind(to: self.arrivalCellModel.realTimeData)
        .disposed(by: self.bag)
        
    }
}
