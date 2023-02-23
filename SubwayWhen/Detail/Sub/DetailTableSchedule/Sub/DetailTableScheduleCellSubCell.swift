//
//  DetailTableScheduleCellSubCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/19.
//

import UIKit

import SnapKit
import Then

class DetailTableScheduleCellSubCell : UICollectionViewCell{
    let scheduleTitle = UILabelCustom(padding: .init(top: 0, left: 5, bottom: 0, right: 5)).then{
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.smallSize, weight: .medium)
        $0.textColor = .white
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DetailTableScheduleCellSubCell{
    func cellSet(_ data : ResultSchdule, color : UIColor){
        if data.startTime == "정보없음"{
            scheduleTitle.text = "⚠️ 정보없음"
            scheduleTitle.backgroundColor = color
        }else{
            scheduleTitle.text = "⏱️ \(data.lastStation)행 \(data.useArrTime)"
            scheduleTitle.backgroundColor = color
        }
       
    }
    
    private func layout(){
        self.contentView.addSubview(self.scheduleTitle)
        self.scheduleTitle.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
    }
}
