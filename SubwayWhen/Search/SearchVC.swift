//
//  SearchVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import UIKit

import RxSwift
import RxCocoa

class SearchVC : UIViewController{
    let bag = DisposeBag()
    
    var searchBarVC : SearchBarVC?
    let resultVC = ResultVC()
    let defaultView = DefaultView()
    
    override func viewDidLoad() {
        self.attribute()
        self.layout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.searchBarVC?.isActive = false
    }
}

extension SearchVC{
    private func attribute(){
        self.view.backgroundColor = .systemBackground
        self.navigationItem.title = "검색"
        self.navigationItem.searchController = self.searchBarVC
    }
    
    private func layout(){
        self.view.addSubview(self.defaultView)
        self.defaultView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    func bind(_ viewModel : SearchViewModel){
        self.searchBarVC = SearchBarVC(searchResultsController: self.resultVC)
        
        self.resultVC.bind(viewModel.resultViewModel)
        self.searchBarVC!.bind(viewModel.serachBarViewModel)
        self.defaultView.bind(viewModel.defaultViewModel)
        
        viewModel.modalData
            .drive(self.rx.showModal)
            .disposed(by: self.bag)
        
    }
}

extension Reactive where Base : SearchVC {
    var showModal : Binder<ResultVCCellData>{
        return Binder(base){base, data in
            let modal = ModalVC()
            let modalViewModel = ModalViewModel()
            modalViewModel.clickCellData.accept(data)
            modal.bind(modalViewModel)
            modal.modalPresentationStyle = .overFullScreen
            base.present(modal, animated: false)
        }
    }
}
