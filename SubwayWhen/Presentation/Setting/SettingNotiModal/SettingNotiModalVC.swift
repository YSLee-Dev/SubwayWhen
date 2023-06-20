//
//  SettingNotiModalVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/20.
//

import UIKit

import Then
import SnapKit
import Lottie

import RxSwift
import RxCocoa

class SettingNotiModalVC: ModalVCCustom {
    let bag = DisposeBag()
    var animationIcon : LottieAnimationView?
    var viewModel: SettingNotiModalViewModel
    
    init(modalHeight: CGFloat, btnTitle: String, mainTitle: String, subTitle: String, viewModel: SettingNotiModalViewModel) {
        self.viewModel = viewModel
        super.init(modalHeight: modalHeight, btnTitle: btnTitle, mainTitle: mainTitle, subTitle: subTitle)
        self.attribute()
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SettingNotiModalVC {
    private func attribute() {
        self.okBtn!.addTarget(self, action: #selector(self.modalDismiss), for: .touchUpInside)
    }
    
    func layout() {
        
    }
    
    private func bind() {
        let input = SettingNotiModalViewModel.Input()
        let output =  self.viewModel.transform(input: input)
        
        output.authSuccess
            .drive(self.rx.authSwitch)
            .disposed(by: self.bag)
    }
    
    func iconLayout(){
        self.animationIcon = LottieAnimationView(name: "Report")
        guard let animationIcon = self.animationIcon else {return}
        
        self.mainBG.addSubview(animationIcon)
        animationIcon.snp.makeConstraints{
            $0.size.equalTo(100)
            $0.top.equalTo(self.subTitle.snp.bottom).offset(50)
            $0.centerX.equalToSuperview()
        }
    }
    
    func animationStart() {
        guard let animationIcon = self.animationIcon else {return}
        
        animationIcon.animationSpeed = 2
        animationIcon.play()
    }
    
}

extension Reactive where Base: SettingNotiModalVC {
    var authSwitch: Binder<Bool>{
        return Binder(base){ base, bool in
            if bool{
                base.layout()
            }else{
                base.iconLayout()
                base.animationStart()
                base.subTitle.text = "알림 권한이 설정되어 있지 않아요."
            }
        }
    }
}
