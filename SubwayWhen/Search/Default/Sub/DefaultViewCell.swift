//
//  DefaultViewCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/29.
//

import UIKit

import SnapKit
import Then

class DefaultViewCell : UICollectionViewCell{
    var stationName = UILabel().then{
        $0.font = .systemFont(ofSize: 14)
        $0.backgroundColor = UIColor(named: "MainColor")
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        $0.textAlignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DefaultViewCell{
    private func layout(){
        self.contentView.addSubview(self.stationName)
        self.stationName.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
    }
}
