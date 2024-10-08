//
//  EditViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/19.
//

import Foundation

import RxSwift
import RxCocoa
import WidgetKit

enum EditVCAction {
    case willDisappear
    case backBtnTap
    case deleteCell(SaveStation)
    case moveCell(ItemMovedEvent)
    case saveBtnTap
}

class EditViewModel {
    
    // MODEL
    private let editModel: EditModelProtocol
    private let notiManager: NotificationManagerProtocol
    private let coreDataManager: CoreDataScheduleManagerProtocol
    
    // VALUE
    private let nowData = BehaviorRelay<[EditViewCellSection]>(value: [])
    private let lastSaveData = BehaviorRelay<[SaveStation]>(value: [])
    private let nowSaveBtnIsEnabled = BehaviorRelay<Bool>(value: false)
    private var removeAlertList: [String] = []
    private var removeShinbundagLine: [String] = []
    
    // Coordinator -> ViewModel
    /// Coordinator가 ViewModel에게 지하철역 저장을 요청할 때 사용
    let requestSave = PublishSubject<Void>()
    
    weak var delegate: EditVCDelegate?
    private let bag = DisposeBag()
    
    struct Input {
        let actionList: Observable<EditVCAction>
    }
    
    struct Output {
        let cellData: Driver<[EditViewCellSection]>
        let saveBtnIsEnabled: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        let saveGroupData = self.editModel.fixDataToGroupData(FixInfo.saveStation)
            .asDriver(onErrorDriveWith: .empty())
        
        saveGroupData
            .drive(self.nowData)
            .disposed(by: self.bag)
        
        saveGroupData
            .map { $0[0].items + $0[1].items}
            .drive(self.lastSaveData)
            .disposed(by: self.bag)
        
        requestSave
            .bind(onNext: self.stationsSave)
            .disposed(by: self.bag)
        
        nowData
            .withUnretained(self)
            .map { viewModel, data in
                let changeData = data[0].items + data[1].items
                let lastSave = viewModel.lastSaveData.value
                
                return changeData != lastSave
            }
            .bind(to: self.nowSaveBtnIsEnabled)
            .disposed(by: self.bag)
        
        input.actionList
            .bind(onNext: self.actionProcess)
            .disposed(by: self.bag)
        
        return Output(
            cellData: self.nowData
                .delay(.microseconds(500), scheduler: MainScheduler.asyncInstance)
                .asDriver(onErrorDriveWith: .empty()),
            saveBtnIsEnabled: self.nowSaveBtnIsEnabled
                .asDriver()
        )
    }
    
    init(
        model : EditModel = .init(),
        noti: NotificationManagerProtocol = NotificationManager.shared,
        coreDataManager: CoreDataScheduleManagerProtocol = CoreDataScheduleManager.shared
    ){
        self.editModel = model
        self.notiManager = noti
        self.coreDataManager = coreDataManager
    }
}

private extension EditViewModel {
    func removeAlertID(id: String) {
        if FixInfo.saveSetting.alertGroupOneID == id {
            FixInfo.saveSetting.alertGroupOneID = ""
            self.notiManager.notiRemove(id: id)
            
        } else if FixInfo.saveSetting.alertGroupTwoID == id {
            FixInfo.saveSetting.alertGroupTwoID = ""
            self.notiManager.notiRemove(id: id)
        }
    }
    
    func actionProcess(type: EditVCAction) {
        switch type {
        case .deleteCell(let item):
            removeAlertList.append(item.id)
            if item.line == "신분당선" {
                self.removeShinbundagLine.append(item.stationName)
            }
            
            var nowValue = self.nowData.value
            var groupOne = nowValue[0].items
            var groupTwo = nowValue[1].items
            
            let removeOne = groupOne.firstIndex(of: item)
            let removeTwo = groupTwo.firstIndex(of: item)
            
            if let removeOne = removeOne {
                groupOne.remove(at: removeOne)
            }
            if let removeTwo = removeTwo {
                groupTwo.remove(at: removeTwo)
            }
            
            nowValue[0].items = groupOne
            nowValue[1].items = groupTwo
            self.nowData.accept(nowValue)
            
        case .moveCell(let itemMovedEvent):
            var nowValue = self.nowData.value
            
            let old = itemMovedEvent.sourceIndex
            let now = itemMovedEvent.destinationIndex
            
            let value = nowValue[old.section].items.remove(at: old.row)
            nowValue[now.section].items.insert(value, at: now.row)
            
            if old[0] != now[0] {
                removeAlertList.append(nowValue[now.section].items[now.row].id)
                nowValue[now.section].items[now.row].group = .one == nowValue[now.section].items[now.row].group ? .two : .one
            }
            
            self.nowData.accept(nowValue)
            
        case .backBtnTap:
            if self.nowSaveBtnIsEnabled.value {
                self.delegate?.notSaveCheck()
            } else {
                self.delegate?.pop()
            }
            
        case .saveBtnTap:
            // 데이터 저장
            self.stationsSave()
            
        case .willDisappear:
            self.delegate?.disappear()
        }
    }
}

private extension EditViewModel {
    func stationsSave() {
        // 데이터 저장
        let nowValue = self.nowData.value
        let newValue = nowValue[0].items + nowValue[1].items
        
        FixInfo.saveStation = newValue
        self.lastSaveData.accept(newValue)
        self.nowSaveBtnIsEnabled.accept(false)
        
        // 알림 삭제
        self.removeAlertList.forEach {
            self.removeAlertID(id: $0)
        }
        self.removeAlertList = []
        
        // 신분당선 지하철 시간표 삭제
        for removeStation in self.removeShinbundagLine {
            self.coreDataManager.shinbundangScheduleDataRemove(stationName: removeStation)
        }
        self.removeShinbundagLine = []
        
        WidgetCenter.shared.reloadTimelines(ofKind: "SubwayWhenHomeWidget")
    }
}
