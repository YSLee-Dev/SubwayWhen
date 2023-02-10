//
//  TitleView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/03.
//

import UIKit

import SnapKit
import Then

class TitleView : UIView{
    lazy var mainTitleLabel = UILabel().then{
        $0.textColor = .label
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mainTitleSize)
        $0.textAlignment = .left
        $0.numberOfLines = 2
        $0.adjustsFontSizeToFitWidth = true
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

extension TitleView {
    private func attribute(){
        self.backgroundColor = .systemBackground
    }
    
    private func layout(){
        self.addSubview(self.mainTitleLabel)
        
        self.mainTitleLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
        }
    }
}
