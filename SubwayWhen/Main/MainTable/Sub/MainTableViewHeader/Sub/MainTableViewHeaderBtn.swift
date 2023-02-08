//
//  MainTableViewHeaderBtn.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/08.
//

import UIKit

import Then
import SnapKit

class MainTableViewHeaderBtn : UIButton{
    
    let btnLabel = UILabel().then{
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.largeSize)
    }
    
    let btnImg = UIImageView()
    
    init(title : String, img : UIImage){
        super.init(frame: .null)
        self.layout()
        self.attribute(title : title, img: img)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainTableViewHeaderBtn{
    private func layout(){
        self.addSubview(self.btnLabel)
        self.addSubview(self.btnImg)
        
        self.btnLabel.snp.makeConstraints{
            $0.top.leading.trailing.equalToSuperview().inset(15)
        }
        
        self.btnImg.snp.makeConstraints{
            $0.trailing.bottom.equalToSuperview().inset(15)
            $0.size.equalTo(35)
        }
    }
    
    private func attribute(title : String, img : UIImage){
        self.backgroundColor = UIColor(named: "MainColor")
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 15
        self.tintColor = .label
        
        self.btnLabel.text = title
        self.btnImg.image = img
    }
}
