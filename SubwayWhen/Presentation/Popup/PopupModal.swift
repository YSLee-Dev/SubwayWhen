//
//  PopupModal.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/27.
//

import UIKit

import Then
import SnapKit
import Lottie

class PopupModal : ModalVCCustom{
    let type : PopupType
    var isUpdate : Bool = true
    
    lazy var textView = UITextView().then{
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.mediumSize)
        $0.layer.cornerRadius = 15
        $0.backgroundColor = UIColor(named: "MainColor")
        $0.textColor = .label
        $0.isEditable = false
        $0.isSelectable = false
    }
    
    lazy var animationIcon = LottieAnimationView()
    lazy var congratulationsIcon = LottieAnimationView()
    
    init(modalHeight: CGFloat, popupTitle : String, subTitle : String, popupValue : String) {
        self.type = .TextView
        super.init(modalHeight: modalHeight, btnTitle: "확인", mainTitle: popupTitle, subTitle: subTitle)
        self.textView.text = popupValue
    }
    
    init(modalHeight: CGFloat, popupTitle : String, subTitle : String, iconName : String, congratulations: Bool){
        self.type = .SuccessIcon
        super.init(modalHeight: modalHeight, btnTitle: "확인", mainTitle: popupTitle, subTitle: subTitle)
        self.animationIcon = LottieAnimationView(name: iconName)
        self.congratulationsIcon = LottieAnimationView(name: "Congratulations")
    }
    
    init(modalHeight: CGFloat, popupTitle : String, subTitle : String, iconName : String, isUpdate : Bool){
        self.type = .Update
        self.isUpdate = false
        super.init(modalHeight: modalHeight, btnTitle: "확인", mainTitle: popupTitle, subTitle: subTitle)
        self.animationIcon = LottieAnimationView(name: iconName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        print("PopupModal DEINIT")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attribute()
        
        switch self.type{
        case .SuccessIcon:
            self.iconLayout()
            self.iconAnimationPlay()
            
            self.congratulationsIconLayout()
            self.congratulationsIcon.play()
            self.congratulationsIconAttribute()
            
        case .TextView:
            self.textViewlayout()
            
        case .Update:
            self.iconLayout()
            self.iconAnimationPlay()
        }
    }
    
    override func modalDismiss() {
        if self.isUpdate{
            super.modalDismiss()
        }else{
            self.appstoreLink()
        }
    }
}

private extension PopupModal {
    func attribute(){
        if self.isUpdate{
            self.okBtn?.addTarget(self, action: #selector(self.modalDismiss), for: .touchUpInside)
        }else{
            self.okBtn?.addTarget(self, action: #selector(self.appstoreLink), for: .touchUpInside)
        }
    }
    
    func textViewlayout(){
        self.mainBG.addSubview(self.textView)
        self.textView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.top.equalTo(self.subTitle.snp.bottom).offset(10)
            $0.bottom.equalTo(self.okBtn!.snp.top).offset(-10)
        }
    }
    
    func iconAnimationPlay(){
        self.animationIcon.animationSpeed = 2
        self.animationIcon.play()
    }
    
    func iconLayout(){
        self.mainBG.addSubview(self.animationIcon)
        self.animationIcon.snp.makeConstraints{
            $0.size.equalTo(100)
            $0.top.equalTo(self.subTitle.snp.bottom).offset(50)
            $0.centerX.equalToSuperview()
        }
    }
    
    func congratulationsIconLayout() {
        self.grayBG.addSubview(self.congratulationsIcon)
        self.congratulationsIcon.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.mainBG.snp.top)
        }
    }
    
    func congratulationsIconAttribute() {
        let tapGestrue = UITapGestureRecognizer(target: self, action: #selector(self.congratulationsIconTap(_:)))
        self.congratulationsIcon.addGestureRecognizer(tapGestrue)
    }
    
    @objc
    func appstoreLink(){
        guard let url = URL(string: "https://itunes.apple.com/app/id6446166573") else {return}
        UIApplication.shared.open(url)
    }
    
    @objc
    func congratulationsIconTap(_ sender: Any) {
        self.modalDismiss()
    }
}
