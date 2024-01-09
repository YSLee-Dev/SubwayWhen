//
//  EditViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/19.
//

import Foundation

import RxSwift
import RxCocoa

class EditViewModel {
    
    // MODEL
    private let editModel : EditModelProtocol
    private let notiManager: NotificationManagerProtocol
    
    // VALUE
    private let nowData = BehaviorSubject<[EditViewCellSection]>(value: [])
    
    private let bag = DisposeBag()
    
    struct Input {
        let deleteCell: Observable<String>
        let refreshOn: Observable<Void>
        let moveCell: Observable<ItemMovedEvent>
    }
    
    struct Output {
        let cellData: Driver<[EditViewCellSection]>
    }
    
    func transform(input: Input) -> Output {
        // 셀 데이터 불러오기
        input.refreshOn
            .withUnretained(self)
            .flatMap {viewmodel, _ in
                viewmodel.editModel.fixDataToGroupData(FixInfo.saveStation)
            }
            .bind(to: self.nowData)
            .disposed(by: self.bag)
        
        // 셀 삭제
        input.deleteCell
            .withUnretained(self)
            .subscribe(onNext: { viewModel, id in
                for x in FixInfo.saveStation.enumerated() {
                    if x.element.id == id{
                        FixInfo.saveStation.remove(at: x.offset)
                        break
                    }
                }
                
                viewModel.deleteAlertID(id: id)
            })
            .disposed(by: self.bag)
        
        // 셀 move
        input.moveCell
            .withUnretained(self)
            .subscribe(onNext: {
                do {
                    let nowVaue = try $0.nowData.value()
                    
                    let old = $1.sourceIndex
                    let now = $1.destinationIndex
                    
                    let oldData = nowVaue[old[0]].items[old[1]]
                    var nowData = EditViewCellSection.Item(id: "", stationName: "", updnLine: "", line: "", useLine: "")
                    
                    // 가장 최상/하단으로 변경 시
                    if now[1] != nowVaue[now[0]].items.count {
                        nowData = nowVaue[now[0]].items[now[1]]
                    }
                    
                    var oldIndex = 0
                    var nowIndex = 0
                    
                    for x in FixInfo.saveStation.enumerated() {
                        if x.element.id == oldData.id {
                            oldIndex = x.offset
                        }
                        
                        if x.element.id == nowData.id {
                            nowIndex = x.offset
                        }
                    }
                    
                    // 세션 이동 감지
                    if old[0] != now[0] {
                        FixInfo.saveStation[oldIndex].group = FixInfo.saveStation[oldIndex].group == .one ? .two : .one
                        $0.deleteAlertID(id: FixInfo.saveStation[oldIndex].id)
                        
                    }
                    
                    if now[1] == nowVaue[now[0]].items.count {
                        let fixData = FixInfo.saveStation[oldIndex]
                        FixInfo.saveStation.remove(at: oldIndex)
                        FixInfo.saveStation.append(fixData)
                        
                    } else if now[1] == 0 {
                        let fixData = FixInfo.saveStation[oldIndex]
                        FixInfo.saveStation.remove(at: oldIndex)
                        FixInfo.saveStation.insert(fixData, at: 0)
                        
                    } else if old[0] == now[0] {
                        FixInfo.saveStation.swapAt(oldIndex, nowIndex)
                        
                    } else {
                        let fixData = FixInfo.saveStation[oldIndex]
                        FixInfo.saveStation.remove(at: oldIndex)
                        FixInfo.saveStation.insert(fixData, at: nowIndex)
                    }
                } catch {
                    print("ERROR")
                }
            })
            .disposed(by: self.bag)
        
        return Output(
            cellData: self.nowData
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
}
