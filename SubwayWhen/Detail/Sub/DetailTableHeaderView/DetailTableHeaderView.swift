//
//  DetailTableHeaderView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/03.
//

import UIKit

import RxSwift
import RxCocoa
import Then
import SnapKit

class DetailTableHeaderView : UITableViewCell{
    lazy var stationName = UILabel().then{
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 37.5
        $0.textColor = .label
        $0.textAlignment = .center
        $0.font = .boldSystemFont(ofSize: 17)
        $0.backgroundColor = .systemBackground
    }
    
    var backStation = UILabel().then{
        $0.textColor = .label
        $0.font = .systemFont(ofSize: 16)
    }
    
    var nextStation = UILabel().then{
        $0.textColor = .label
        $0.font = .systemFont(ofSize: 16)
    }
    
    var lineColor = UIView().then{
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.attribute()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DetailTableHeaderView {
    private func attribute(){
        self.contentView.backgroundColor = .clear
        self.selectionStyle = .none
    }
    
    private func layout(){
        self.contentView.addSubview(self.lineColor)
        self.lineColor.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.top.equalToSuperview()
            $0.height.equalTo(75)
        }
        [self.stationName, self.backStation, self.nextStation]
            .forEach{
                self.lineColor.addSubview($0)
            }
        
        self.stationName.snp.makeConstraints{
            $0.size.equalTo(75)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.contentView)
        }
        
        self.nextStation.snp.makeConstraints{
            $0.centerY.equalTo(self.stationName)
            $0.trailing.equalToSuperview().inset(15)
        }
        
        self.backStation.snp.makeConstraints{
            $0.centerY.equalTo(self.stationName)
            $0.leading.equalToSuperview().inset(15)
        }
    }
    
    func cellSet(_ data : DetailTableViewCellData){
        self.lineColor.backgroundColor = UIColor(named: data.lineNumber)
        
        self.stationName.text = data.stationName
        
    }
}
