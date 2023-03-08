//
//  ReportContentsModalColletionViewCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/07.
//

import UIKit

import SnapKit
import Then

class ReportContentsModalColletionViewCell : UICollectionViewCell{
    let mainBG = MainStyleUIView()
    
    let titleLabel = UILabel().then{
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.smallSize)
        $0.textAlignment = .center
        $0.textColor = .gray
    }
    
    let icon = UIImageView().then{
        $0.contentMode = .scaleToFill
        $0.tintColor = .gray
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ReportContentsModalColletionViewCell {
    private func layout(){
        self.contentView.addSubview(self.mainBG)
        self.mainBG.snp.makeConstraints{
            $0.edges.equalToSuperview()
            
        }
        [self.titleLabel, self.icon]
            .forEach{
                self.mainBG.addSubview($0)
            }
        
        self.icon.snp.makeConstraints{
            $0.size.equalTo(40)
            $0.top.equalToSuperview().inset(10)
            $0.centerX.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(10)
        }
    }
    
    func cellSet(text: String, iconImg : UIImage){
        self.titleLabel.text = text
        self.icon.image = iconImg
    }
}