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

import FirebaseAnalytics

class SearchViewModel : SearchViewModelProtocol{
    // MODEL
    let serachBarViewModel : SearchBarViewModelProtocol
    let resultViewModel : ResultViewModelProtocol
    let defaultViewModel : DefaultViewModelProtocol
    private let model : SearchModelProtocol
   
    private let defaultData = BehaviorSubject<[DefaultSectionData]>(
        value: [.init(id: "Default", items: [.init(title: "강남"), .init(title: "광화문"), .init(title: "명동"), .init(title: "판교")])]
    )
    private let nowData = BehaviorRelay<[ResultVCSection]>(value: [ResultVCSection(section: "", items: [])])
    
    weak var delegate: SearchVCActionProtocol?
    
    let bag = DisposeBag()
    
    init(
        model : SearchModel = .init(),
        searchBarViewModel : SearchBarViewModel = .init(),
        resultViewModel : ResultViewModel = .init(),
        defaultViewModel : DefaultViewModel = .init()
    ){
        self.model = model
        self.serachBarViewModel = searchBarViewModel
        self.resultViewModel = resultViewModel
        self.defaultViewModel = defaultViewModel
        
        self.nowData
            .bind(to: self.resultViewModel.resultData)
            .disposed(by: self.bag)
        
        self.defaultData
            .bind(to: self.defaultViewModel.defaultListData)
            .disposed(by: self.bag)
    
        self.resultViewModel.cellClick
            .withLatestFrom(nowData){
                $1[$0.section].items[$0.row]
        }
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                viewModel.delegate?.modalPresent(data: data)
            })
            .disposed(by: self.bag)
        
        self.defaultViewModel.defaultListClick
            .delay(.microseconds(300), scheduler: MainScheduler.asyncInstance)
            .bind(to: self.serachBarViewModel.defaultViewClick)
            .disposed(by: self.bag)
        
        // 추천 역 가져오기 (파이어베이스)
        self.model.fireBaseDefaultViewListLoad()
            .bind(to: self.defaultData)
            .disposed(by: self.bag)
        
        // 역명 검색 (API 통신)
        let searchQuery = self.serachBarViewModel.searchText
            .filterNil()
            .filterEmpty()
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
        
        let search = Observable
            .merge(
                searchQuery,
                self.defaultViewModel.defaultListClick.asObservable()
            )
            .share()
        
        // 구글 애널리틱스
        search
            .subscribe(onNext: {
                Analytics.logEvent("SerachVC_Search", parameters: [
                    "Search_Station" : $0
                ])
            })
            .disposed(by: self.bag)
        
        search
            .withUnretained(self)
            .flatMap{ viewModel, data in
                viewModel.model.stationNameSearchRequest(data)
            }
            .withUnretained(self)
            .map{ viewModel, data in
                viewModel.model.searchStationToResultVCSection(data)
            }
            .bind(to: self.nowData)
            .disposed(by: self.bag)
        
        self.defaultViewModel.locationBtnTap
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                viewModel.delegate?.locationPresent()
            })
            .disposed(by: self.bag)
    }
}
