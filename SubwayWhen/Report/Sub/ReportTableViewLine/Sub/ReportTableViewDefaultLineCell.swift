//
//  ReportTableViewDefaultLineCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/06.
//

import UIKit

import SnapKit
import Then

class ReportTableViewDefaultLineCell : UICollectionViewCell{
    var lineName = UILabel().then{
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.smallSize)
        $0.backgroundColor = UIColor(named: "MainColor")
        $0.layer.cornerRadius = 15
        $0.layer.masksToBounds = true
        $0.textAlignment = .center
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

extension ReportTableViewDefaultLineCell{
    private func layout(){
        self.contentView.addSubview(self.lineName)
        self.lineName.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
    }
    
    func viewColorSet(_ color : UIColor){
        self.lineName.backgroundColor = color
    }
}
