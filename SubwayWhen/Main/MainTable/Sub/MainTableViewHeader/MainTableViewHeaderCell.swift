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
    let bag = DisposeBag()
    
    let mainBG = UIView().then{
        $0.backgroundColor = .systemBackground
    }
    
    var firstBG = MainStyleUIView().then{
        $0.layer.borderColor = UIColor.gray.cgColor
        $0.layer.borderWidth = 1.0
    }
    
    let mainTitle = UILabel().then{
        $0.text = "현재 지하철 예상 혼잡도"
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mediumSize)
        $0.textAlignment = .left
        $0.textColor = .label
    }
    
    let congestionLabel = UILabel().then{
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mainTitleSize)
        $0.textAlignment = .left
        $0.text = "😵😵😵😵😵😵😵😵🫥🫥"
    }
    
    var searchBtn = MainTableViewHeaderBtn(title: "검색", img: UIImage(systemName: "magnifyingglass")!)
    var editBtn = MainTableViewHeaderBtn(title: "편집", img: UIImage(systemName: "list.bullet.indent")!)
    
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
            $0.top.bottom.equalToSuperview().inset(7.5)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(190)
        }
        
        [self.firstBG, self.searchBtn, self.editBtn]
            .forEach{
                self.mainBG.addSubview($0)
            }
        
        self.firstBG.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(90)
        }
        
        self.searchBtn.snp.makeConstraints{
            $0.top.equalTo(self.firstBG.snp.bottom).offset(10)
            $0.leading.equalTo(self.mainBG)
            $0.trailing.equalTo(self.mainBG.snp.centerX).offset(-7.5)
            $0.height.equalTo(90)
            $0.bottom.equalToSuperview()
        }
        
        self.editBtn.snp.makeConstraints{
            $0.top.equalTo(self.firstBG.snp.bottom).offset(10)
            $0.trailing.equalTo(self.mainBG)
            $0.leading.equalTo(self.mainBG.snp.centerX).offset(7.5)
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
    
    func bind(_ viewModel : MainTableViewHeaderCellModel){
        viewModel.peopleCount
            .map{ count -> String in
                var result = ""
                
                for _ in 1...count{
                    result.append("😵")
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
        
        self.searchBtn.rx.tap
            .bind(to: viewModel.searchBtnClick)
            .disposed(by: self.bag)
        
        self.editBtn.rx.tap
            .bind(to: viewModel.editBtnClick)
            .disposed(by: self.bag)
    }
}
