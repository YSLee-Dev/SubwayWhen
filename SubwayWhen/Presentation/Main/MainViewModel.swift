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

class MainViewModel{
    // MODEL
    let mainTableViewModel : MainTableViewModelProtocol
    let mainModel : MainModelProtocol
    
    let bag = DisposeBag()
    
    // 현재 데이터
    private let groupData = BehaviorRelay<[MainTableViewCellData]>(value: [])
    private let totalData = BehaviorRelay<[MainTableViewCellData]>(value: [])
    
    // INPUT
    let reloadData = PublishRelay<Void>()
    
    // OUTPUT
    let reportBtnClick : Driver<Void>
    let stationPlusBtnClick : Driver<Void>
    let editBtnClick : Driver<Void>
    let clickCellData : Driver<MainTableViewCellData>
    let mainTitle : Driver<String>
    let mainTitleHidden : Driver<Void>
    
    init(
        mainTableViewModel : MainTableViewModel = .init(),
        mainModel : MainModel = .init())
    {
        // Model Init
        self.mainModel = mainModel
        self.mainTableViewModel = mainTableViewModel
        
        // 메인 타이틀(요일마다 변경)
        self.mainTitle = Observable<String>.create{
            let data = Calendar.current.component(.weekday, from: Date())
            if data == 1 || data == 7{
                // 주말
                let weekend = ["행복하고 즐거운 주말\n좋은 하루 보내세요!",
                               "행복한 일만 가득한 주말\n행복한 주말 보내세요!",
                ]
                $0.onNext(weekend.randomElement() ?? "행복하고 즐거운 주말이에요!\n좋은 하루 보내세요!")
            }else if data == 2{
                // 월요일
                $0.onNext("월요일,\n한 주도 화이팅해봐요!")
            }else if data == 3{
                // 화요일
                $0.onNext("화요일,\n평범하지만 행복한 날로 만들어봐요!")
            }else if data == 4{
                // 수요일
                $0.onNext("수요일, \n수많은 즐거움이 가득할거에요!")
            }else if data == 5{
                // 목요일
                $0.onNext("목요일,\n주말까지 단 2일 남았어요!")
            }else if data == 6{
                // 금요일
                $0.onNext("금요일,\n행복한 하루 보내세요!")
            }
            $0.onCompleted()
            
            return Disposables.create()
        }
        .asDriver(onErrorDriveWith: .empty())
        
        // 민원 버튼 클릭 시
        self.reportBtnClick = self.mainTableViewModel.mainTableViewHeaderViewModel.reportBtnClick
            .asDriver(onErrorDriveWith: .empty())
        
        // 검색,플러스 버튼 클릭 시
        self.stationPlusBtnClick = self.mainTableViewModel.plusBtnClick
            .asDriver(onErrorDriveWith: .empty())
        
        // edit 버튼 클릭 시
        self.editBtnClick = self.mainTableViewModel.mainTableViewHeaderViewModel.editBtnClick
            .asDriver(onErrorDriveWith: .empty())
        
        // 그룹 변경 시 타이틀 제거
        self.mainTitleHidden = self.mainTableViewModel.mainTableViewGroupModel.groupSeleted
            .map{_ in Void()}
            .asDriver(onErrorDriveWith: .empty())
        
        // 셀 클릭 시
        self.clickCellData = self.mainTableViewModel.cellClick
            .asDriver(onErrorDriveWith: .empty())
        
        
        // 모든 데이터를 받은 후 그룹에 맞춰서 return
        Observable.combineLatest(self.totalData, self.mainTableViewModel.mainTableViewGroupModel.groupSeleted){ data, group in
            return data.filter{
                $0.group == group.rawValue
            }
        }
        .bind(to: self.groupData)
        .disposed(by: self.bag)
        
        
        // 데이터 리로드 할 때(메인VC 데이터 리로드는 2초에 한번으로 제한)
        let reload = Observable.merge(
            self.reloadData.asObservable(),
            self.mainTableViewModel.refreshOn.asObservable()
        )
            .throttle(.seconds(1), latest: false ,scheduler: MainScheduler.instance)
            .share()
        
        // 데이터 리로딩 전 기존 데이터 삭제
        reload
            .flatMap{[weak self] _ in
                self?.mainModel.totalDataRemove() ?? .never()
            }
            .bind(to: self.totalData)
            .disposed(by: self.bag)
        
        // 지하철 데이터를 하나 씩 받음, 기존 total데이터를 받아, 배열 형태에 추가한 후 totalData에 전달
        reload
            .flatMap{[weak self] _ in
                self?.mainModel.arrivalDataLoad(stations: FixInfo.saveStation) ?? .never()
            }
            .withUnretained(self)
            .map{viewModel, data in
                var now = viewModel.totalData.value
                now.append(data)
                return now
            }
            .bind(to: self.totalData)
            .disposed(by: self.bag)
        
        // 시간에 맞는 그룹 set
        reload
            .flatMap{[weak self] in
                self?.mainModel.timeGroup(oneTime: FixInfo.saveSetting.mainGroupOneTime, twoTime: FixInfo.saveSetting.mainGroupTwoTime) ?? .never()
            }
            .bind(to: self.mainTableViewModel.mainTableViewGroupModel.groupSeleted)
            .disposed(by: self.bag)
        
        // 혼잡도 세팅
        reload
            .flatMap{[weak self] in
                self?.mainModel.congestionDataLoad() ?? .never()
            }
            .bind(to: self.mainTableViewModel.mainTableViewHeaderViewModel.congestionData)
            .disposed(by: self.bag)
        
        // 데이터 로드
        self.groupData
            .map{[weak self] data -> [MainTableViewSection]in
                self?.mainModel.mainSectionDataLoad(data) ?? []
            }
            .bind(to: self.mainTableViewModel.resultData)
            .disposed(by: self.bag)
        
        // 시간표 버튼 클릭
        let clickCellRow = self.mainTableViewModel.mainTableViewCellModel.cellTimeChangeBtnClick
            .withLatestFrom(self.groupData){ id, data in
                data[id.row]
            }
        
        // 시간표 검색 구조체로 변환
        let scheduleData = clickCellRow
            .map{ [weak self] item -> ScheduleSearch? in
                self?.mainModel.mainCellDataToScheduleData(item)
            }
            .filterNil()
        
        // 시간표 통신
        let scheduleTotalData = scheduleData
            .withUnretained(self)
            .flatMap{viewModel, data -> Observable<[ResultSchdule]> in
                viewModel.mainModel.scheduleLoad(data)
            }
        
        // 통신 후 groupData로 바꾸기
        scheduleTotalData
            .withLatestFrom(self.mainTableViewModel.mainTableViewCellModel.cellTimeChangeBtnClick){[weak self] scheduleData, index -> [MainTableViewCellData] in
                guard let scheduleData = scheduleData.first else {return []}
                guard let groupData = self?.groupData.value[index.row] else {return []}
                guard let newData = self?.mainModel.scheduleDataToMainTableViewCell(data: scheduleData, nowData: groupData) else {return []}
                
                guard var now = self?.groupData.value else {return []}
                now[index.row] = newData
                return now
            }
            .filterEmpty()
            .bind(to: self.groupData)
            .disposed(by: self.bag)
    }
}
