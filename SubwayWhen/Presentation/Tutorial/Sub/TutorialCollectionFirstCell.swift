//
//  TutorialCollectionFirstCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/09/25.
//

import UIKit

import SnapKit
import Then
import Lottie

import RxSwift
import RxCocoa

class TutorialCollectionFirstCell: UICollectionViewCell {
    static let id = "TutorialCollectionFirstCell"
    var bag = DisposeBag()
    
    override func prepareForReuse() {
        self.bag = DisposeBag()
        self.animationIcon.play()
    }
    
    var title = UILabel().then {
        $0.alpha = 0
        $0.textColor = .label
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mainTitleSize)
        $0.text = "환영합니다 👏"
    }
    
    var mainBG = UIView().then{
        $0.backgroundColor = UIColor(named: "MainColor")
        $0.layer.cornerRadius = ViewStyle.Layer.radius
        $0.layer.masksToBounds = true
    }
    
    lazy var okBtn = ModalCustomButton(
        bgColor: UIColor(named: "AppIconColor") ?? .systemBackground,
        customTappedBG: "AppIconColor"
    ).then {
        $0.alpha = 0
    }
    
    lazy var animationIcon = LottieAnimationView(name: "Congratulations")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layout()
        self.animationStart()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TutorialCollectionFirstCell {
    func layout() {
        self.contentView.addSubview(self.mainBG)
        self.mainBG.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
        
        self.mainBG.addSubview(self.animationIcon)
        self.animationIcon.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.animationIcon.addSubview(self.title)
        self.title.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-16)
            $0.centerX.equalToSuperview()
        }
        
        self.animationIcon.addSubview(self.okBtn)
        self.okBtn.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(50)
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
        }
    }
    
    func animationStart() {
        UIView.animate(withDuration: 0.25, delay: 0.25, animations: {
            self.animationIcon.play()
            self.title.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.25, delay: 0.25, animations: {
                self.okBtn.alpha = 1
            })
        })
       
    }
    
    func bind(_ viewModel: TutorialCollectionViewCellModelProtocol) {
        self.okBtn.rx.tap
            .bind(to: viewModel.nextBtnTap)
            .disposed(by: self.bag)
    }
}
