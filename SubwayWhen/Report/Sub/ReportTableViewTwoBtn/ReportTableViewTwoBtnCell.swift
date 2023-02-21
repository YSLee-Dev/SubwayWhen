//
//  ReportTableViewTwoBtnCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/21.
//

import UIKit

import RxSwift
import RxCocoa
import Then
import SnapKit

class ReportTableViewTwoBtnCell : UITableViewCell{
    let mainBG = MainStyleUIView()
    
    let mainTitle = UILabel().then{
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.largeSize, weight: .semibold)
        $0.adjustsFontSizeToFitWidth = true
    }
    
    let upBtn = ModalCustomButton().then{
        $0.backgroundColor = .systemRed
        $0.setTitle("상행", for: .normal)
    }
    
    let downBtn = ModalCustomButton().then{
        $0.backgroundColor = .systemBlue
        $0.setTitle("하행", for: .normal)
    }
    
    var bag = DisposeBag()
    var index = IndexPath(row: 0, section: 0)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.attribute()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.bag = DisposeBag()
        self.unseleted()
    }
}

extension ReportTableViewTwoBtnCell{
    private func attribute(){
        self.selectionStyle = .none
    }
    
    private func layout(){
        self.contentView.addSubview(self.mainBG)
        self.mainBG.snp.makeConstraints{
            $0.top.bottom.equalToSuperview().inset(ViewStyle.padding.mainStyleViewTB)
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.height.equalTo(102)
        }
        
        [self.mainTitle, self.upBtn, self.downBtn]
            .forEach{
                self.mainBG.addSubview($0)
            }
        
        self.mainTitle.snp.makeConstraints{
            $0.leading.trailing.top.equalToSuperview().inset(15)
            $0.height.equalTo(17)
        }
        
        self.upBtn.snp.makeConstraints{
            $0.leading.equalToSuperview().inset(15)
            $0.top.equalTo(self.mainTitle.snp.bottom).offset(15)
            $0.height.equalTo(40)
            $0.trailing.equalTo(self.mainBG.snp.centerX).offset(-5)
        }
        self.downBtn.snp.makeConstraints{
            $0.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(40)
            $0.top.equalTo(self.mainTitle.snp.bottom).offset(15)
            $0.leading.equalTo(self.mainBG.snp.centerX).offset(5)
        }
    }
    
    func bind(_ cellModel : ReportTableViewTwoBtnCellModel){
        self.upBtn.rx.tap
            .map{ [weak self] _  -> String in
                self?.unseleted()
                return self?.upBtn.title(for: .normal) ?? ""
            }
            .bind(to: cellModel.updownClick)
            .disposed(by: self.bag)
        
        self.downBtn.rx.tap
            .map{[weak self] _ -> String in
                self?.unseleted()
                return self?.downBtn.title(for: .normal) ?? ""
            }
            .bind(to: cellModel.updownClick)
            .disposed(by: self.bag)
        
        Observable<Void>.merge(
            self.upBtn.rx.tap.asObservable(),
            self.downBtn.rx.tap.asObservable()
        )
        .map{[weak self] in
            self?.index ?? IndexPath(row: 0, section: 0)
        }
        .bind(to: cellModel.identityIndex)
        .disposed(by: self.bag)
    }
    
    func unseleted(){
        self.upBtn.isEnabled = false
        self.downBtn.isEnabled = false
        self.mainBG.alpha = 0.5
    }
    
    func viewDataSet(one: String, two:String, index : IndexPath, titleString : String){
        self.upBtn.setTitle(one, for: .normal)
        self.downBtn.setTitle(two, for: .normal)
        self.index = index
        self.mainTitle.text = titleString
    }
}
