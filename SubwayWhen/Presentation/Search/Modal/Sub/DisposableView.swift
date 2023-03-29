//
//  DisposableView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/26.
//

import UIKit

import SnapKit
import Then

import RxSwift
import RxCocoa

class DisposableView : UIView{
    let bag = DisposeBag()
    
    let titleLabel = UILabel().then{
        $0.text = "저장하지 않고 일회성으로 볼 수 있어요."
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.smallSize)
        $0.textColor = .white
        $0.adjustsFontSizeToFitWidth = true
    }
    
    let upBtn = ModalCustomButton().then{
        $0.setTitle("상행", for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: ViewStyle.FontSize.superSmallSize)
        $0.backgroundColor = .black.withAlphaComponent(0.3)
    }
    
    let downBtn = ModalCustomButton().then{
        $0.setTitle("하행", for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: ViewStyle.FontSize.superSmallSize)
        $0.backgroundColor = .black.withAlphaComponent(0.3)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layout()
        self.attribute()
        self.hiddenAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DisposableView{
    private func layout(){
        [self.titleLabel, self.upBtn, self.downBtn]
            .forEach{
                self.addSubview($0)
            }
        
        self.downBtn.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12.5)
            $0.width.equalTo(60)
            $0.height.equalTo(30)
        }
        
        self.upBtn.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(self.downBtn.snp.leading).offset(-7.5)
            $0.width.equalTo(60)
            $0.height.equalTo(30)
        }
        
        self.titleLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12.5)
            $0.trailing.equalTo(self.upBtn.snp.leading).inset(-12.5)
        }
    }
    
    private func attribute(){
        self.layer.cornerRadius = ViewStyle.Layer.radius
        self.backgroundColor = UIColor(named: "AppIconColor")?.withAlphaComponent(0.7)
    }
    
    func upDownLabelSet(up: String, down: String){
        self.upBtn.setTitle(up, for: .normal)
        self.downBtn.setTitle(down, for: .normal)
    }
    
    func showAnimation(){
        UIView.animate(withDuration: 0.25, delay: 0.5){[weak self] in
            self?.transform = .identity
            self?.alpha = 1
        }
    }
    
    func hiddenAnimation(){
        UIView.animate(withDuration: 0.25, delay: 0){[weak self] in
            self?.transform = CGAffineTransform(translationX: 0, y: 50)
            self?.alpha = 0
        }
    }
}
