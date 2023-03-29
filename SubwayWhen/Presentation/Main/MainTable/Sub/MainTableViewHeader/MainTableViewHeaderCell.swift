//
//  MainTableViewHeaderCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/13.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

class MainTableViewHeaderCell : UITableViewCell{
    var bag = DisposeBag()
    
    let mainBG = UIView().then{
        $0.backgroundColor = .systemBackground
    }
    
    var firstBG = MainStyleUIView()
    
    let mainTitle = UILabel().then{
        $0.text = "현재 지하철 예상 혼잡도"
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mediumSize)
        $0.textAlignment = .left
        $0.textColor = .label
    }
    
    let congestionLabel = UILabel().then{
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mainTitleSize)
        $0.textAlignment = .left
        $0.adjustsFontSizeToFitWidth = true
        $0.text = "😵😵😵😵😵😵😵😵🫥🫥"
    }
    
    var reportBtn = MainTableViewHeaderBtn(title: "지하철 민원", img: "Report")
    var editBtn = MainTableViewHeaderBtn(title: "편집", img: "List")
    
    override func prepareForReuse() {
        self.bag = DisposeBag()
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

extension MainTableViewHeaderCell {
    private func layout(){
        self.contentView.addSubview(self.mainBG)
        self.mainBG.snp.makeConstraints{
            $0.top.bottom.equalToSuperview().inset(ViewStyle.padding.mainStyleViewTB)
            $0.leading.equalToSuperview().offset(ViewStyle.padding.mainStyleViewLR)
            $0.trailing.equalToSuperview().offset(-ViewStyle.padding.mainStyleViewLR)
            $0.height.equalTo(190)
        }
        
        [self.firstBG, self.editBtn, self.reportBtn]
            .forEach{
                self.mainBG.addSubview($0)
            }
        
        self.firstBG.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(90)
        }
        
        self.reportBtn.snp.makeConstraints{
            $0.top.equalTo(self.firstBG.snp.bottom).offset(10)
            $0.leading.equalTo(self.mainBG)
            $0.trailing.equalTo(self.mainBG.snp.centerX).offset(-5)
            $0.height.equalTo(90)
            $0.bottom.equalToSuperview()
        }
        
        self.editBtn.snp.makeConstraints{
            $0.top.equalTo(self.firstBG.snp.bottom).offset(10)
            $0.trailing.equalTo(self.mainBG)
            $0.leading.equalTo(self.mainBG.snp.centerX).offset(5)
            $0.height.equalTo(90)
            $0.bottom.equalToSuperview()
        }
        
        
        [self.mainTitle, self.congestionLabel]
            .forEach{
                self.firstBG.addSubview($0)
            }
        
        self.mainTitle.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.bottom.equalTo(self.firstBG.snp.centerY).offset(-5)
        }
        self.congestionLabel.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.top.equalTo(self.firstBG.snp.centerY)
        }
    }
    
    private func attribute(){
        self.selectionStyle = .none
    }
    
    func bind(_ viewModel : MainTableViewHeaderViewModelProtocol){
        viewModel.peopleCount
            .map{ count -> String in
                var result = ""
                
                for _ in 1...count{
                    result.append("\(FixInfo.saveSetting.mainCongestionLabel)")
                }
                if count != 10{
                    for _ in result.count...9{
                        result.append("🫥")
                    }
                }
               
                return result
            }
            .drive(self.congestionLabel.rx.text)
            .disposed(by: self.bag)
        
        viewModel.peopleCount
            .throttle(.seconds(2), latest: false)
            .drive(onNext: { [weak self] _ in
                self?.editBtn.iconAnimationPlay()
                self?.reportBtn.iconAnimationPlay()
            })
            .disposed(by: self.bag)
        
        self.reportBtn.rx.tap
            .bind(to: viewModel.reportBtnClick)
            .disposed(by: self.bag)
        
        self.editBtn.rx.tap
            .bind(to: viewModel.editBtnClick)
            .disposed(by: self.bag)
    }
}
