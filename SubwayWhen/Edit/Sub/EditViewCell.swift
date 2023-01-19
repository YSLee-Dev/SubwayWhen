//
//  EditViewCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/19.
//

import UIKit

import Then
import SnapKit

class EditViewCell : UITableViewCell{
    
    var mainBG = MainStyleUIView().then{
        $0.layer.borderWidth = 1.0
    }
    
    lazy var line = UILabel().then{
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 30
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .boldSystemFont(ofSize: 14)
    }
    
    var stationName = UILabel().then{
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textAlignment = .right
        $0.textColor = .label
    }
    
    var upDown = UILabel().then{
        $0.font = .systemFont(ofSize: 14)
        $0.textAlignment = .right
        $0.textColor = .label
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layout()
        self.attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditViewCell{
    private func layout(){
        self.contentView.addSubview(self.mainBG)
        self.mainBG.snp.makeConstraints{
            $0.top.bottom.equalToSuperview().inset(7.5)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        [self.line, self.stationName, self.upDown].forEach{
            self.mainBG.addSubview($0)
        }
        self.line.snp.makeConstraints{
            $0.leading.equalTo(self.mainBG).inset(15)
            $0.centerY.equalTo(self.mainBG)
            $0.size.equalTo(60)
        }
        self.stationName.snp.makeConstraints{
            $0.leading.equalTo(self.line.snp.trailing).offset(15)
            $0.centerY.equalTo(self.line)
        }
        self.upDown.snp.makeConstraints{
            $0.leading.equalTo(self.stationName.snp.trailing).offset(5)
            $0.centerY.equalTo(self.line)
        }
    }
    
    private func attribute(){
        self.selectionStyle = .none
    }
    
    func lineColor(line : String){
        self.mainBG.layer.borderColor = UIColor(named: line)?.cgColor
        self.line.backgroundColor = UIColor(named: line)
    }
    
    func cellSet(data : EditViewCellData){
        self.lineColor(line: data.line)
        self.stationName.text = data.stationName
        self.upDown.text = data.updnLine
        self.line.text = data.useLine
    }
}
