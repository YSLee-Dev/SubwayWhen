//
//  MainTableViewCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/30.
//

import UIKit

import RxSwift
import RxCocoa
import Then
import SnapKit

class MainTableViewCell : UITableViewCell{
    
    var id = ""
    var bag = DisposeBag()
    
    var mainBG = UIView().then{
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
    }
    
    lazy var line = UILabel().then{
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 30
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .boldSystemFont(ofSize: 14)
        $0.backgroundColor = self.grayAlpha
    }
    
    var station = UILabel().then{
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 14)
    }
    
    var now = UILabel().then{
        $0.font = .boldSystemFont(ofSize: 16)
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        $0.textColor = .white
    }
    
    var arrivalTime = UILabel().then{
        $0.textColor = .white
        $0.font = .boldSystemFont(ofSize: 18)
        $0.textAlignment = .right
        
    }
    
    var nowStackView = UIStackView().then{
        $0.distribution = .equalSpacing
        $0.spacing = 5
        $0.axis = .vertical
    }
    
    lazy var changeBtn = UIButton().then{
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        $0.backgroundColor = self.grayAlpha
        $0.setTitle("실시간", for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 14)
    }
    
    lazy var border = UIView().then{
        $0.layer.borderColor = self.grayAlpha.cgColor
        $0.layer.borderWidth = 0.5
    }
    
    var grayAlpha = UIColor.black.withAlphaComponent(0.15)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layout()
        self.attibute()
    }
    
    override func prepareForReuse() {
        self.bag = DisposeBag()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cellSet(id : String, cellModel : MainTableViewCellModel){
        self.id = id
        self.bind(cellModel)
    }
    
    func lineColor(line : String){
        self.mainBG.backgroundColor = UIColor(named: line)
    }
}

extension MainTableViewCell{
    private func layout(){
        self.contentView.addSubview(self.mainBG)
        self.mainBG.snp.makeConstraints{
            $0.top.bottom.equalToSuperview().inset(7.5)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        [self.line, self.nowStackView, self.arrivalTime, self.changeBtn, self.border].forEach{
            self.mainBG.addSubview($0)
        }
        self.line.snp.makeConstraints{
            $0.leading.top.equalToSuperview().inset(15)
            $0.size.equalTo(60)
        }
        
        self.nowStackView.snp.makeConstraints{
            $0.leading.equalTo(self.line.snp.trailing).offset(15)
            $0.centerY.equalTo(self.line.snp.centerY)
            $0.trailing.equalTo(self.arrivalTime.snp.leading)
        }
        
        self.nowStackView.addArrangedSubview(self.station)
        self.nowStackView.addArrangedSubview(self.now)
        
        self.changeBtn.snp.makeConstraints{
            $0.trailing.equalToSuperview().inset(15)
            $0.width.equalTo(80)
            $0.height.equalTo(30)
            $0.top.equalTo(self.nowStackView.snp.bottom).offset(15)
        }
        
        self.border.snp.makeConstraints{
            $0.leading.equalTo(self.line)
            $0.trailing.equalTo(self.changeBtn.snp.leading)
            $0.top.equalTo(self.changeBtn.snp.bottom).inset(15)
            $0.height.equalTo(0.5)
        }
        
        self.arrivalTime.snp.makeConstraints{
            $0.trailing.equalToSuperview().inset(15)
            $0.leading.equalTo(self.nowStackView.snp.trailing)
            $0.top.equalTo(self.changeBtn.snp.bottom).offset(15)
            $0.height.equalTo(30)
            $0.bottom.equalToSuperview().inset(15)
        }
    }
    
    private func attibute(){
        self.selectionStyle = .none
    }
    
    func bind(_ viewModel : MainTableViewCellModel){
        self.changeBtn.rx.tap
            .map{
                self.id
            }
            .bind(to: viewModel.cellTimeChangeBtnClick)
            .disposed(by: self.bag)
    }
}
