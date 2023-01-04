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
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        self.mainTableView.delegate = self
    }
    
    private func layout(){
        self.view.addSubview(self.groupView)
        self.groupView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).inset(55)
            $0.height.equalTo(75)
        }
        
        self.view.addSubview(self.mainTableView)
        self.mainTableView.snp.makeConstraints{
            $0.top.equalTo(self.groupView.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    private func bind(_ viewModel : MainViewModel){
        self.mainTableView.bind(viewModel.mainTableViewModel)
        self.groupView.bind(viewModel.groupViewModel)
        
        // VIEWMODEL -> VIEW
        viewModel.stationPlusBtnClick
            .drive(self.rx.tapChange)
            .disposed(by: self.bag)
        
        viewModel.clickCellData
            .drive(self.rx.detailVCPresent)
            .disposed(by: self.bag)
        
        viewModel.editBtnClick
            .drive(self.rx.editVCPresent)
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
            let editVC = EditVC(title: "편집")
            editVC.modalPresentationStyle = .fullScreen
            base.present(editVC, animated: true)
        }
    }
    
    var detailVCPresent : Binder<MainTableViewCellData>{
        return Binder(base){base, data in
            let detail = DetailVC(title: "\(data.useLine) \(data.stationName)")
            detail.hidesBottomBarWhenPushed = true
            let viewModel = DetailViewModel()
            detail.bind(viewModel)
            viewModel.detailViewData.accept(data)
            
            base.navigationController?.pushViewController(detail, animated: true)
        }
    }
}

extension MainVC : UITableViewDelegate{
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y < 0{
            self.groupView.tableScrollBtnResizing(false)
            
            self.groupView.snp.updateConstraints{
                $0.height.equalTo(75)
            }
        }else{
            self.groupView.tableScrollBtnResizing(true)
            
            self.groupView.snp.updateConstraints{
                $0.height.equalTo(25)
            }
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.75, options: [.allowUserInteraction]){
            self.view.layoutIfNeeded()
        }
    }
}
