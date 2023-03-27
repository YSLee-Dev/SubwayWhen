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

typealias schduleResultData = (scheduleData : [ResultSchdule], cellData: DetailLoadData)

class DetailViewModel{
    // MODEL
    let detailModel : DetailModelProtocol
    let headerViewModel : DetailTableHeaderViewModelProtocol
    let arrivalCellModel : DetailTableArrivalCellModelProtocol
    let scheduleCellModel : DetailTableScheduleCellModelProtocol
    
    // INPUT
    let detailViewData = BehaviorRelay<DetailLoadData>(value: .init(upDown: "", subWayId: "", stationName: "", lastStation: "", lineNumber: "", useLine: "", id: "", stationCode: "", exceptionLastStation: "", backStationId: "", nextStationId: "", korailCode: ""))
    let exceptionLastStationRemoveReload = PublishRelay<Void>()
    
    // OUTPUT
    let cellData : Driver<[DetailTableViewSectionData]>
    let moreBtnClickData : Driver<schduleResultData>
    let exceptionLastStationRemoveBtnClick : Driver<DetailLoadData>
    
    // DATA
    let nowData = BehaviorRelay<[DetailTableViewSectionData]>(value: [])
    let scheduleData = PublishRelay<[ResultSchdule]>()
    let arrivalData = PublishRelay<[RealtimeStationArrival]>()
    
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
        
        self.arrivalData
            .bind(to: self.arrivalCellModel.realTimeData)
            .disposed(by: self.bag)
        
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
        
        let realTimeTotal = realTimeData
            .withLatestFrom(self.detailViewData){[weak self] realTime, station -> [RealtimeStationArrival] in
                self?.detailModel.arrivalDataMatching(station: station, arrivalData: realTime) ?? []
        }
            .share()
        
        realTimeTotal
        .bind(to: self.arrivalData)
        .disposed(by: self.bag)
       
        // 일회성 보기 or back,next ID가 없을 때
        realTimeTotal
            .withLatestFrom(self.detailViewData){ real, value -> DetailLoadData? in
                var now = value
                
                if now.backStationId == "" && now.nextStationId == ""{
                    now.nextStationId = real.first?.nextStationId ?? ""
                    now.backStationId = real.first?.backStationId ?? ""
                    return now
                }else{
                    return nil
                }
            }
            .filterNil()
            .bind(to: self.detailViewData)
            .disposed(by: self.bag)
        
    }
}
