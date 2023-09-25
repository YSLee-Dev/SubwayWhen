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
        self.contentView.transform = CGAffineTransform(translationX: 0, y: 200)
    }
    
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
        self.contentView.addSubview(self.mainBG)
        self.mainBG.snp.makeConstraints{
            $0.edges.equalToSuperview()
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
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.top.equalToSuperview().inset(ViewStyle.padding.mainStyleViewTB)
            $0.bottom.equalTo(self.okBtn.snp.top).inset(ViewStyle.padding.mainStyleViewTB)
        }
    }
    
    private func attribute() {
        self.okBtn.setTitleColor(.white, for: .normal)
        self.contentView.transform = CGAffineTransform(translationX: 0, y: 200)
    }
    
    func cellSet(_ data: TutorialCellData) {
        self.imageView.image = data.contents
        self.okBtn.setTitle(data.btnTitle, for: .normal)
        
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