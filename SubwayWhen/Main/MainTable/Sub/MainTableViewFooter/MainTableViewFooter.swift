//
//  MainTableViewFooterView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/05.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

class MainTableViewFooterView : UITableViewHeaderFooterView {
    let bag = DisposeBag()
    
    var mainBG = UIView().then{
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        $0.backgroundColor =  UIColor(named: "MainColor")
        $0.layer.borderColor = UIColor.gray.cgColor
        $0.layer.borderWidth = 1.0
    }
    
    var plusBtn = UIButton(type: .custom).then{
        $0.setBackgroundImage(UIImage(systemName: "plus"), for: .normal)
        $0.tintColor = .gray
    }
    
    var editBtn = UIButton(type: .system).then{
        $0.setTitle("편집", for: .normal)
        $0.tintColor = .gray
        $0.titleLabel?.font = .boldSystemFont(ofSize: 16)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainTableViewFooterView{
    private func layout(){
        self.contentView.addSubview(self.mainBG)
        self.mainBG.snp.makeConstraints{
            $0.top.equalToSuperview().inset(7.5)
            $0.height.equalTo(60)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        self.mainBG.addSubview(self.plusBtn)
        self.plusBtn.snp.makeConstraints{
            $0.center.equalToSuperview()
            $0.size.equalTo(30)
        }
        
        self.contentView.addSubview(self.editBtn)
        self.editBtn.snp.makeConstraints{
            $0.top.equalTo(self.mainBG.snp.bottom).offset(10)
            $0.centerX.equalTo(self.mainBG)
            $0.height.equalTo(30)
            $0.width.equalTo(self.mainBG)
        }
    }
    
    func bind(_ viewModel : MainTableViewFooterViewModel){
        self.plusBtn.rx.tap
            .bind(to: viewModel.plusBtnClick)
            .disposed(by: self.bag)
        
        self.editBtn.rx.tap
            .bind(to: viewModel.editBtnClick)
            .disposed(by: self.bag)
    }
}
