//
//  MainTableViewCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/30.
//

import UIKit

import Then
import SnapKit

class MainTableViewCell : UITableViewCell{
    
    var mainBG = UIView().then{
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .secondarySystemBackground
    }
    
    var line = UILabel().then{
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 30
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .boldSystemFont(ofSize: 14)
    }
    
    var station = UILabel().then{
        $0.textColor = .systemGray
        $0.font = .systemFont(ofSize: 14)
    }
    
    var now = UILabel().then{
        $0.font = .boldSystemFont(ofSize: 16)
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    var arrivalTime = UILabel().then{
        $0.textColor = .systemRed
        $0.font = .boldSystemFont(ofSize: 18)
        $0.textAlignment = .right
        
    }
    
    var nowStackView = UIStackView().then{
        $0.distribution = .equalSpacing
        $0.spacing = 5
        $0.axis = .vertical
    }
    
    func cellSet(){
        self.selectionStyle = .none
        
        self.contentView.addSubview(self.mainBG)
        self.mainBG.snp.makeConstraints{
            $0.top.bottom.equalToSuperview().inset(7.5)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        [self.line, self.nowStackView, self.arrivalTime].forEach{
            self.mainBG.addSubview($0)
        }
        self.line.snp.makeConstraints{
            $0.leading.equalToSuperview().inset(15)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(60)
        }
        
        self.nowStackView.snp.makeConstraints{
            $0.leading.equalTo(self.line.snp.trailing).offset(15)
            $0.centerY.equalTo(self.line.snp.centerY)
            $0.trailing.equalTo(self.arrivalTime.snp.leading)
        }
        
        self.nowStackView.addArrangedSubview(self.station)
        self.nowStackView.addArrangedSubview(self.now)
        
        self.arrivalTime.snp.makeConstraints{
            $0.trailing.equalToSuperview().inset(15)
            $0.leading.equalTo(self.nowStackView.snp.trailing)
            $0.centerY.equalToSuperview()
        }
    }
    
    func lineColor(line : String){
        self.line.backgroundColor = UIColor(named: line)
    }
}
