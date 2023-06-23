//
//  SettingNotiSelectModalVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/06/21.
//

import UIKit

import SnapKit

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
    }
    
    deinit {
        print("SettingNotiSelectModalVC DEINIT")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attribute()
        self.layout()
        self.bind()
        self.animation()
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
        self.view.backgroundColor = .lightGray
        self.topView.layer.cornerRadius = ViewStyle.Layer.radius
        
        [self.topView, self.tableView]
            .forEach{
                $0.transform = CGAffineTransform(translationX: 0, y: 250)
            }
        
    }
    
    func layout() {
        self.topView.snp.remakeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide).inset(40)
            $0.height.equalTo(60)
        }
        
        self.tableView.snp.remakeConstraints{
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(self.topView.snp.bottom).offset(-15)
        }
    }
    
    func animation() {
        UIView.animate(withDuration: 0.25, animations: {
            [self.topView, self.tableView]
                .forEach{
                    $0.transform = .identity
                }
        })
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
