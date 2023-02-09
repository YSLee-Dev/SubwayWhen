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
    var index = IndexPath(row: 0, section: 0)
    var bag = DisposeBag()
    
    var mainBG = MainStyleUIView()
    
    lazy var line = UILabel().then{
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 30
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.smallSize)
    }
    
    var station = UILabel().then{
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.smallSize)
        $0.textColor = .label
    }
    
    var now = UILabel().then{
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mediumSize)
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        $0.textColor = .label
    }
    
    var arrivalTime = UILabel().then{
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.largeSize)
        $0.textAlignment = .right
        $0.textColor = .label
    }
    
    var nowStackView = UIStackView().then{
        $0.distribution = .equalSpacing
        $0.spacing = 5
        $0.axis = .vertical
    }
    
    lazy var changeBtn = UIButton().then{
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = ViewStyle.Layer.shadowRadius
        $0.setImage(UIImage(systemName: "timer"), for: .normal)
        $0.tintColor = .white
        $0.titleLabel?.font = .boldSystemFont(ofSize: 14)
    }
    
    lazy var border = UIView().then{
        $0.layer.borderWidth = 1.0
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layout()
        self.attibute()
    }
    
    // 재사용 시 초기화 구문
    override func prepareForReuse() {
        self.bag = DisposeBag()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cellSet(data : MainTableViewCellData, cellModel : MainTableViewCellModel, indexPath : IndexPath){
        self.bind(cellModel)
        self.index = indexPath
        
        self.station.text = "\(data.stationName) | \(data.lastStation)"
        self.line.text = data.useLine
        
        self.arrivalTime.text = "\(data.useTime)"
        self.now.text = "\(data.useFast)\(data.cutString(cutString: data.previousStation)) \(data.useCode)"
        self.lineColor(line: data.lineNumber)
    }
    
    func lineColor(line : String){
        self.border.layer.borderColor = UIColor(named: line)?.cgColor
        self.line.backgroundColor = UIColor(named: line)
        self.changeBtn.backgroundColor = UIColor(named: line)
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
            $0.height.equalTo(1)
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
                self.index
            }
            .bind(to: viewModel.cellTimeChangeBtnClick)
            .disposed(by: self.bag)
    }
}
