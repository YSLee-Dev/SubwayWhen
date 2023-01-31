//
//  DetailTableHeaderView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/03.
//

import UIKit

import RxSwift
import RxCocoa
import RxOptional
import Then
import SnapKit

class DetailTableHeaderView : UITableViewCell{
    let bag = DisposeBag()
    
    lazy var stationName = UILabelCustom(padding: .init(top: 5, left: 5, bottom: 5, right: 5)).then{
        $0.layer.cornerRadius = 37.5
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mediumSize)
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1
    }
    
    var backStation = UILabel().then{
        $0.textColor = .white
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mediumSize)
        $0.adjustsFontSizeToFitWidth = true
        $0.textAlignment = .right
    }
    
    var nextStation = UILabel().then{
        $0.textColor = .white
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mediumSize)
        $0.adjustsFontSizeToFitWidth = true
        $0.textAlignment = .left
    }
    
    var lineColor = UIView().then{
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
    }
    
    var upDown = UILabelCustom(padding: .init(top: 0, left: 0, bottom: 0, right: 0)).then{
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
    
    lazy var exceptionLastStationMoreBtn = UIButton().then{
        $0.setImage(UIImage(systemName: "arrowtriangle.down"), for: .normal)
        $0.tintColor = .systemRed
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
            $0.top.equalToSuperview().inset(12.5)
            $0.height.equalTo(50)
        }
        
        self.contentView.addSubview(stationName)
        self.stationName.snp.makeConstraints{
            $0.size.equalTo(75)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
        }
        
        [self.backStation, self.nextStation]
            .forEach{
                self.lineColor.addSubview($0)
            }
        
        self.backStation.snp.makeConstraints{
            $0.centerY.equalTo(self.stationName)
            $0.trailing.equalToSuperview().inset(15)
            $0.leading.equalTo(self.stationName.snp.trailing).offset(5)
        }
        
        self.nextStation.snp.makeConstraints{
            $0.centerY.equalTo(self.stationName)
            $0.leading.equalToSuperview().inset(15)
            $0.trailing.equalTo(self.stationName.snp.leading).offset(-5)
        }
        
        [self.exceptionLastStationBtn, self.upDown]
            .forEach{
                self.contentView.addSubview($0)
            }
        
        self.upDown.snp.makeConstraints{
            $0.trailing.equalTo(self.snp.centerX).offset(-10)
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().inset(15)
            $0.top.equalTo(self.stationName.snp.bottom).offset(10)
            $0.height.equalTo(40)
        }
        
        self.exceptionLastStationBtn.snp.makeConstraints{
            $0.height.equalTo(40)
            $0.leading.equalTo(self.snp.centerX).offset(10)
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(15)
            $0.top.equalTo(self.stationName.snp.bottom).offset(10)
        }
    }
    
    func bind(_ viewModel : DetailTableHeaderViewModel){
        self.exceptionLastStationBtn.rx.tap
            .bind(to: viewModel.exceptionLastStationBtnClick)
            .disposed(by: self.bag)
    }
    
    func excpetionLastStationMoreBtnLayout(){
        self.exceptionLastStationBtn.addSubview(self.exceptionLastStationMoreBtn)
        self.exceptionLastStationMoreBtn.snp.makeConstraints{
            $0.width.equalTo(25)
            $0.height.equalTo(15)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-10)
        }
        
        self.exceptionLastStationBtn.snp.updateConstraints{
            $0.trailing.equalToSuperview().inset(35)
        }
    }
    
    func cellSet(_ data : DetailTableViewCellData){
        self.lineColor.backgroundColor = UIColor(named: data.lineNumber)
        self.stationName.layer.borderColor = UIColor(named: data.lineNumber)?.cgColor
        
        self.stationName.text = data.stationName
        self.backStation.text = data.backStationName == data.stationName ? "" : data.backStationName
        self.nextStation.text = data.nextStationName == data.stationName ? "" : data.nextStationName
        self.upDown.text = data.upDown
        self.exceptionLastStationBtn.setTitle( data.exceptionLastStation == "" ? "제외 행 없음" : "\(data.exceptionLastStation)행 제외", for: .normal)
        
        self.exceptionLastStationBtn.isEnabled = data.exceptionLastStation != ""
        
        if data.exceptionLastStation != ""{
            self.excpetionLastStationMoreBtnLayout()
        }
    }
}
