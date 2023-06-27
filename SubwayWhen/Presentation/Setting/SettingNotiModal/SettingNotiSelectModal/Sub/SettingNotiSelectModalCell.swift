//
//  SettingNotiSelectModalCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/26.
//

import UIKit

import Then
import SnapKit

class SettingNotiSelectModalCell: TableViewCellCustom{
    lazy var line = UILabel().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 30
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.smallSize)
    }
    
    var stationName = UILabel().then {
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mediumSize)
        $0.textAlignment = .left
        $0.textColor = .label
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    var upDown = UILabel().then {
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.smallSize)
        $0.textAlignment = .right
        $0.textColor = .label
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 재사용 시 포인트 컬러 제거
        self.mainBG.backgroundColor = UIColor(named: "MainColor")
        self.stationName.textColor = .label
        self.upDown.textColor = .label
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SettingNotiSelectModalCell{
    private func layout() {
        [self.line, self.stationName, self.upDown].forEach{
            self.mainBG.addSubview($0)
        }
        self.line.snp.makeConstraints {
            $0.leading.equalTo(self.mainBG).inset(15)
            $0.centerY.equalTo(self.mainBG)
            $0.size.equalTo(60)
        }
        self.stationName.snp.makeConstraints {
            $0.leading.equalTo(self.line.snp.trailing).offset(15)
            $0.centerY.equalTo(self.line)
        }
        self.upDown.snp.makeConstraints {
            $0.leading.equalTo(self.stationName.snp.trailing).offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.centerY.equalTo(self.line)
        }
    }
    
    func lineColor(line: String) {
        self.line.backgroundColor = UIColor(named: line)
    }
    
    func cellSet(data: SettingNotiSelectModalCellData) {
        self.lineColor(line: data.line)
        self.stationName.text = data.stationName
        self.upDown.text = data.updnLine
        self.line.text = data.useLine
        
        if data.isChecked {
            self.mainBG.backgroundColor = UIColor(named: "AppIconColor")?.withAlphaComponent(0.7)
            self.stationName.textColor = .white
            self.upDown.textColor = .white
        }
    }
}
