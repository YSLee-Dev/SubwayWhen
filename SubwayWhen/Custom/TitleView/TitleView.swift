//
//  TitleView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/02.
//

import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa

class TitleView : UIView{
    let bag = DisposeBag()
    
    let backBtn = UIButton().then{
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.tintColor = .label
    }
    
    let titleLabel = UILabel().then{
        $0.textColor = .label
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textAlignment = .left
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.attribute()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TitleView{
    private func attribute(){
        self.backgroundColor = .systemBackground
    }
    
    private func layout(){
        [self.backBtn, self.titleLabel]
            .forEach{
                self.addSubview($0)
            }
        
        self.backBtn.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().inset(15)
        }
        
        self.titleLabel.snp.makeConstraints{
            $0.leading.equalTo(self.backBtn.snp.trailing).inset(-20)
            $0.centerY.equalToSuperview()
        }
    }
}
