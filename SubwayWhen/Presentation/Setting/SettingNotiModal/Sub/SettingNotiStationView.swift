//
//  SettingNotiStationView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/21.
//

import UIKit

import Then
import SnapKit

class SettingNotiStationView: UIView {
    let groupOneTitle = UILabel().then {
        $0.text = "출근시간"
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.largeSize, weight: .bold)
        $0.textColor = .label
    }
    
    let groupOneLine = UILabel().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 30
        $0.backgroundColor = .systemGray
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mediumSize)
        $0.text = "?"
    }
    
    let groupOneBtn = ModalCustomButton().then {
        $0.backgroundColor = UIColor(named: "MainColor")
    }
    
    let groupOneStation = UILabel().then {
        $0.text = "역 선택"
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.mediumSize, weight: .medium)
        $0.textColor = .label
    }
    
    let groupTwoTitle = UILabel().then {
        $0.text = "퇴근시간"
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.largeSize, weight: .bold)
        $0.textColor = .label
    }
    
    let groupTwoLine = UILabel().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 30
        $0.backgroundColor = .systemGray
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mediumSize)
        $0.text = "?"
    }
    
    let groupTwoLBtn = ModalCustomButton().then {
        $0.backgroundColor = UIColor(named: "MainColor")
    }
    
    let groupTwoStation = UILabel().then {
        $0.text = "역 선택"
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.mediumSize, weight: .medium)
        $0.textColor = .label
    }
    
    let border = UIView().then {
        $0.backgroundColor = .gray.withAlphaComponent(0.5)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SettingNotiStationView {
    private func layout() {
        [self.groupOneTitle, self.groupTwoTitle, self.groupOneBtn, self.groupTwoLBtn, self.border].forEach {
            self.addSubview($0)
        }
        
        self.groupOneTitle.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.top.equalToSuperview().offset(35)
        }
        
        self.groupOneBtn.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.trailing.equalTo(self.snp.centerX).offset(-ViewStyle.padding.mainStyleViewLR)
            $0.top.equalTo(self.groupOneTitle.snp.bottom).offset(ViewStyle.padding.mainStyleViewTB)
            $0.height.equalTo(110)
        }
        
        [self.groupOneLine, self.groupOneStation]
            .forEach{
                self.groupOneBtn.addSubview($0)
            }
        
        self.groupOneLine.snp.makeConstraints {
            $0.centerY.equalToSuperview().inset(ViewStyle.padding.mainStyleViewTB)
            $0.leading.equalToSuperview().inset(8)
            $0.size.equalTo(60)
        }
        
        self.groupOneStation.snp.makeConstraints {
            $0.centerY.equalTo(self.groupOneLine)
            $0.leading.equalTo(self.groupOneLine.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-8)
        }
        
        self.groupTwoTitle.snp.makeConstraints {
            $0.leading.equalTo(self.snp.centerX).offset(ViewStyle.padding.mainStyleViewLR)
            $0.top.equalToSuperview().offset(35)
        }
        
        self.groupTwoLBtn.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-ViewStyle.padding.mainStyleViewLR)
            $0.leading.equalTo(self.snp.centerX).offset(ViewStyle.padding.mainStyleViewLR)
            $0.top.equalTo(self.groupTwoTitle.snp.bottom).offset(ViewStyle.padding.mainStyleViewTB)
            $0.height.equalTo(110)
        }
        
        [self.groupTwoLine, self.groupTwoStation]
            .forEach{
                self.groupTwoLBtn.addSubview($0)
            }
        
        self.groupTwoLine.snp.makeConstraints {
            $0.centerY.equalToSuperview().inset(ViewStyle.padding.mainStyleViewTB)
            $0.leading.equalToSuperview().inset(8)
            $0.size.equalTo(60)
        }
        
        self.groupTwoStation.snp.makeConstraints {
            $0.centerY.equalTo(self.groupTwoLine)
            $0.leading.equalTo(self.groupTwoLine.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-8)
        }
        
        self.border.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.bottom.equalTo(self.groupOneBtn)
            $0.width.equalTo(0.5)
        }
    }
    
    func viewDataSet(data: NotificationManagerRequestData) {
        if data.group == .one {
            self.groupOneStation.text = data.stationName
            self.groupOneLine.text = data.useLine
            self.groupOneLine.backgroundColor = UIColor(named: data.line)
        } else {
            self.groupTwoStation.text = data.stationName
            self.groupTwoLine.text = data.useLine
            self.groupTwoLine.backgroundColor = UIColor(named: data.line)
        }
        
    }
}
