//
//  DetailTableArrivalLiveView.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/01/31.
//

import UIKit

import SnapKit
import Then

class DetailTableArrivalLiveView : MainStyleUIView{
    var beforeTitle = ""
    
    var border = UIView()
    
    var nowStationCirecle = UIView().then{
        $0.layer.cornerRadius = 7.5
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1
    }
    
    var nowStationTitle = UILabel().then{
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.smallSize)
        $0.textAlignment = .left
    }
    
    var beforeStationCirecle = UIView().then{
        $0.layer.cornerRadius = 7.5
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1
    }
    
    var beforeStationTitle = UILabel().then{
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.smallSize)
        $0.textAlignment = .right
    }
    
    var moreStationCircle = UIView().then{
        $0.layer.cornerRadius = 7.5
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1
    }
    
    var moreStationTitle = UILabel().then{
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.smallSize)
        $0.textAlignment = .right
    }
    
    var trainIcon = UILabel().then{
        $0.text = "🚃"
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.mainTitleSize)
        $0.alpha = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DetailTableArrivalLiveView{
    private func layout(){
        [self.border, self.nowStationCirecle, self.beforeStationCirecle, self.nowStationTitle, self.beforeStationTitle, self.trainIcon, self.moreStationTitle, self.moreStationCircle]
            .forEach{
                self.addSubview($0)
            }
        
        self.border.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(5)
            $0.centerY.equalToSuperview().offset(-6.5)
        }
        
        self.nowStationCirecle.snp.makeConstraints{
            $0.size.equalTo(15)
            $0.centerY.equalTo(self.border)
            $0.centerX.equalTo(self.border.snp.leading)
        }
        
        self.nowStationTitle.snp.makeConstraints{
            $0.leading.equalTo(self.nowStationCirecle)
            $0.trailing.equalTo(self.beforeStationTitle.snp.leading)
            $0.top.equalTo(self.nowStationCirecle.snp.bottom).offset(5)
        }
        
        self.beforeStationCirecle.snp.makeConstraints{
            $0.size.equalTo(15)
            $0.centerY.equalTo(self.border)
            $0.centerX.equalTo(self.border.snp.centerX).multipliedBy(0.5)
        }
        
        self.beforeStationTitle.snp.makeConstraints{
            $0.top.equalTo(self.beforeStationCirecle.snp.bottom).offset(5)
            $0.leading.equalTo(self.beforeStationCirecle.snp.leading)
        }
        
        self.moreStationCircle.snp.makeConstraints{
            $0.size.equalTo(15)
            $0.centerY.equalTo(self.border)
            $0.centerX.equalTo(self.border.snp.trailing)
        }
        
        self.moreStationTitle.snp.makeConstraints{
            $0.trailing.equalTo(self.moreStationCircle)
            $0.top.equalTo(self.beforeStationCirecle.snp.bottom).offset(5)
        }
        
        self.trainIcon.snp.makeConstraints{
            $0.bottom.equalTo(self.border.snp.top).offset(5)
            $0.centerX.equalTo(self.moreStationCircle.snp.centerX)
        }
    }
    
    func viewSet(_ data : DetailTableViewCellData){
        self.border.backgroundColor = UIColor(named: data.lineNumber)
        self.nowStationCirecle.layer.borderColor = UIColor(named: data.lineNumber)?.cgColor
        self.beforeStationCirecle.layer.borderColor = UIColor(named: data.lineNumber)?.cgColor
        self.moreStationCircle.layer.borderColor = UIColor(named: data.lineNumber)?.cgColor
        
        self.nowStationTitle.text = data.stationName
        self.beforeTitle = data.backStationName
    }
    
    func trainIconSet(code : String, now : String){
        guard let intCode = Int(code) else {return}
        
        self.moreStationTitle.text = now
        self.trainIcon.alpha = 1
        
        if 0...5 ~= intCode{
            [self.beforeStationTitle, self.beforeStationCirecle]
                .forEach{
                    $0.isHidden = true
                }
            
            self.moreStationTitle.text = self.beforeTitle
            
        }else{
            [self.beforeStationTitle, self.beforeStationCirecle]
                .forEach{
                    $0.isHidden = false
                }
            
            self.beforeStationTitle.text = self.beforeTitle
            self.moreStationTitle.text = now
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: [.allowUserInteraction]){
            switch intCode{
            case 0:
                self.trainIcon.transform = CGAffineTransform(translationX:(-(self.border.frame.width) + 10), y: 0)
            case 1:
                self.trainIcon.transform = CGAffineTransform(translationX: -(self.border.frame.width), y: 0)
            case 2:
                self.trainIcon.transform = CGAffineTransform(translationX:(-(self.border.frame.width) - 10), y: 0)
            case 3:
                self.trainIcon.transform = CGAffineTransform(translationX:(-(self.border.frame.width)/2), y: 0)
            case 4:
                self.trainIcon.transform = CGAffineTransform(translationX: 10, y: 0)
            case 5:
                self.trainIcon.transform = .identity
            case 99:
                self.trainIcon.transform = .identity
            default:
                break
            }
        }
    }
}
