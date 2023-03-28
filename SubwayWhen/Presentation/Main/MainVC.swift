//
//  MainVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa

class MainVC : TableVCCustom{
    let bag = DisposeBag()
    
    let mainTableView = MainTableView()
    let mainViewModel : MainViewModelProtocol
    
    var delegate : MainDelegate?
    
    init(viewModel : MainViewModelProtocol){
        self.mainViewModel = viewModel
        super.init(title: "홈", titleViewHeight: 62)
        self.tableView = self.mainTableView
        self.tableView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bind(self.mainViewModel)
        self.attibute()
        self.layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // view 다시 들어올 때 리프레시
        self.mainViewModel.reloadData
            .accept(Void())
    }
}
 
extension MainVC{
    private func attibute(){
        self.topView.backBtn.isHidden = true
        self.topView.subTitleLabel.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mainTitleMediumSize)
    }
    
    private func layout(){
        self.topView.subTitleLabel.snp.remakeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
        }
        
        self.titleView.mainTitleLabel.snp.updateConstraints{
            $0.centerY.equalToSuperview().offset(-5)
        }
    }
    
    private func bind(_ viewModel : MainViewModelProtocol){
        self.mainTableView.bind(viewModel.mainTableViewModel)
        
        // VIEWMODEL -> VIEW
        viewModel.stationPlusBtnClick
            .drive(self.rx.tapChange)
            .disposed(by: self.bag)
        
        viewModel.clickCellData
            .drive(self.rx.detailVCPush)
            .disposed(by: self.bag)
        
        viewModel.editBtnClick
            .drive(self.rx.editVCPresent)
            .disposed(by: self.bag)
        
        viewModel.mainTitle
            .drive(self.rx.mainTitleSet)
            .disposed(by: self.bag)
        
        viewModel.mainTitleHidden
            .drive(self.rx.mainTitleHidden)
            .disposed(by: self.bag)
        
        viewModel.reportBtnClick
            .drive(self.rx.reportVCPush)
            .disposed(by: self.bag)
    }
}

extension Reactive where Base : MainVC {
    var mainTitleHidden : Binder<Void>{
        return Binder(base){base, _ in
            base.topView.isMainTitleHidden(true)
        }
    }
    
    var mainTitleSet : Binder<String>{
        return Binder(base){base, data in
            base.titleView.mainTitleLabel.text = data
        }
    }
    
    var tapChange : Binder<Void>{
        return Binder(base){base, _ in
            base.tabBarController?.selectedIndex = 1
        }
    }
    
    var editVCPresent : Binder<Void>{
        return Binder(base){base, _ in
            base.delegate?.pushTap(action: .Edit)
        }
    }
    
    var detailVCPush : Binder<MainTableViewCellData>{
        return Binder(base){base, data in
            base.delegate?.pushDetailTap(data: data)
        }
    }
    
    var reportVCPush : Binder<Void>{
        return Binder(base){base, _ in
            base.delegate?.pushTap(action: .Report)
        }
    }
}
