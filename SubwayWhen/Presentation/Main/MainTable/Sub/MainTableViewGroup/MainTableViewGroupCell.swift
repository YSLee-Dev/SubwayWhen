//
//  MainTableViewGroupCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/12/01.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

class MainTableViewGroupCell : UITableViewCell{
    var bag = DisposeBag()
    
    var status = true
    
    let groupView = MainStyleUIView()
    
    let groupOne = MainTableViewGroupBtn().then{
        $0.setTitle("출근", for: .normal)
        $0.seleted()
    }
    
    let groupTwo = MainTableViewGroupBtn().then{
        $0.setTitle("퇴근", for: .normal)
        $0.unSeleted()
    }
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layout()
        self.attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.bag = DisposeBag()
    }
}

extension MainTableViewGroupCell{
    private func layout(){
        self.contentView.addSubview(self.groupView)
        self.groupView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.height.equalTo(40)
            $0.top.bottom.equalToSuperview().inset(ViewStyle.padding.mainStyleViewTB)
        }
        
        [self.groupOne, self.groupTwo]
            .forEach{self.groupView.addSubview($0)}
        
        self.groupOne.snp.makeConstraints{
            $0.leading.equalToSuperview()
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalTo(self.groupView.snp.trailing).inset(100)
        }
        self.groupTwo.snp.makeConstraints{
            $0.trailing.equalToSuperview()
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(self.groupOne.snp.trailing)
        }
    }
    
    private func attribute(){
        self.selectionStyle = .none
    }
    
    func bind(groupData: Driver<SaveStationGroup>) -> Observable<SaveStationGroup> {
        groupData
            .drive(self.rx.groupDesign)
            .disposed(by: self.bag)
        
        let oneClick = groupOne.rx.tap
            .map{ _ -> SaveStationGroup in
                return .one
            }
        let twoClick = groupTwo.rx.tap
            .map{_ -> SaveStationGroup in
                return .two
            }
        
        let click = Observable
            .merge(oneClick, twoClick)
            .share()
        
        click
            .bind(to: self.rx.groupDesign)
            .disposed(by: self.bag)
        
        return click
    }
    
    func btnClickSizeChange(group : Bool){
            if group{
                self.groupOne.snp.remakeConstraints{
                    $0.leading.equalToSuperview()
                    $0.top.bottom.equalToSuperview()
                    $0.trailing.equalTo(self.groupView.snp.leading).inset(100)
                }
            }else{
                self.groupOne.snp.remakeConstraints{
                    $0.leading.equalToSuperview()
                    $0.top.bottom.equalToSuperview()
                    $0.trailing.equalTo(self.groupView.snp.trailing).inset(100)
                }
            }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.75){
            self.layoutIfNeeded()
        }
    }
}

extension Reactive where Base : MainTableViewGroupCell{
    var groupDesign : Binder<SaveStationGroup>{
        return Binder(base){base, group in
            if group == .one{
                base.groupOne.seleted()
                base.groupTwo.unSeleted()
                base.btnClickSizeChange(group: false)
            }else{
                base.groupOne.unSeleted()
                base.groupTwo.seleted()
                base.btnClickSizeChange(group: true)
            }
        }
    }
}
