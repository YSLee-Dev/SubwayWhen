//
//  DetailTableArrivalLiveViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/04/17.
//

import Foundation

import RxSwift
import RxCocoa
import RxOptional

class DetailTableArrivalLiveViewModel : DetailTableArrivalLiveViewModelProtocol{
    // INPUT
    let superTimer = PublishSubject<Int>()
    let arrivalData = PublishSubject<[RealtimeStationArrival]>()
    
    let timer : Driver<Int>
    let viewData : Driver<RealtimeStationArrival>
    
    private let filterTimer = PublishSubject<Int>()
    
    let bag = DisposeBag()
    
    init(){
        self.timer = self.filterTimer
            .asDriver(onErrorDriveWith: .empty())
        
        self.viewData = self.arrivalData
            .map{
                $0.first
            }
            .filterNil()
            .asDriver(onErrorDriveWith: .empty())
        
        let filterCodeThree = self.arrivalData
            .map{
                $0.first?.code == "3"
            }
        
        self.superTimer
            .withLatestFrom(filterCodeThree){ timer, filter -> Int? in
                if filter{
                    return timer
                }else{
                    return nil
                }
            }
            .filterNil()
            .bind(to: self.filterTimer)
            .disposed(by: self.bag)
    }
}
