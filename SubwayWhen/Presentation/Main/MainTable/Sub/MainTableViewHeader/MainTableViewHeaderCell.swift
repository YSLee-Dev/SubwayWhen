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
    
    var congestionLabelBG = MainTableViewHeaderView(
        title: "현재 지하철 예상 혼잡도", subTitle: "🫥🫥🫥🫥🫥🫥🫥🫥🫥🫥"
    )
    
    lazy var importantLabelBG = MainTableViewHeaderView (
        title: "중요알림", subTitle: "중요알림"
    )
    
    var reportBtn = MainTableViewHeaderBtn(title: "지하철 민원", img: "Report")
    var editBtn = MainTableViewHeaderBtn(title: "편집", img: "List")
    
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
    
    func isImportant(data: ImportantData?) {
        self.importantLayout()
        if let data = data {
            self.importantLabelBG.subTitle.text = data.contents
            self.importantLabelBG.smallSizeTransform(title: data.title)
        }
        self.congestionLabelBG.smallSizeTransform(title: "예상 혼잡도")
        
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
        
        [self.congestionLabelBG, self.editBtn, self.reportBtn]
            .forEach{
                self.mainBG.addSubview($0)
            }
        
        self.congestionLabelBG.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(90)
        }
        
        self.reportBtn.snp.makeConstraints{
            $0.top.equalTo(self.congestionLabelBG.snp.bottom).offset(10)
            $0.leading.equalTo(self.mainBG)
            $0.trailing.equalTo(self.mainBG.snp.centerX).offset(-5)
            $0.bottom.equalToSuperview()
        }
        
        self.editBtn.snp.makeConstraints{
            $0.top.equalTo(self.congestionLabelBG.snp.bottom).offset(10)
            $0.trailing.equalTo(self.mainBG)
            $0.leading.equalTo(self.mainBG.snp.centerX).offset(5)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func importantLayout() {
        self.mainBG.snp.updateConstraints {
            $0.height.equalTo(250)
        }
        
        self.mainBG.addSubview(self.importantLabelBG)
        self.importantLabelBG.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(70)
        }
        
        self.congestionLabelBG.snp.remakeConstraints {
            $0.top.equalTo(self.importantLabelBG.snp.bottom).offset(10)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(70)
        }
    }
    
    private func attribute(){
        self.selectionStyle = .none
    }
    
    func bind(peopleData: Driver<Int>) {
        peopleData
            .map{ count -> String in
                var result = ""
                
                if count == 0{
                    for _ in 1...10{
                        result.append("🫥")
                    }
                }else{
                    for _ in 1...count{
                        result.append("\(FixInfo.saveSetting.mainCongestionLabel)")
                    }
                    if count != 10{
                        for _ in result.count...9{
                            result.append("🫥")
                        }
                    }
                }
                
                return result
            }
            .drive(self.congestionLabelBG.subTitle.rx.text)
            .disposed(by: self.bag)
        
        peopleData
            .throttle(.seconds(2), latest: false)
            .drive(onNext: { [weak self] _ in
                self?.editBtn.iconAnimationPlay()
                self?.reportBtn.iconAnimationPlay()
            })
            .disposed(by: self.bag)
    }
}
