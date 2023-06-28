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
    let searchViewModel : SearchViewModelProtocol
    
    var searchBarVC : SearchBarVC?
    let resultVC = ResultVC()
    let defaultView = DefaultView()
    
    init(viewModel : SearchViewModelProtocol) {
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
    
    private func bind(_ viewModel : SearchViewModelProtocol){
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
        // modal close까지 0.3초 대기
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){[weak self] in
            let popup = PopupModal(modalHeight: 400, popupTitle: "저장 완료", subTitle: "지하철 역이 저장되었어요.", iconName: "CheckMark", congratulations: true)
            popup.modalPresentationStyle = .overFullScreen
            self?.present(popup, animated: false)
        }
    }
    
    func disposableDetailPush(data: DetailLoadData) {
        let viewModel = DetailViewModel()
        let detailVC = DetailVC(title: "\(data.stationName)(저장안됨)", viewModel: viewModel)
        viewModel.detailViewData.accept(data)
        
        detailVC.modalPresentationStyle = .pageSheet
        
        if let sheet = detailVC.sheetPresentationController{
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 25
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){[weak self] in
            self?.present(detailVC, animated: true)
        }
    }
}
