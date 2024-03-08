//
//  EditViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/19.
//

import Foundation

import RxSwift
import RxCocoa

enum EditVCAction {
    case willDisappear
    case backBtnTap
    case deleteCell(SaveStation)
    case moveCell(ItemMovedEvent)
}

class EditViewModel {
    
    // MODEL
    private let editModel: EditModelProtocol
    private let notiManager: NotificationManagerProtocol
    
    // VALUE
    private let nowData = BehaviorRelay<[EditViewCellSection]>(value: [])
    
    weak var delegate: EditVCDelegate?
    private let bag = DisposeBag()
    
    struct Input {
        let actionList: Observable<EditVCAction>
    }
    
    struct Output {
        let cellData: Driver<[EditViewCellSection]>
    }
    
    func transform(input: Input) -> Output {
        self.editModel.fixDataToGroupData(FixInfo.saveStation)
            .asDriver(onErrorDriveWith: .empty())
            .drive(self.nowData)
            .disposed(by: self.bag)
        
        input.actionList
            .bind(onNext: self.actionProcess)
            .disposed(by: self.bag)
        
        return Output(
            cellData: self.nowData
                .delay(.microseconds(500), scheduler: MainScheduler.asyncInstance)
                .asDriver(onErrorDriveWith: .empty())
        )
    }
    
    init(
        model : EditModel = .init(),
        noti: NotificationManagerProtocol = NotificationManager.shared
    ){
        self.editModel = model
        self.notiManager = noti
    }
}

private extension EditViewModel {
    func deleteAlertID(id: String) {
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
            self.deleteAlertID(id: item.id)
            
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
                self.deleteAlertID(id: nowValue[now.section].items[now.row].id)
                nowValue[now.section].items[now.row].group = .one == nowValue[now.section].items[now.row].group ? .two : .one
            }
            
            self.nowData.accept(nowValue)
            
        case .backBtnTap:
            self.delegate?.pop()
            
        case .willDisappear:
            // 데이터 저장
            let nowValue = self.nowData.value
            FixInfo.saveStation = nowValue[0].items + nowValue[1].items
            print(FixInfo.saveStation.map {($0.stationName,$0.group)})
            self.delegate?.disappear()
        }
    }
}
