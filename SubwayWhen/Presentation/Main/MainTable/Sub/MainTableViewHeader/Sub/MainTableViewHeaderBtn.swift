//
//  MainTableViewHeaderBtn.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/08.
//

import UIKit

import Then
import SnapKit

import Lottie

class MainTableViewHeaderBtn : ModalCustomButton{
    let btnLabel = UILabel().then{
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.largeSize)
    }
    
    let btnImg : LottieAnimationView
    
    init(title : String, img : String){
        self.btnImg = LottieAnimationView(name: img)
        super.init(bgColor: UIColor(named: "MainColor") ?? .gray, customTappedBG: nil)
        self.layout()
        self.attribute(title : title, img: img)
        self.iconAnimationPlay()
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
            $0.size.equalTo(50)
        }
    }
    
    private func attribute(title : String, img : String){
        self.tintColor = .gray
        self.btnLabel.text = title
    }
    
    func iconAnimationPlay(){
        self.btnImg.stop()
        self.btnImg.play()
    }
}
