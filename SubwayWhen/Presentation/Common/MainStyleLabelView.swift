//
//  MainStyleLabelView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/09/24.
//

import UIKit

import Then
import SnapKit

class MainStyleLabelView: MainStyleUIView {
    let titleLabel = UILabel().then{
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.largeSize)
        $0.textAlignment = .left
        $0.adjustsFontSizeToFitWidth = true
        $0.numberOfLines = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MainStyleLabelView {
    func layout() {
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
    }
}
