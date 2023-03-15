//
//  DetailResultScheduleViewCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/06.
//

import UIKit

import SnapKit
import Then

class DetailResultScheduleViewCell : TableViewCellCustom{
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
    
    let startStationLabel = UILabel().then{
        $0.textColor = .label
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.smallSize, weight: .medium)
        $0.numberOfLines = .max
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DetailResultScheduleViewCell{
    private func layout(){
        self.mainBG.addSubview(self.minuteLabel)
        self.minuteLabel.snp.makeConstraints{
            $0.leading.equalToSuperview().inset(15)
            $0.top.bottom.equalToSuperview().inset(10)
        }
        
        self.mainBG.addSubview(self.startStationLabel)
        self.startStationLabel.snp.makeConstraints{
            $0.leading.equalTo(self.minuteLabel.snp.trailing).offset(5)
            $0.top.bottom.equalToSuperview().inset(10)
        }
        
        self.mainBG.addSubview(self.lastStationLabel)
        self.lastStationLabel.snp.makeConstraints{
            $0.leading.equalTo(self.startStationLabel.snp.trailing)
            $0.trailing.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(10)
        }
    }
    
    func cellSet(_ data : DetailResultScheduleViewCellData){
        var minute = data.minute.reduce(""){result, new in
            result + "\(new)분 \n"
        }
        minute.removeLast(1)
       
        var lastStation = data.lastStation.enumerated().reduce(""){result, new in
            let isFast = data.isFast[new.offset] == "급행" ? "(급) " : ""
            return result + " > \(new.element) \(isFast)\n"
        }
        lastStation.removeLast(1)
        
        var startStation = data.startStation.reduce(""){result, new in
            result + "\(new)\n"
        }
        startStation.removeLast(1)
        
        self.minuteLabel.text = minute
        self.startStationLabel.text = startStation
        self.lastStationLabel.text = lastStation
    }
}
