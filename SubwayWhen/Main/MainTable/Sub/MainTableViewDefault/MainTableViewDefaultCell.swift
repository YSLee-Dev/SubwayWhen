//
//  MainTableViewDefaultCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/27.
//

import UIKit

import Then
import SnapKit
import Lottie

class MainTableViewDefaultCell : TableViewCellCustom{
    var plusIcon = LottieAnimationView(name: "Plus")
    
    var titleLabel = UILabel().then{
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mediumSize)
        $0.textAlignment = .left
        $0.textColor = .label
        $0.text = "버튼을 눌러서 지하철 역을 추가할 수 있어요!"
        $0.adjustsFontSizeToFitWidth = true
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainTableViewDefaultCell{
    func animationPlay(){
        self.plusIcon.alpha = 0
        self.titleLabel.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.25, animations: {
            self.plusIcon.alpha = 1
            self.titleLabel.alpha = 1
        }){[weak self] _ in
            self?.plusIcon.play()
        }
    }
    
    private func layout(){
        [self.plusIcon, self.titleLabel].forEach{
            self.mainBG.addSubview($0)
        }
        
        self.plusIcon.snp.makeConstraints{
            $0.top.bottom.equalToSuperview().inset(7.5)
            $0.leading.equalToSuperview().inset(5)
            $0.size.equalTo(85)
        }
        
        self.titleLabel.snp.makeConstraints{
            $0.leading.equalTo(self.plusIcon.snp.trailing)
            $0.centerY.equalTo(self.plusIcon.snp.centerY)
            $0.trailing.equalTo(self.mainBG.snp.trailing).inset(15)
        }
    }
}
