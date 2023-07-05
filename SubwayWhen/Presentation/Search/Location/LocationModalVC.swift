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

class LocationModalVC: ModalVCCustom {
    let viewModel: LocationModalViewModel
    
    private let modalCompletion =  PublishSubject<Void>()
    private let didDisappear = PublishSubject<Void>()
    private let bag = DisposeBag()
    
    init(modalHeight: CGFloat, btnTitle: String, mainTitle: String, subTitle: String, viewModel: LocationModalViewModel) {
        self.viewModel = viewModel
        super.init(modalHeight: modalHeight, btnTitle: btnTitle, mainTitle: mainTitle, subTitle: subTitle)
        self.attribute()
        self.bind()
        self.layout()
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
    }
}

extension Reactive where Base: LocationModalVC {
    var modalDismiss: Binder<Void> {
        return Binder(base) { base, _ in
            base.modalDismiss()
        }
    }
}
