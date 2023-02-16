//
//  ResultVCCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import Foundation

import Then
import SnapKit

class ResultVCCell : UITableViewCell{
    var mainBG = MainStyleUIView()
    
    var stationName = UILabel().then{
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mediumSize)
    }
    
    var line = UILabel().then{
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 25
        $0.backgroundColor = UIColor(hue: 0.9333, saturation: 0.89, brightness: 0.9, alpha: 1.0)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.smallSize)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "ResultVCCell")
        self.layout()
        self.attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
}

extension ResultVCCell{
    func dataSet(line : ResultVCCellData){
        self.line.backgroundColor = UIColor(named: line.lineNumber)
        self.stationName.text = line.stationName
        self.line.text = line.useLine
    }
    
    private func attribute(){
        self.selectionStyle = .none
    }
    
    private func layout(){
        self.contentView.addSubview(self.mainBG)
        self.mainBG.addSubview(self.stationName)
        self.mainBG.addSubview(self.line)
        
        self.mainBG.snp.makeConstraints{
            $0.top.bottom.equalToSuperview().inset(ViewStyle.padding.mainStyleViewTB)
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
        }
        
        self.stationName.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(10)
        }
        
        self.line.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(10)
            $0.width.height.equalTo(50)
        }
    }
}
