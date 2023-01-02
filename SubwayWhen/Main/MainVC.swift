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

class MainVC : UIViewController{
    let bag = DisposeBag()
    
    let mainTableView = MainTableView()
    let groupView = GroupView()
    let mainViewModel = MainViewModel()
    
    override func viewDidLoad() {
        self.attibute()
        self.layout()
        self.bind(self.mainViewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // view 다시 들어올 때 리프레시
        self.mainViewModel.reloadData
            .accept(Void())
    }
}
 
extension MainVC{
    private func attibute(){
        self.view.backgroundColor = .systemBackground
        self.navigationItem.title = "홈"
    }
    
    private func layout(){
        self.view.addSubview(self.groupView)
        self.groupView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(40)
        }
        
        self.view.addSubview(self.mainTableView)
        self.mainTableView.snp.makeConstraints{
            $0.top.equalTo(self.groupView.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    private func bind(_ viewModel : MainViewModel){
        // Bind 함수가 메모리에 먼저 올라감
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "편집", style: .done, target: self, action: nil)
        
        self.mainTableView.bind(viewModel.mainTableViewModel)
        self.groupView.bind(viewModel.groupViewModel)
        
        // VIEW
        self.navigationItem.rightBarButtonItem?.rx.tap
            .bind(to: self.rx.editVCPresent)
            .disposed(by: self.bag)
        
        // VIEWMODEL -> VIEW
        viewModel.stationPlusBtnClick
            .drive(self.rx.tapChange)
            .disposed(by: self.bag)
        
        viewModel.clickCellData
            .drive(self.rx.detailVCPresent)
            .disposed(by: self.bag)
        
    }
}

extension Reactive where Base : MainVC {
    var tapChange : Binder<Void>{
        return Binder(base){base, _ in
            base.tabBarController?.selectedIndex = 1
        }
    }
    
    var editVCPresent : Binder<Void>{
        return Binder(base){base, _ in
            let editVC = EditVC()
            editVC.bind(EditViewModel())
            let navigation = UINavigationController(rootViewController: editVC)
            navigation.modalPresentationStyle = .fullScreen
            base.present(navigation, animated: true)
        }
    }
    
    var detailVCPresent : Binder<MainTableViewCellData>{
        return Binder(base){base, data in
            let detail = DetailVC(style: .plain)
            detail.hidesBottomBarWhenPushed = true
            let viewModel = DetailViewModel()
            detail.bind(viewModel)
            viewModel.detailViewData.accept(data)
            
            base.navigationController?.pushViewController(detail, animated: true)
        }
    }
}
