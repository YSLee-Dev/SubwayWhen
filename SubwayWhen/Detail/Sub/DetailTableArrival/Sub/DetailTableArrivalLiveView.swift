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
        $0.alpha = 0
    }
    
    var moreStationCircle = UIView().then{
        $0.layer.cornerRadius = 7.5
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1
    }
    
    var moreStationTitle = UILabel().then{
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.smallSize)
        $0.textAlignment = .right
        $0.alpha = 0
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
    
    func liveViewReset(){
        self.animateCGSet(false)
        self.beforeStationTitle.alpha = 0
    }
    
    func trainIconSet(code : String, now : String){
        guard let intCode = Int(code) else {return}
        
        UIView.animate(withDuration: 0.25, delay: 0, options: [.allowUserInteraction]){
            [self.moreStationTitle, self.trainIcon]
                .forEach{
                    $0.alpha = 0
                }
            
            self.beforeStationCirecle.alpha = 1
            self.moreStationTitle.text = now
        }
        
        if 0...5 ~= intCode{
            UIView.animate(withDuration: 0.75, delay: 0, options: [.allowUserInteraction], animations: {
                self.animateCGSet(true)
                self.beforeStationTitle.alpha = 0
                self.moreStationTitle.text = self.beforeTitle
            }, completion:{ _ in
                self.animateCGSet(false)
                self.beforeStationCirecle.alpha = 0
            })
            UIView.animate(withDuration: 0.25, delay: 0.75, options: [.allowUserInteraction], animations: {
                self.moreStationTitle.alpha = 1
                self.trainIcon.alpha = 1
            })
            
        }else{
            self.animateCGSet(true)
            
            self.beforeStationTitle.text = self.beforeTitle
            
            UIView.animate(withDuration: 0.75, delay: 0, options: [.allowUserInteraction], animations: {
                self.beforeStationCirecle.alpha = 1
                self.animateCGSet(false)
                
            }, completion: { _ in
                UIView.animate(withDuration: 0.25, delay: 0){
                    self.moreStationTitle.alpha = 1
                    self.trainIcon.alpha = 1
                    self.beforeStationTitle.alpha = 1
                }
            })
            
        }
        
        let cellWidth = self.frame.width - 40
        self.trainIcon.transform = .identity
        
        UIView.animate(withDuration: 0.5, delay: 0.75, options: [.allowUserInteraction], animations: {
            switch intCode{
            case 0:
                self.trainIcon.transform = CGAffineTransform(translationX:(-(cellWidth) + 15), y: 0)
            case 1:
                self.trainIcon.transform = CGAffineTransform(translationX: -(cellWidth), y: 0)
            case 2:
                self.trainIcon.transform = CGAffineTransform(translationX:(-(cellWidth) - 15), y: 0)
            case 3:
                self.trainIcon.transform = CGAffineTransform(translationX:(-(cellWidth)/2), y: 0)
            case 4:
                self.trainIcon.transform = CGAffineTransform(translationX: 10, y: 0)
            case 5:
                self.trainIcon.transform = .identity
            case 99:
                self.trainIcon.transform = .identity
            default:
                break
            }
        })
    }
    private func animateCGSet(_ isStart : Bool){
        if isStart{
            [self.moreStationCircle, self.moreStationTitle]
                .forEach{
                    $0.transform = CGAffineTransform(translationX: 30, y: 0)
                }
            
            self.beforeStationCirecle.transform = CGAffineTransform(translationX: ((self.border.frame.width / 4) * 3) + 10, y: 0)
            self.border.transform = CGAffineTransform(scaleX: 1.2, y: 1.0).concatenating(CGAffineTransform(translationX: 30, y: 0))
        }else{
            [self.beforeStationCirecle, self.moreStationCircle, self.moreStationTitle, self.border]
                .forEach{
                    $0.transform = .identity
                }
        }
    }
}
