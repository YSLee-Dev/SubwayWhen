//
//  SettingGroupModalTF.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/08.
//

import UIKit

import Then
import SnapKit

class SettingGroupModalTF : UIView{
    let tf = UITextField().then{
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.mediumSize)
        $0.textColor = . systemRed
        $0.keyboardType = .numberPad
        $0.textAlignment = .right
    }
    
    let hourTitle = UILabel().then{
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.mediumSize)
        $0.textColor = .systemRed
        $0.text = "시"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SettingGroupModalTF{
    private func layout(){
        self.addSubview(self.hourTitle)
        self.hourTitle.snp.makeConstraints{
            $0.top.bottom.trailing.equalToSuperview()
            $0.width.equalTo(15)
        }
        
        self.addSubview(self.tf)
        self.tf.snp.makeConstraints{
            $0.leading.top.bottom.equalToSuperview()
            $0.trailing.equalTo(self.hourTitle.snp.leading)
        }
    }
}
