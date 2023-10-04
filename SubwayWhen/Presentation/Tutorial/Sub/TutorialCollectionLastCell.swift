//
//  TutorialCollectionLastCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/10/04.
//

import UIKit

import SnapKit
import Then
import Lottie

import RxSwift
import RxCocoa

class TutorialCollectionLastCell: UICollectionViewCell {
    static let id = "TutorialCollectionLastCell"
    var bag = DisposeBag()
    
    lazy var animationIcon = LottieAnimationView(name: "TutorialSuccess")
    lazy var okBtn = ModalCustomButton(
        bgColor: UIColor(named: "MainColor") ?? .gray, 
        customTappedBG: nil
    ).then {
        $0.alpha = 0
    }
    
    override func prepareForReuse() {
        self.bag = DisposeBag()
        self.animationIcon.transform = CGAffineTransform(translationX: 0, y: -110)
        self.okBtn.alpha = 0
        self.animationStart()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layout()
        self.attribute()
        self.animationStart()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension TutorialCollectionLastCell {
    func layout() {
        self.contentView.addSubview(self.animationIcon)
        self.animationIcon.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(110)
        }
        
        self.animationIcon.addSubview(self.okBtn)
        self.okBtn.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(50)
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
        }
        
        self.animationIcon.transform = CGAffineTransform(translationX: 0, y: -110)
    }
    
    func attribute() {
        self.okBtn.setTitleColor(.label, for: .normal)
    }
    
    func animationStart() {
        self.animationIcon.play(completion: {  [weak self] _ in
            UIView.animate(withDuration: 0.25, delay: 0, animations: {
                self?.animationIcon.transform = .identity
            }) { _ in
                UIView.animate(withDuration: 0.25, delay: 0.1, animations: {
                    self?.okBtn.alpha = 1
                })
            }
        })
    }
}
