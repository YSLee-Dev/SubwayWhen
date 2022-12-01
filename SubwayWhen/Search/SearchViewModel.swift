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
    let modalViewModel : Driver<ModalViewModel>
    
    let bag = DisposeBag()
    
    init(){
        let modalViewModel = ModalViewModel()
        
        self.resultViewModel.cellClick
            .bind(to: modalViewModel.clickCellData)
            .disposed(by: self.bag)
        
        self.modalViewModel = self.resultViewModel.cellClick
            .map{ _ in
                modalViewModel
            }
            .asDriver(onErrorDriveWith: .empty())
        
        self.defaultViewModel.defaultListClick
            .bind(to: self.serachBarViewModel.defaultViewClick)
            .disposed(by: self.bag)
        
        let searchQuery = self.serachBarViewModel.searchText
            .filter{$0 != nil}
            .map{
                $0!
            }
        
        let saveStationInfo = Observable
            .combineLatest(self.resultViewModel.cellClick, modalViewModel.groupClick, modalViewModel.exceptionLastStationText){
                SaveStation(stationName: $0.stationName, updnLine: "", line: $0.lineNumber.rawValue, lineCode: $0.lineCode, group: $1, exceptionLastStation: $2 ?? "")
            }
        
        
        modalViewModel.upDownBtnClick
            .withLatestFrom(saveStationInfo){
                var updown = ""
                print($1.group)
                if $1.useLine ==  "2호선" {
                    updown = $0 ? "내선" : "외선"
                }else{
                    updown = $0 ? "상행" : "하행"
                }
            
                FixInfo.saveStation.append(SaveStation(stationName: $1.stationName, updnLine: updown, line: $1.line, lineCode: $1.lineCode, group: $1.group, exceptionLastStation: $1.exceptionLastStation))
                return Void()
            }
            .bind(to: self.serachBarViewModel.updnLineClick)
            .disposed(by: self.bag)
        
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
            .map{ stationModel -> [searchStationInfo] in
                let data = stationModel!.SearchInfoBySubwayNameService.row
                if data.count == 5 && data[0].stationName == "신답"{
                    return []
                }else{
                    return data
                }
            }
            .bind(to: self.resultViewModel.resultData)
            .disposed(by: self.bag)
    }
}
