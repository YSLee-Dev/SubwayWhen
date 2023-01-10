//
//  DetailTableArrivalCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/05.
//

import UIKit

import RxSwift
import RxCocoa

class DetailTableArrivalCell : UITableViewCell{
    var bag = DisposeBag()
    
    var mainBG = UIView().then{
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        $0.backgroundColor = UIColor(named: "MainColor")
    }
    
    var mainTitle = UILabel().then{
        $0.textColor = .label
        $0.font = .boldSystemFont(ofSize: 16)
        $0.adjustsFontSizeToFitWidth = true
        $0.textAlignment = .left
    }
    
    var firstSubway = UILabelCustom(padding: .init(top: 0, left: 5, bottom: 0, right: 5)).then{
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 15, weight: .medium)
        $0.numberOfLines = 2
        $0.textColor = .white
    }
    
    var secondSubway = UILabelCustom(padding: .init(top: 0, left: 5, bottom: 0, right: 5)).then{
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 15, weight: .medium)
        $0.numberOfLines = 2
        $0.textColor = .white
    }
    
    override func prepareForReuse() {
        self.bag = DisposeBag()
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

extension DetailTableArrivalCell {
    private func attribute(){
        self.selectionStyle = .none
    }
    
    private func layout(){
        self.contentView.addSubview(self.mainBG)
        self.mainBG.snp.makeConstraints{
            $0.top.bottom.equalToSuperview().inset(7.5)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        [self.mainTitle, self.firstSubway, self.secondSubway]
            .forEach{
                self.mainBG.addSubview($0)
            }
        
        self.mainTitle.snp.makeConstraints{
            $0.leading.top.trailing.equalToSuperview().inset(15)
        }
        
        self.firstSubway.snp.makeConstraints{
            $0.top.equalTo(self.mainTitle.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalTo(self.mainBG.snp.centerX).offset(35)
            $0.height.equalTo(45)
        }
        
        self.secondSubway.snp.makeConstraints{
            $0.top.equalTo(self.firstSubway.snp.bottom).offset(10)
            $0.trailing.equalToSuperview().inset(15)
            $0.leading.equalTo(self.mainBG.snp.centerX).offset(-35)
            $0.height.equalTo(45)
            $0.bottom.equalToSuperview().inset(15)
        }
    }
    
    func bind(_ viewModel : DetailTableArrivalCellModel){
        viewModel.realTimeData
            .bind(to: self.rx.dataViewSet)
            .disposed(by: self.bag)
            
    }
    
    func lineColorSet(_ color : UIColor){
        self.firstSubway.backgroundColor = color
        self.secondSubway.backgroundColor = color
    }
}

extension Reactive where Base : DetailTableArrivalCell {
    var dataViewSet : Binder<[RealtimeStationArrival]>{
        return Binder(base){ base, dataArray in
            if let firstData = dataArray.first{
                base.mainTitle.text = "\(firstData.subPrevious)"
                base.firstSubway.text = "🚇 \(firstData.trainCode) 열차 \n \(firstData.subPrevious)"
            }else{
                base.mainTitle.text = "⚠️ 실시간 정보없음"
            }
            
            if let secondData = dataArray.last{
                base.secondSubway.text = secondData.subPrevious != "" ? "🚇 \(secondData.trainCode) 열차 \n \(secondData.subPrevious)" : "⚠️ 실시간 정보없음"
            }else{
                base.secondSubway.text = "⚠️ 실시간 정보없음"
            }
        }
    }
}
