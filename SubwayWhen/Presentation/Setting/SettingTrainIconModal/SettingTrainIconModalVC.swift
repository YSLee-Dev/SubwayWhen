//
//  SettingTrainIconModalVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2/9/24.
//

import UIKit

import Then
import SnapKit

import RxSwift
import RxCocoa

class SettingTrainIconModalVC: ModalVCCustom {
    private let viewModel: SettingTrainIconModalViewModel
    private let viewAction = PublishRelay<SettingTrainIconModalAction>()
    private let bag = DisposeBag()
    
    init(modalHeight: CGFloat, btnTitle: String, mainTitle: String, subTitle: String, viewModel: SettingTrainIconModalViewModel) {
        self.viewModel = viewModel
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
    func bind() {
        let input = SettingTrainIconModalViewModel.Input(
            actionList: self.viewAction
                .asObservable()
        )
        let output = self.viewModel.transform(input: input)
    }
}
