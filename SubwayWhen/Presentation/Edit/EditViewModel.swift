//
//  EditViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/19.
//

import Foundation

import RxSwift
import RxCocoa

class EditViewModel : EditViewModelProtocol{
    // MODEL
    private let editModel : EditModelProtocol
    
    // INPUT
    let deleteCell = PublishRelay<String>()
    let refreshOn = PublishRelay<Void>()
    let moveCell = PublishRelay<ItemMovedEvent>()
    
    // OUTPUT
    let cellData : Driver<[EditViewCellSection]>
    
    // VALUE
    private let nowData = BehaviorSubject<[EditViewCellSection]>(value: [])
    
    let bag = DisposeBag()
    
    init(
        model : EditModel = .init()
    ){
        self.editModel = model
        
        self.cellData = self.nowData
            .asDriver(onErrorDriveWith: .empty())
        
        // 셀 삭제
        self.deleteCell
            .map{
                for x in FixInfo.saveStation.enumerated(){
                    if x.element.id == $0{
                        FixInfo.saveStation.remove(at: x.offset)
                        break
                    }
                }
                return Void()
            }
            .bind(to: self.refreshOn)
            .disposed(by: self.bag)
        
        // 셀 move
        self.moveCell
            .withUnretained(self)
            .map{
                do {
                    let nowVaue = try $0.nowData.value()
                    
                    let old = $1.sourceIndex
                    let now = $1.destinationIndex
                    
                    let oldData = nowVaue[old[0]].items[old[1]]
                    var nowData = EditViewCellSection.Item(id: "", stationName: "", updnLine: "", line: "", useLine: "")
                    
                    // 가장 최상/하단으로 변경 시
                    if now[1] != nowVaue[now[0]].items.count{
                        nowData = nowVaue[now[0]].items[now[1]]
                    }
                    
                    var oldIndex = 0
                    var nowIndex = 0
                    
                    for x in FixInfo.saveStation.enumerated(){
                        if x.element.id == oldData.id{
                            oldIndex = x.offset
                        }
                        
                        if x.element.id == nowData.id{
                            nowIndex = x.offset
                        }
                    }
                    
                    // 세션 이동 감지
                    if old[0] != now[0]{
                        FixInfo.saveStation[oldIndex].group = FixInfo.saveStation[oldIndex].group == .one ? .two : .one
                    }
                    
                    if now[1] == nowVaue[now[0]].items.count{
                        let fixData = FixInfo.saveStation[oldIndex]
                        FixInfo.saveStation.remove(at: oldIndex)
                        FixInfo.saveStation.append(fixData)
                    }else if now[1] == 0{
                        let fixData = FixInfo.saveStation[oldIndex]
                        FixInfo.saveStation.remove(at: oldIndex)
                        FixInfo.saveStation.insert(fixData, at: 0)
                    }else if old[0] == now[0]{
                        FixInfo.saveStation.swapAt(oldIndex, nowIndex)
                    }else{
                        let fixData = FixInfo.saveStation[oldIndex]
                        FixInfo.saveStation.remove(at: oldIndex)
                        FixInfo.saveStation.insert(fixData, at: nowIndex)
                    }
                    
                    return Void()
                }catch{
                    return Void()
                }
            }
            .bind(to: self.refreshOn)
            .disposed(by: self.bag)
        
        
        
        // 셀 데이터 불러오기
        self.refreshOn
            .withUnretained(self)
            .flatMap{viewmodel, _ in
                viewmodel.editModel.fixDataToGroupData(FixInfo.saveStation)
            }
            .bind(to: self.nowData)
            .disposed(by: self.bag)
        
    }
}
