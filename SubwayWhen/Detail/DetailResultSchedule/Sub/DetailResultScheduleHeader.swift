//
//  DetailResultScheduleHeader.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/06.
//

import UIKit

import Then
import SnapKit

class DetailResultScheduleHeader : UIView{
    var stationLabel = UILabelCustom(padding: .init(top: 0, left: 0, bottom: 0, right: 0)).then{
        $0.textColor = .label
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.smallSize, weight: .medium)
        $0.backgroundColor = UIColor(named: "MainColor")
        $0.textAlignment = .center
    }
    
    var updownLabel = UILabelCustom(padding: .init(top: 0, left: 0, bottom: 0, right: 0)).then{
        $0.textColor = .red
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.smallSize, weight: .medium)
        $0.backgroundColor = UIColor(named: "MainColor")
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

extension DetailResultScheduleHeader{
    private func layout(){
        [self.updownLabel, self.stationLabel]
            .forEach{
                self.addSubview($0)
            }
        
        self.updownLabel.snp.makeConstraints{
            $0.height.equalTo(40)
            $0.leading.equalTo(self.snp.centerX).offset(10)
            $0.trailing.equalToSuperview().inset(15)
            $0.top.equalToSuperview()
        }
        
        self.stationLabel.snp.makeConstraints{
            $0.trailing.equalTo(self.snp.centerX).offset(-10)
            $0.leading.equalToSuperview().inset(15)
            $0.top.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
    
    func viewSet(station : String, updown : String){
        self.stationLabel.text = station
        self.updownLabel.text = updown
    }
}
