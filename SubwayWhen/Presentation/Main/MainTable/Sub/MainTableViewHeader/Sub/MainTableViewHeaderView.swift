//
//  MainTableViewHeaderView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/09/18.
//

import UIKit

import SnapKit
import Then

class MainTableViewHeaderView: MainStyleUIView {
    let mainTitle = UILabel().then{
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mediumSize)
        $0.textAlignment = .left
        $0.textColor = .label
        $0.adjustsFontSizeToFitWidth = true
    }
    
    let subTitle = UILabel().then{
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mainTitleSize)
        $0.textAlignment = .left
        $0.adjustsFontSizeToFitWidth = true
    }
    
    init(title: String, subTitle: String){
        super.init(frame: .zero)
        self.layout()
        self.attribute(title: title, subTitle: subTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainTableViewHeaderView {
    private func layout() {
        [self.mainTitle, self.subTitle]
            .forEach{
                self.addSubview($0)
            }
        
        self.mainTitle.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.bottom.equalTo(self.snp.centerY).offset(-5)
        }
        self.subTitle.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.top.equalTo(self.snp.centerY)
        }
    }
    
    private func attribute(title: String, subTitle: String) {
        self.mainTitle.text = title
        self.subTitle.text = subTitle
    }
    
    func smallSizeTransform(title : String) {
        self.mainTitle.snp.remakeConstraints {
            $0.leading.equalToSuperview().inset(15)
            $0.width.equalTo(80)
            $0.centerY.equalToSuperview()
        }
        self.subTitle.snp.remakeConstraints {
            $0.leading.equalTo(self.mainTitle.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(15)
            $0.centerY.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.25) {
            self.mainTitle.font = .boldSystemFont(ofSize: ViewStyle.FontSize.largeSize)
            self.subTitle.font = .boldSystemFont(ofSize: ViewStyle.FontSize.largeSize)
            self.layoutIfNeeded()
            self.mainTitle.text = title
        }
        
    }
}
