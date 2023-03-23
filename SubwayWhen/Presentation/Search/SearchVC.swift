//
//  SearchVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import UIKit

import Toast_Swift

import RxSwift
import RxCocoa

class SearchVC : UIViewController{
    let bag = DisposeBag()
    let searchViewModel : SearchViewModel
    
    var searchBarVC : SearchBarVC?
    let resultVC = ResultVC()
    let defaultView = DefaultView()
    
    init(viewModel : SearchViewModel) {
        self.searchViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.bind(self.searchViewModel)
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
        self.navigationItem.searchController = self.searchBarVC
    }
    
    private func layout(){
        self.view.addSubview(self.defaultView)
        self.defaultView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    private func bind(_ viewModel : SearchViewModel){
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
            base.searchBarVC?.searchBar.resignFirstResponder()
            
            let modalViewModel = ModalViewModel()
            let modal = ModalVC(modalViewModel, modalHeight: 381)
            
            modal.delegate = base
            modalViewModel.clickCellData.accept(data)
            modal.modalPresentationStyle = .overFullScreen
            base.present(modal, animated: false)
        }
    }
}

extension SearchVC : ModalVCProtocol{
    func stationSave() {
        self.searchBarVC?.view.makeToast("지하철 역이 추가되었어요.", duration: 1.5, style: ViewStyle.toastStyle)
    }
}
