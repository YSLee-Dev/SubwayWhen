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
    private let totalData = PublishRelay<[RealtimeStationArrival]>()
    
    init(){
        self.mainTableViewModel.refreshOn
            .flatMap{
                self.model.totalLiveDataLoad()
            }
            .bind(to: self.totalData)
            .disposed(by: self.bag)
        
        // 모든 데이터를 받은 후 그룹에 맞춰서 return
        Observable.combineLatest(self.totalData, self.groupViewModel.groupSeleted){ data, group in
            return data.filter{
                $0.group ?? "" == group.rawValue
            }
        }
        .bind(to: self.mainTableViewModel.resultData)
        .disposed(by: self.bag)
        
        // 데이터 삭제
        self.mainTableViewModel.cellDelete
            .map{ data in
                for x in FixInfo.saveStation.enumerated(){
                    if x.element.id == data.id ?? "" {
                        FixInfo.saveStation.remove(at: x.offset)
                    }
                }
                
                return Void()
            }
            .bind(to: self.mainTableViewModel.refreshOn)
            .disposed(by: self.bag)
    }
}
