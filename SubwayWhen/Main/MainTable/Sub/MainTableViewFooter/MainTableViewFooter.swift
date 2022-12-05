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
        $0.backgroundColor = .secondarySystemBackground
    }
    
    var plusBtn = UIButton(type: .custom).then{
        $0.setBackgroundImage(UIImage(systemName: "plus.app"), for: .normal)
        $0.tintColor = .label
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
            $0.top.bottom.equalToSuperview().inset(7.5)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        self.mainBG.addSubview(self.plusBtn)
        self.plusBtn.snp.makeConstraints{
            $0.center.equalToSuperview()
            $0.size.equalTo(30)
        }
    }
    
    func bind(_ viewModel : MainTableViewFooterViewModel){
        self.plusBtn.rx.tap
            .bind(to: viewModel.plusBtnClick)
            .disposed(by: self.bag)
    }
}
