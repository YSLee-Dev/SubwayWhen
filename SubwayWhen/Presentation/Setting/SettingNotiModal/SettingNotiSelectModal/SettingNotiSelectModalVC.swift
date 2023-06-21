//
//  SettingNotiSelectModalVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/21.
//

import UIKit

import RxSwift
import RxCocoa

class SettingNotiSelectModalVC: TableVCCustom {
    let bag = DisposeBag()
    let viewModel: SettingNotiSelectModalViewModel
    
    private let didDisappearAction =  PublishSubject<Void>()
    let popAction = PublishSubject<Void>()
    
    init(
        title: String,
        titleViewHeight: CGFloat,
        viewModel: SettingNotiSelectModalViewModel
    ) {
        self.viewModel = viewModel
        super.init(title: title, titleViewHeight: titleViewHeight)
        self.attribute()
        self.bind()
    }
    
    deinit {
        print("SettingNotiSelectModalVC DEINIT")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.didDisappearAction.onNext(Void())
    }
}

private extension SettingNotiSelectModalVC {
    func attribute() {
        
    }
    
    func bind() {
        self.topView.backBtn.rx.tap
            .bind(to: self.rx.backBtnTap)
            .disposed(by: self.bag)
        
        let input = SettingNotiSelectModalViewModel.Input(
            didDisappearAction: self.didDisappearAction,
            popAction: self.popAction
        )
        
       let _ =  self.viewModel.transform(input: input)
    }
}

extension Reactive where Base: SettingNotiSelectModalVC {
    var backBtnTap: Binder<Void> {
        return Binder(base) { base, _ in
            base.popAction.onNext(Void())
        }
    }
}
