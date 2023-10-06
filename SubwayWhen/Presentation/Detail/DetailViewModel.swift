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

import FirebaseAnalytics

typealias schduleResultData = (scheduleData : [ResultSchdule], cellData: DetailLoadData)

class DetailViewModel {
    // MODEL
    private let detailModel : DetailModelProtocol
    let headerViewModel : DetailTableHeaderViewModelProtocol
    let arrivalCellModel : DetailTableArrivalCellModelProtocol
    let scheduleCellModel : DetailTableScheduleCellModelProtocol
    
    // INPUT(COORDINATOR)
    let detailViewData = BehaviorRelay<DetailLoadData>(value: .init(upDown: "", stationName: "", lineNumber: "", lineCode: "", useLine: "", stationCode: "", exceptionLastStation: "", backStationId: "", nextStationId: "", korailCode: ""))
    let exceptionLastStationRemoveReload = PublishRelay<Void>()
    
    // DATA
    private let nowData = BehaviorRelay<[DetailTableViewSectionData]>(value: [])
    private let scheduleData = PublishRelay<[ResultSchdule]>()
    private let arrivalData = PublishRelay<[RealtimeStationArrival]>()
    private let scheduleSortedData = PublishSubject<[ResultSchdule]>()
    
    var delegate : DetailVCDelegate?
    
    struct Input {
        let popBtnTap: Observable<Void>
        let disappear: Observable<Void>
    }
    
    struct Output {
        let cellData : Driver<[DetailTableViewSectionData]>
        let isDisposable: Bool
        let headerViewModel: DetailTableHeaderViewModelProtocol
        let arrivalCellModel: DetailTableArrivalCellModelProtocol
        let scheduleCellModel: DetailTableScheduleCellModelProtocol
    }
    
    func transform(input: Input) -> Output {
        self.flowLogic(input)
        
        return Output(
            cellData: self.nowData
                .asDriver(onErrorDriveWith: .empty()),
            isDisposable: self.disposable,
            headerViewModel: self.headerViewModel,
            arrivalCellModel: self.arrivalCellModel,
            scheduleCellModel: self.scheduleCellModel)
    }
    
    var bag = DisposeBag()
    var timerBag = DisposeBag()
    
    var disposable : Bool
    var liveActivity : Bool = false
    
    deinit{
        print("DetailViewModel DEINIT")
    }
    
    init(
        headerViewModel : DetailTableHeaderViewModel = .init(),
        arrivalCellModel : DetailTableArrivalCellModel = .init(),
        scheduleCellModel : DetailTableScheduleCellModel = .init(),
        detailModel : DetailModel = .init(),
        isDisposable: Bool
    ){
        // Model Init
        self.detailModel = detailModel
        self.headerViewModel = headerViewModel
        self.arrivalCellModel = arrivalCellModel
        self.scheduleCellModel = scheduleCellModel
        
        self.disposable = isDisposable
        
        self.scheduleSortedData
            .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: self.scheduleCellModel.scheduleData)
            .disposed(by: self.bag)
        
        self.arrivalData
            .bind(to: self.arrivalCellModel.realTimeData)
            .disposed(by: self.bag)
        
        // 시간표 정렬
        Observable.combineLatest(self.arrivalCellModel.refreshBtnClick, self.scheduleData){
            $1
        }
            .withUnretained(self)
            .map{ viewModel, data in
                if FixInfo.saveSetting.detailScheduleAutoTime{
                    return viewModel.detailModel.scheduleSort(data)
                }else{
                    return data
                }
            }
            .bind(to: self.scheduleSortedData)
            .disposed(by: self.bag)
        
        // liveActivityArrivalData 값 조합 후 넘기기(refresh 버튼 클릭 시 마다 업데이트 (초기값 O))
        self.scheduleSortedData
            .withLatestFrom(self.detailViewData){ schedule, detail -> DetailActivityLoadData? in
                guard FixInfo.saveSetting.liveActivity == true else {return nil}
                guard schedule.first?.startTime != "정보없음" else {return nil}
                
                var list = schedule.map{
                    "⏱️ \($0.useArrTime)"
                }
                
                list = list.count >= 6 ? (Array(list[0...4])) : list
                
                let minute = Calendar.current.component(.minute, from: Date())
                let hour = Calendar.current.component(.hour, from: Date())
                
                return DetailActivityLoadData(saveStation: detail.stationName, saveLine: detail.useLine, scheduleList: list, lastUpdate: "\(hour)시 \(minute)분 기준")
            }
            .filterNil()
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                viewModel.liveActivitySet(data)
            })
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
        
        // 구글 애널리틱스
        self.exceptionLastStationRemoveReload
            .subscribe(onNext: {
                Analytics.logEvent("DetailVC_ExceptionBtnTap", parameters: [
                    "Exception" : "BTNTAP"
                ])
            })
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
            .delay(.microseconds(100), scheduler: MainScheduler.asyncInstance)
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

private extension DetailViewModel {
    func flowLogic(_ input: Input) {
        self.headerViewModel.exceptionLastStationBtnClick
            .withLatestFrom(self.detailViewData)
            .map {$0.exceptionLastStation}
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                viewModel.delegate?.exceptionLastStationPopup(station: data)
            })
            .disposed(by: self.bag)
        
        let showData = self.scheduleData
            .withLatestFrom(self.detailViewData){ schedule, cell -> schduleResultData in
                schduleResultData(scheduleData: schedule, cellData: cell)
        }
        
        self.scheduleCellModel.moreBtnClick
            .withLatestFrom(showData)
            .map{ data -> schduleResultData? in
                if data.scheduleData.first?.startTime == "정보없음" || data.scheduleData.isEmpty{
                    return nil
                }else{
                    return data
                }
            }
            .filterNil()
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                viewModel.delegate?.scheduleTap(schduleResultData: data)
            })
            .disposed(by: self.bag)
        
        input.disappear
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                viewModel.delegate?.disappear()
            })
            .disposed(by: self.bag)
        
        input.popBtnTap
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                viewModel.delegate?.pop()
            })
            .disposed(by: self.bag)
    }
    
    func liveActivitySet(_ data: DetailActivityLoadData) {
        guard !self.disposable else {return}
        
        if !self.liveActivity {
            SubwayWhenDetailWidgetManager.shared.start(stationLine: data.saveLine, saveStation: data.saveStation, scheduleList: data.scheduleList, lastUpdate: data.lastUpdate)
            self.liveActivity = !self.liveActivity
        } else{
            SubwayWhenDetailWidgetManager.shared.update(scheduleList: data.scheduleList, lastUpdate: data.lastUpdate)
        }
    }
}
