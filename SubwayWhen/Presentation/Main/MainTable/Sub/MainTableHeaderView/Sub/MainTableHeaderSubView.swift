//
//  MainTableHeaderSubView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/09/18.
//

import UIKit

import SnapKit
import Then

class MainTableHeaderSubView: ModalCustomButton {
    
    // MARK: - Properties
    
    private let mainTitle = UILabel().then{
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mediumSize)
        $0.textAlignment = .left
        $0.textColor = .label
        $0.adjustsFontSizeToFitWidth = true
    }
    
    let subTitle = UILabel().then{
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mainTitleSize)
        $0.textAlignment = .left
        $0.adjustsFontSizeToFitWidth = true
    }
    
    private lazy var arrowView = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .gray
    }
    
    // MARK: - LifeCycle
    
    init(title: String, subTitle: String, isImportantMode: Bool = false){
        super.init(bgColor: UIColor(named: "MainColor") ?? .gray, customTappedBG: nil)
        
        self.attribute(title: title, subTitle: subTitle, isImportantMode: isImportantMode)
        self.layout(isImportantMode: isImportantMode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Methods

extension MainTableHeaderSubView {
    private func attribute(title: String, subTitle: String, isImportantMode: Bool) {
        self.mainTitle.text = title
        self.subTitle.text = subTitle
        
        if isImportantMode {
            self.mainTitle.font = .boldSystemFont(ofSize: ViewStyle.FontSize.largeSize)
            self.subTitle.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mediumSize)
        }
    }
    
    private func layout(isImportantMode: Bool) {
        self.addSubviews(self.mainTitle, self.subTitle, self.arrowView)
        self.arrowView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(15)
            $0.width.equalTo(12)
            $0.height.equalTo(18)
        }
        
        self.mainTitle.snp.makeConstraints{
            $0.leading.equalToSuperview().inset(15)
            $0.bottom.equalTo(self.snp.centerY).offset(isImportantMode ? 0 : -5)
            $0.trailing.equalTo(self.arrowView.snp.leading).offset(-5)
        }
        
        self.subTitle.snp.makeConstraints{
            $0.leading.equalToSuperview().inset(15)
            $0.top.equalTo(self.snp.centerY).offset(isImportantMode ? 5 : 0)
            $0.trailing.equalTo(self.arrowView.snp.leading).offset(-5)
        }
    }
}
