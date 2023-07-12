//
//  SettingNotiModalExplanationView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/29.
//

import UIKit

import SnapKit
import Then

class SettingNotiModalExplanationView : UIView{
    let titleLabel = UILabel().then{
        $0.text = "특정 그룹 시간이 0시로 설정되어 있으면 알림이 울리지 않아요."
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.smallSize)
        $0.textColor = .white
        $0.adjustsFontSizeToFitWidth = true
    }
    
    let goBtn = ModalSubCustomButton().then{
        $0.setTitle("수정하기", for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: ViewStyle.FontSize.superSmallSize)
        $0.backgroundColor = .systemRed.withAlphaComponent(0.7)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layout()
        self.attribute()
        self.hiddenAnimation()
    }
    
    deinit {
        print("SettingNotiModalExplanationView DEINIT")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SettingNotiModalExplanationView{
    private func layout(){
        self.addSubview(self.goBtn)
        self.goBtn.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12.5)
            $0.width.equalTo(60)
            $0.height.equalTo(30)
        }
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12.5)
            $0.trailing.equalTo(self.goBtn.snp.leading).inset(-12.5)
        }
    }
    
    private func attribute(){
        self.layer.cornerRadius = ViewStyle.Layer.radius
        self.backgroundColor = UIColor(named: "AppIconColor")?.withAlphaComponent(0.9)
    }
    
    func showAnimation(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){[weak self] in
            UIView.animate(withDuration: 0.25, delay: 0){
                self?.transform = .identity
                self?.alpha = 1
            }
        }
       
    }
    
    func hiddenAnimation(){
        UIView.animate(withDuration: 0.2, delay: 0){[weak self] in
            self?.transform = CGAffineTransform(translationX: 0, y: 50)
            self?.alpha = 0
        }
    }
}

