//
//  NoNetworkModal.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/21.
//

import UIKit

import SnapKit
import Then

class NoNetworkView : UIView{
    let titleLable = UILabel().then{
        $0.text = "현재 인터넷에 연결되어 있지 않아요."
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.largeSize)
        $0.textAlignment = .center
        $0.textColor = .white
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.attribute()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NoNetworkView {
    private func attribute(){
        self.backgroundColor = UIColor(named: "AppIconColor")
    }
    
    private func layout(){
        self.addSubview(self.titleLable)
        self.titleLable.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(10)
        }
    }
}
