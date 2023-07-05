//
//  LocationView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/03.
//

import UIKit

import Then
import SnapKit
import Lottie

class LocationView: CollectionViewCellCustom {
    let title = UILabel().then {
        $0.adjustsFontSizeToFitWidth = true
        $0.numberOfLines = 2
        $0.textColor = .label
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.mainTitleMediumSize, weight: .heavy)
        $0.text = "현재 위치와 가장 가까운 지하철역을\n검색할 수 있어요."
    }
    
    let animationView = LottieAnimationView(name: "Location")
    
    let okBtn = ModalCustomButton(bgColor: UIColor(named: "AppIconColor") ?? .gray, customTappedBG: "AppIconColor").then {
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("확인하기", for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LocationView {
    private func layout() {
        self.mainBG.snp.remakeConstraints {
            $0.top.bottom.equalToSuperview().inset(ViewStyle.padding.mainStyleViewTB)
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
        }
        
        [self.title, self.animationView, self.okBtn]
            .forEach {
                self.mainBG.addSubview($0)
            }
        
        self.title.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.top.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
        }
        
        self.animationView.snp.makeConstraints {
            $0.top.equalTo(self.title.snp.bottom)
            $0.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.size.equalTo(150)
        }
        
        self.okBtn.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.bottom.equalToSuperview().offset(-ViewStyle.padding.mainStyleViewLR)
            $0.height.equalTo(40)
        }
    }
    
    func animationPlay() {
        self.animationView.stop()
        self.animationView.play()
    }
}
