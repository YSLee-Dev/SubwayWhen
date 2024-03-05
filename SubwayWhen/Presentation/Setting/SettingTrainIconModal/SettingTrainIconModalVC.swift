//
//  SettingTrainIconModalVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2/9/24.
//

import UIKit

import Then
import SnapKit
import SwiftUI

import RxSwift
import RxCocoa

class SettingTrainIconModalVC: ModalVCCustom {
    private let settingModalView: SettingTrainIconModalView
    
    private let viewModel: SettingTrainIconModalViewModel
    private let viewAction = PublishRelay<SettingTrainIconModalAction>()
    private let bag = DisposeBag()
    
    init(modalHeight: CGFloat, btnTitle: String, mainTitle: String, subTitle: String, viewModel: SettingTrainIconModalViewModel, modalView: SettingTrainIconModalView) {
        self.viewModel = viewModel
        self.settingModalView = modalView
        
        super.init(modalHeight: modalHeight, btnTitle: btnTitle, mainTitle: mainTitle, subTitle: subTitle)
    }
    
    deinit {
        print("SettingTrainIconModalVC DEINIT")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.layout()
        self.bind()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.viewAction.accept(.viewDidDisappear)
    }
    
    override func modalDismiss() {
        UIView.animate(withDuration: 0.25, delay: 0, animations: {
            self.mainBG.transform = CGAffineTransform(translationX: 0, y: self.modalHeight)
            self.mainBGContainer.transform = CGAffineTransform(translationX: 0, y: self.modalHeight)
            self.grayBG.backgroundColor = .clear
        }, completion: { [weak self] _ in
            self?.viewAction.accept(.closeBtnTap)
        })
    }
}

private extension SettingTrainIconModalVC {
    func layout() {
        let settingSwiftUIVC = UIHostingController(rootView: self.settingModalView)
        let settingModalView = settingSwiftUIVC.view!
        
        self.addChild(settingSwiftUIVC)
        self.mainBG.addSubview(settingModalView)
        settingModalView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.top.equalTo(self.subTitle.snp.bottom).offset(20)
            $0.bottom.equalTo(self.okBtn!.snp.top).offset(-10)
        }
    }
    
    func bind() {
        self.okBtn!.rx.tap
            .do(onNext: { [weak self] in
                self?.modalDismiss()
            })
            .map { _ in
                .okBtnTap
            }
            .bind(to: self.viewAction)
            .disposed(by: self.bag)
        
        let input = SettingTrainIconModalViewModel.Input(
            actionList: self.viewAction
                .asObservable()
        )
        let _ = self.viewModel.transform(input: input)
    }
}
