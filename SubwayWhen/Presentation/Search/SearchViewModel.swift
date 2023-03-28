//
//  SearchViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import Foundation

import RxSwift
import RxCocoa
import RxOptional

class SearchViewModel {
    // MODEL
    let serachBarViewModel = SearchBarViewModel()
    let resultViewModel = ResultViewModel()
    let defaultViewModel = DefaultViewModel()
    let model : SearchModelProtocol
    
    // OUTPUT
    let modalData : Driver<ResultVCCellData>
    
    let defaultData = BehaviorSubject<[String]>(value: ["강남", "광화문", "명동", "광화문", "판교", "수원"])
    let nowData = BehaviorRelay<[ResultVCSection]>(value: [ResultVCSection(section: "", items: [])])
    
    let bag = DisposeBag()
    
    init(
        model : SearchModel = .init()
    ){
        self.model = model
        
        self.nowData
            .bind(to: self.resultViewModel.resultData)
            .disposed(by: self.bag)
        
        self.defaultData
            .bind(to: self.defaultViewModel.defaultListData)
            .disposed(by: self.bag)
    
        let cellClickData = self.resultViewModel.cellClick
            .withLatestFrom(nowData){
                $1[$0.section].items[$0.row]
        }
        
        self.modalData = cellClickData
            .asDriver(onErrorDriveWith: .empty())
        
        self.defaultViewModel.defaultListClick
            .bind(to: self.serachBarViewModel.defaultViewClick)
            .disposed(by: self.bag)
        
        // 추천 역 가져오기 (파이어베이스)
        self.model.fireBaseDefaultViewListLoad()
            .bind(to: self.defaultData)
            .disposed(by: self.bag)
        
        // 역명 검색 (API 통신)
        let searchQuery = self.serachBarViewModel.searchText
            .filterNil()
            .filter{$0 != ""}
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
        
        let search = Observable
            .merge(
                searchQuery,
                self.defaultViewModel.defaultListClick.asObservable()
            )
        
        search
            .withUnretained(self)
            .flatMap{ viewModel, data in
                viewModel.model.stationNameSearchRequest(data)
            }
            .withUnretained(self)
            .map{ viewModel, data in
                viewModel.model.stationNameMatching(data)
            }
            .bind(to: self.nowData)
            .disposed(by: self.bag)
        
    }
}
