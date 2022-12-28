//
//  SearchBarVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import UIKit

import RxSwift
import RxCocoa

class SearchBarVC : UISearchController{
    let bag = DisposeBag()
    
    override init(searchResultsController: UIViewController?) {
        super.init(searchResultsController: searchResultsController)
        self.attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SearchBarVC{
    private func attribute(){
        self.searchBar.placeholder = "🔍 지하철역을 검색하세요"
        self.searchBar.setValue("취소", forKey: "cancelButtonText")
        self.searchBar.searchTextField.backgroundColor = UIColor(named: "MainColor")
        self.searchBar.setImage(UIImage(), for: UISearchBar.Icon.search, state: .normal)
    }
    
    func bind(_ viewModel: SearchBarViewModel){
        // VIEW -> VIEWMODEL
        self.searchBar.rx.text
            .bind(to: viewModel.searchText)
            .disposed(by: self.bag)
        
        // VIEWMODEL -> VIEW
        viewModel.searchStart
            .drive(self.searchBar.rx.text)
            .disposed(by: self.bag)
        
        viewModel.searchStart
            .map{ _ in
                Void()
            }
            .drive(self.rx.searchPresent)
            .disposed(by: self.bag)
        
        viewModel.searchEnd
            .drive(self.rx.searchDismiss)
            .disposed(by: self.bag)
        
        viewModel.searchEnd
            .map{ _ in
                ""
            }
            .drive(self.searchBar.rx.text)
            .disposed(by: self.bag)
    }
}

extension Reactive where Base : SearchBarVC{
    var searchPresent : Binder<Void>{
        return Binder(base){base, _ in
            base.isActive = true
        }
    }
    
    var searchDismiss : Binder<Void>{
        return Binder(base){base, _ in
            base.dismiss(animated: true)
        }
    }
}
