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

class MainVC: TableVCCustom {
    private let bag = DisposeBag()
    
    private let mainTableView = MainTableView()
    private let mainViewModel : MainViewModel
    private let mainAction = PublishRelay<MainViewAction>()
    
    init(viewModel: MainViewModel){
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
        self.bind()
        self.attibute()
        self.layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // view 다시 들어올 때 리프레시
        self.mainAction.accept(.refreshEvent)
    }
}
 
extension MainVC{
    private func attibute(){
        self.topView.backBtn.isHidden = true
        self.topView.subTitleLabel.font = .boldSystemFont(ofSize: ViewStyle.FontSize.largeSize)
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
    
    private func bind(){
        let input = MainViewModel.Input(
            actionList: self.mainAction
                .asObservable()
        )
        
        let output = self.mainViewModel.trasnform(input: input)
        self.mainTableView.setDI(action: self.mainAction)
            .setDI(importantData: output.importantData)
            .setTableView(
                tableViewData: output.tableViewData,
                peopleData: output.peopleData,
                groupData: output.groupData)
        
        output.tableViewData
            .map { _ in Void()}
            .drive(self.rx.mainTitleHidden)
            .disposed(by: self.bag)
        
        output.mainTitle
            .drive(self.rx.mainTitleSet)
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
}
