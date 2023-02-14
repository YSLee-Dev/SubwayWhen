//
//  DetailResultScheduleTopView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/13.
//

import UIKit

import RxSwift
import RxCocoa
import Then
import SnapKit

class DetailResultScheduleTopView : TopView{
    let topBag = DisposeBag()
    
    var upDown = UILabelCustom(padding: .init(top: 0, left: 0, bottom: 0, right: 0)).then{
        $0.textColor = .label
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.smallSize, weight: .medium)
        $0.backgroundColor = UIColor(named: "MainColor")
        $0.textAlignment = .center
    }
    
    var exceptionLastStationBtn = UIButton().then{
        $0.backgroundColor = UIColor(named: "MainColor")
        
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = ViewStyle.Layer.shadowRadius
        
        $0.setTitle("제외 행 없음", for: .normal)
        $0.setTitleColor(UIColor.systemRed, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: ViewStyle.FontSize.smallSize, weight: .medium)
        $0.titleLabel?.textAlignment = .center
        $0.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DetailResultScheduleTopView {
    private func layout(){
        [self.exceptionLastStationBtn, self.upDown]
            .forEach{
                self.addSubview($0)
            }
        
        self.upDown.snp.makeConstraints{
            $0.trailing.equalTo(self.snp.centerX).offset(-10)
            $0.height.equalTo(40)
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalTo(self.subTitleLabel.snp.bottom).offset(10)
        }
        
        self.exceptionLastStationBtn.snp.makeConstraints{
            $0.leading.equalTo(self.snp.centerX).offset(10)
            $0.height.equalTo(40)
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(self.subTitleLabel.snp.bottom).offset(10)
        }
    }
    
    func bind(_ viewModel : DetailResultScheduleTopViewModel){
        self.exceptionLastStationBtn.rx.tap
            .bind(to: viewModel.exceptionLastStationBtnClick)
            .disposed(by: self.topBag)
    }
    
    func scrollMoreInfoIsHidden(_ hidden : Bool){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.75){
            if hidden{
                [self.upDown, self.exceptionLastStationBtn]
                    .forEach{
                        $0.isHidden = true
                    }
            }else{
                [self.upDown, self.exceptionLastStationBtn]
                    .forEach{
                        $0.isHidden = false
                    }
            }
        }
    }
}
