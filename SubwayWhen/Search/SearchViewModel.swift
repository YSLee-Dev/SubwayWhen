//
//  SearchViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import Foundation

import RxSwift
import RxCocoa

class SearchViewModel {
    // MODEL
    let serachBarViewModel = SearchBarViewModel()
    let resultViewModel = ResultViewModel()
    let defaultViewModel = DefaultViewModel()
    let model = SearchModel()
    
    // OUTPUT
    let modalData : Driver<ResultVCCellData>
    
    let nowData = BehaviorRelay<[ResultVCSection]>(value: [ResultVCSection(section: "", items: [])])
    
    let bag = DisposeBag()
    
    init(){
        self.nowData
            .bind(to: self.resultViewModel.resultData)
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
        
        let searchQuery = self.serachBarViewModel.searchText
            .filter{$0 != nil}
            .map{
                $0!
            }
        
        // 추천 역 가져오기 (API 통신)
        Observable.just(["강남", "광화문", "명동", "광화문", "판교", "수원"])
            .flatMap{_ in
                self.model.defaultViewListRequest()
            }
            .bind(to: self.defaultViewModel.defaultListData)
            .disposed(by: self.bag)
        
        // 역명 검색 (API 통신)
        Observable
            .merge(
                searchQuery,
                self.defaultViewModel.defaultListClick.asObservable()
            )
            .flatMap{
                self.model.stationSearch(station: $0)
            }
            .map{ data -> SearchStaion? in
                guard case .success(let value) = data else{
                    return nil
                }
                return value
            }
            .filter{$0 != nil}
            .map{ stationModel -> [ResultVCSection] in
                let data = stationModel!.SearchInfoBySubwayNameService.row
                if data.count == 5 && data[0].stationName == "신답"{
                    return []
                }else{
                    let section = data.map{
                        return ResultVCSection(section: "\($0.stationCode)\($0.lineCode)", items: [ResultVCCellData(stationName: $0.stationName, lineNumber: $0.lineNumber.rawValue, stationCode: $0.stationCode, useLine: $0.useLine, lineCode: $0.lineCode)])
                    }
                    return section
                }
            }
            .bind(to: self.nowData)
            .disposed(by: self.bag)
        
    }
}
