//
//  MainVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import UIKit

import RxSwift
import RxCocoa

class MainVC : UIViewController{
    let bag = DisposeBag()
    
    let mainTableView = MainTableView()
    let groupView = GroupView()
    
    override func viewDidLoad() {
        self.attibute()
        self.layout()
    }
}
 
extension MainVC{
    private func attibute(){
        self.view.backgroundColor = .systemBackground
        self.navigationItem.title = "홈"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func layout(){
        self.view.addSubview(self.groupView)
        self.groupView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(35)
        }
        
        self.view.addSubview(self.mainTableView)
        self.mainTableView.snp.makeConstraints{
            $0.top.equalTo(self.groupView.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    func bind(_ viewModel : MainViewModel){
        // Bind 함수가 메모리에 먼저 올라감
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "편집", style: .done, target: self, action: nil)
        
        self.mainTableView.bind(viewModel.mainTableViewModel)
        self.groupView.bind(viewModel.groupViewModel)
        
        self.navigationItem.rightBarButtonItem?.rx.tap
            .map{[weak self] _ in
                if self?.navigationItem.rightBarButtonItem!.title == "편집"{
                    self?.navigationItem.rightBarButtonItem!.title = "완료"
                    return true
                }else{
                    self?.navigationItem.rightBarButtonItem!.title = "편집"
                    return false
                }
            }
            .bind(to: viewModel.mainTableViewModel.editBtnClick)
            .disposed(by: self.bag)
    }
}
