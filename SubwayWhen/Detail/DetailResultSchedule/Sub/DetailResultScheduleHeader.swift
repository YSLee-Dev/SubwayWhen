//
//  DetailResultScheduleHeader.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/06.
//

import UIKit

import Then
import SnapKit

class DetailResultScheduleHeader : TitleView{
    var updownLabel = UILabelCustom(padding: .init(top: 0, left: 0, bottom: 0, right: 0)).then{
        $0.textColor = .label
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.smallSize, weight: .medium)
        $0.backgroundColor = UIColor(named: "MainColor")
        $0.textAlignment = .center
    }
    
    var exceptionLastStationBtn = UIButton().then{
        $0.backgroundColor = UIColor(named: "MainColor")
        
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        
        $0.setTitle("제외 행 없음", for: .normal)
        $0.setTitleColor(UIColor.systemRed, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: ViewStyle.FontSize.smallSize, weight: .medium)
        $0.titleLabel?.textAlignment = .center
        $0.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DetailResultScheduleHeader{
    private func layout(){
        [self.exceptionLastStationBtn, self.updownLabel]
            .forEach{
                self.addSubview($0)
            }
        
        self.exceptionLastStationBtn.snp.makeConstraints{
            $0.height.equalTo(40)
            $0.leading.equalTo(self.snp.centerX).offset(10)
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(15)
            $0.top.equalTo(self.mainTitleLabel.snp.bottom).offset(10)
        }
        
        self.updownLabel.snp.makeConstraints{
            $0.trailing.equalTo(self.snp.centerX).offset(-10)
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().inset(15)
            $0.top.equalTo(self.mainTitleLabel.snp.bottom).offset(10)
            $0.height.equalTo(40)
        }
    }
    
    func viewSet(excptionLastStation : String, updown : String){
        self.exceptionLastStationBtn.setTitle("\(excptionLastStation)행 제외", for: .normal)
        self.updownLabel.text = updown
    }
}
