//
//  TutorialCollectionCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/09/24.
//

import UIKit

import SnapKit
import Then

import RxSwift
import RxCocoa

class TutorialCollectionCell: UICollectionViewCell {
    static let id = "TutorialCollectionCell"
    var bag = DisposeBag()
    
    override func prepareForReuse() {
        self.bag = DisposeBag()
        self.contentView.transform = CGAffineTransform(translationX: 0, y: 150)
    }
    
    lazy var subTitle = MainStyleLabelView()
    
    var mainBG = UIView().then{
        $0.backgroundColor = UIColor(named: "MainColor")
        $0.layer.cornerRadius = ViewStyle.Layer.radius
        $0.layer.masksToBounds = true
    }
    
    let imageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFit
    }
    
    lazy var okBtn = ModalCustomButton(
        bgColor: UIColor(named: "AppIconColor") ?? .systemBackground,
        customTappedBG: "AppIconColor"
    )
    
    var whiteBG = UIView().then {
        $0.backgroundColor = .white
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layout()
        self.attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TutorialCollectionCell {
    private func layout() {
        [self.subTitle, self.mainBG].forEach {
            self.contentView.addSubview($0)
        }
        
        self.subTitle.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
            $0.top.equalToSuperview()
        }
        
        self.mainBG.snp.makeConstraints{
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(self.subTitle.snp.bottom).offset(20)
        }
        
        [self.imageView, self.okBtn].forEach {
            self.mainBG.addSubview($0)
        }
        
        self.okBtn.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(50)
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
        }
        
        self.imageView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().inset(16)
            $0.bottom.equalTo(self.okBtn.snp.top).offset(-16)
        }
    }
    
    private func attribute() {
        self.okBtn.setTitleColor(.white, for: .normal)
    }
    
    func cellSet(_ data: TutorialCellData) {
        self.contentView.transform = CGAffineTransform(translationX: 0, y: 150)
        self.imageView.image = data.contents
        self.okBtn.setTitle(data.btnTitle, for: .normal)
        self.subTitle.titleLabel.text = data.title
        
        UIView.animate(withDuration: 0.25, animations: {
            self.contentView.transform = .identity
        })
    }
    
    func bind(_ viewModel: TutorialCollectionViewCellModelProtocol) {
        self.okBtn.rx.tap
            .bind(to: viewModel.nextBtnTap)
            .disposed(by: self.bag)
    }
}
