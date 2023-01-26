//
//  TopView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/02.
//

import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa

class TopView : UIView{
    let bag = DisposeBag()
    
    let backBtn = UIButton().then{
        $0.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        $0.tintColor = .label
    }
    
    lazy var subTitleLabel = UILabel().then{
        $0.textColor = .label
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.largeSize)
        $0.textAlignment = .left
        $0.alpha = 0
        $0.transform = CGAffineTransform(translationX: 0, y: 10)
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

extension TopView{
    private func attribute(){
        self.backgroundColor = .systemBackground
    }
    
    private func layout(){
        [self.backBtn, self.subTitleLabel]
            .forEach{
                self.addSubview($0)
            }
        
        self.backBtn.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().inset(15)
        }

        self.subTitleLabel.snp.makeConstraints{
            $0.leading.equalTo(self.backBtn.snp.trailing).offset(10)
            $0.centerY.equalTo(self.backBtn)
        }
    }
    
    func isMainTitleHidden(_ hidden : Bool){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.75){
            self.subTitleLabel.alpha = hidden ? 1 : 0
            self.subTitleLabel.transform = hidden ? .identity : CGAffineTransform(translationX: 0, y: 10)
        }
    }
}
