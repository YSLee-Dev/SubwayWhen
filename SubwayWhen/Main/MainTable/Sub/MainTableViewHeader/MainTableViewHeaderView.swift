//
//  MainTableViewHeaderView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/13.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

class MainTableViewHeaderView : UITableViewHeaderFooterView{
    let bag = DisposeBag()
    
    var mainBG = UIView().then{
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        $0.backgroundColor =  UIColor(named: "MainColor")
        $0.layer.borderColor = UIColor.gray.cgColor
        $0.layer.borderWidth = 1.0
    }
    
    let mainTitle = UILabel().then{
        $0.text = "현재 지하철 예상 혼잡도"
        $0.font = .boldSystemFont(ofSize: 18)
        $0.textAlignment = .left
        $0.textColor = .label
    }
    
    let congestionLabel = UILabel().then{
        $0.font = .boldSystemFont(ofSize: 25)
        $0.textAlignment = .left
        $0.text = "😵😵😵😵😵😵😵😵🫥🫥"
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainTableViewHeaderView {
    private func attribute(){
        
    }
    
    private func layout(){
        self.contentView.addSubview(self.mainBG)
        self.mainBG.snp.makeConstraints{
            $0.top.bottom.equalToSuperview().inset(7.5)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        [self.mainTitle, self.congestionLabel]
            .forEach{
                self.mainBG.addSubview($0)
            }
        
        self.mainTitle.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.bottom.equalTo(self.snp.centerY).offset(-5)
        }
        self.congestionLabel.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.top.equalTo(self.snp.centerY)
        }
    }
    
    func bind(_ viewModel : MainTableViewHeaderViewModel){
        viewModel.peopleCount
            .map{ count -> String in
                var result = ""
                
                for _ in 1...count{
                    result.append("😵")
                }
                if count != 10{
                    for _ in result.count...9{
                        result.append("🫥")
                    }
                }
               
                return result
            }
            .drive(self.congestionLabel.rx.text)
            .disposed(by: self.bag)
    }
}
