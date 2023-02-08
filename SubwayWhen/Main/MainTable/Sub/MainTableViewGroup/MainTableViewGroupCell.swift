//
//  MainTableViewGroupCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/01.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

class MainTableViewGroupCell : UITableViewCell{
    let bag = DisposeBag()
    
    var status = true
    var nowClick = "출근"
    
    let groupOne = GroupCustomButton().then{
        $0.setTitle("출근", for: .normal)
        $0.seleted()
    }
    
    let groupTwo = GroupCustomButton().then{
        $0.setTitle("퇴근", for: .normal)
        $0.unSeleted()
    }
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layout()
        self.attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainTableViewGroupCell{
    private func layout(){
        [self.groupOne, self.groupTwo]
            .forEach{self.contentView.addSubview($0)}
        
        self.groupOne.snp.makeConstraints{
            $0.leading.equalToSuperview().inset(20)
            $0.top.bottom.equalToSuperview()
            $0.height.equalTo(40)
            $0.trailing.equalTo(self.snp.trailing).inset(100)
        }
        self.groupTwo.snp.makeConstraints{
            $0.trailing.equalToSuperview().inset(20)
            $0.top.bottom.equalToSuperview()
            $0.height.equalTo(40)
            $0.leading.equalTo(self.groupOne.snp.trailing)
        }
    }
    
    private func attribute(){
        self.selectionStyle = .none
    }
    
    func bind(_ viewModel : MainTableViewGroupCellModel){
        // VIEW -> VIEWMODEL
        let oneClick = self.groupOne.rx.tap
            .map{[weak self] _ -> SaveStationGroup in
                self?.groupOne.seleted()
                self?.groupTwo.unSeleted()
                self?.btnClickSizeChange(group: false)
                self?.nowClick = "출근"
                return .one
            }
        
       let twoClick = self.groupTwo.rx.tap
            .map{[weak self] _ -> SaveStationGroup in
                self?.groupOne.unSeleted()
                self?.groupTwo.seleted()
                self?.btnClickSizeChange(group: true)
                self?.nowClick = "퇴근"
                return .two
            }
        
        Observable
            .merge(
                oneClick, twoClick
            )
            .bind(to: viewModel.groupSeleted)
            .disposed(by: self.bag)
    }
    
    private func btnClickSizeChange(group : Bool){
            if group{
                self.groupOne.snp.remakeConstraints{
                    $0.leading.equalToSuperview().inset(20)
                    $0.top.bottom.equalToSuperview()
                    $0.height.equalTo(40)
                    $0.trailing.equalTo(self.snp.leading).inset(100)
                }
            }else{
                self.groupOne.snp.remakeConstraints{
                    $0.leading.equalToSuperview().inset(20)
                    $0.top.bottom.equalToSuperview()
                    $0.height.equalTo(40)
                    $0.trailing.equalTo(self.snp.trailing).inset(100)
                }
            }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.75){
            self.layoutIfNeeded()
        }
    }
    
    func tableScrollBtnResizing(_ scroll : Bool){
        if scroll{
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.75){
                [self.groupOne, self.groupTwo]
                    .forEach{
                        $0.transform = CGAffineTransform(translationX: 0, y: -30)
                        $0.alpha = 0
                    }
            }
        }else{
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.75){
                [self.groupOne, self.groupTwo]
                    .forEach{
                        $0.transform = .identity
                        $0.alpha = 1
                    }
            }
        }
        
    }
}
