//
//  DetailResultScheduleViewCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/06.
//

import UIKit

import SnapKit
import Then

class DetailResultScheduleViewCell : UITableViewCell{
    let mainCell = MainStyleUIView()
    
    let minuteLabel = UILabel().then{
        $0.textColor = .label
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.smallSize, weight: .medium)
        $0.numberOfLines = .max
    }
    
    let lastStationLabel = UILabel().then{
        $0.textColor = .label
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.smallSize, weight: .medium)
        $0.numberOfLines = .max
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

extension DetailResultScheduleViewCell{
    private func attribute(){
        self.selectionStyle = .none
    }
    
    private func layout(){
        self.contentView.addSubview(self.mainCell)
        self.mainCell.snp.makeConstraints{
            $0.top.equalToSuperview().offset(7.5)
            $0.bottom.equalToSuperview().inset(7.5)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        self.mainCell.addSubview(self.minuteLabel)
        self.minuteLabel.snp.makeConstraints{
            $0.leading.equalToSuperview().offset(10)
            $0.top.bottom.equalToSuperview().inset(10)
        }
        
        self.mainCell.addSubview(self.lastStationLabel)
        self.lastStationLabel.snp.makeConstraints{
            $0.leading.equalTo(self.minuteLabel.snp.trailing).offset(5)
            $0.trailing.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(10)
        }
    }
    
    func cellSet(_ data : DetailResultScheduleViewCellData){
        var minute = data.minute.reduce(""){result, new in
            result + "\(new)분 \n"
        }
        minute.removeLast(2)
       
        
        var lastStation = data.lastStation.reduce(""){result, new in
            result + "(\(new)행) \n"
        }
        lastStation.removeLast(2)
        
        self.minuteLabel.text = minute
        self.lastStationLabel.text = lastStation
    }
}
