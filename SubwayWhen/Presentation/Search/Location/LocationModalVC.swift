//
//  LocationModalVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/07/05.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

import Then
import SnapKit
import Lottie

class LocationModalVC: ModalVCCustom {
    var animationIcon : LottieAnimationView?
    
    let viewModel: LocationModalViewModel
    
    private let modalCompletion =  PublishSubject<Void>()
    private let didDisappear = PublishSubject<Void>()
    private let bag = DisposeBag()
    
    init(modalHeight: CGFloat, btnTitle: String, mainTitle: String, subTitle: String, viewModel: LocationModalViewModel) {
        self.viewModel = viewModel
        super.init(modalHeight: modalHeight, btnTitle: btnTitle, mainTitle: mainTitle, subTitle: subTitle)
        self.attribute()
        self.bind()
    }
    
    deinit {
        print("LocationModalVC DEINIT")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.didDisappear.onNext(Void())
    }
    
    override func modalDismiss() {
        UIView.animate(withDuration: 0.25, delay: 0, animations: {
            self.mainBG.transform = CGAffineTransform(translationX: 0, y: self.modalHeight)
            self.mainBGContainer.transform = CGAffineTransform(translationX: 0, y: self.modalHeight)
            self.grayBG.backgroundColor = .clear
        }, completion: { _ in
            self.modalCompletion.onNext(Void())
        })
    }
}

private extension LocationModalVC {
    func attribute() {
        
    }
    
    func layout() {
        
    }
    
    func bind() {
        guard let okBtn = self.okBtn else {return}
        
        let input = LocationModalViewModel.Input(
            modalCompletion: self.modalCompletion.asObservable(),
            okBtnTap: okBtn.rx.tap.asObservable(),
            didDisappear: self.didDisappear.asObservable()
        )
        
        let output = self.viewModel.transform(input: input)
        
        output.modalDismissAnimation
            .drive(self.rx.modalDismiss)
            .disposed(by: self.bag)
        
        output.locationAuthStatus
            .drive(self.rx.authSwitch)
            .disposed(by: self.bag)
    }
    
    func iconLayout(){
        self.animationIcon = LottieAnimationView(name: "Report")
        guard let animationIcon = self.animationIcon else {return}
        
        self.mainBG.addSubview(animationIcon)
        animationIcon.snp.makeConstraints{
            $0.size.equalTo(100)
            $0.top.equalTo(self.subTitle.snp.bottom).offset(100)
            $0.centerX.equalToSuperview()
        }
    }
    
    func animationStart() {
        guard let animationIcon = self.animationIcon else {return}
        
        animationIcon.animationSpeed = 2
        animationIcon.play()
    }
}

extension Reactive where Base: LocationModalVC {
    var modalDismiss: Binder<Void> {
        return Binder(base) { base, _ in
            base.modalDismiss()
        }
    }
    
    var authSwitch: Binder<Bool>{
        return Binder(base){ base, bool in
            if bool{
                base.layout()
            }else{
                base.iconLayout()
                base.animationStart()
                base.subTitle.text = "위치 권한이 설정되어 있지 않아요."
                base.okBtn?.titleLabel?.text = "닫기"
            }
        }
    }
}
