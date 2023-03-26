//
//  DetailTableScheduleCellModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/17.
//

import Foundation

import RxSwift
import RxCocoa

class DetailTableScheduleCellModel : DetailTableScheduleCellModelProtocol{
    // INPUT
    let scheduleData = BehaviorRelay<[ResultSchdule]>(value: [])
    let moreBtnClick = PublishRelay<Void>()
    
    // OUTPUT
    let cellData : Driver<[ResultSchdule]>
    
    // NOW
    private let nowData = BehaviorRelay<[ResultSchdule]>(value: [])
    
    let bag = DisposeBag()
    
    init(){
        self.cellData = self.nowData
            .asDriver(onErrorDriveWith: .empty())
        
        self.scheduleData
            .map{ data -> [ResultSchdule] in
                if FixInfo.saveSetting.detailScheduleAutoTime{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HHmmss"
                    
                    guard let now = Int(formatter.string(from: Date())) else {return data}
                    let schedule = data.filter{
                        guard let scheduleTime = Int($0.startTime.components(separatedBy: ":").joined()) else {return false}
                        if scheduleTime >= now{
                            return true
                        }else{
                            return false
                        }
                    }
                    
                    if schedule.isEmpty{
                        return data
                    }else if schedule.count == 1{
                        guard let first = schedule.first else {return []}
                        return [first]
                    }else {
                        return schedule
                    }
                }else{
                    return data
                }
               
            }
            .bind(to: self.nowData)
            .disposed(by: self.bag)
    }
}
