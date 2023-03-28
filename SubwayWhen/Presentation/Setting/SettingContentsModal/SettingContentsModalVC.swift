//
//  SettingContentsModalVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/23.
//

import UIKit

import Then
import SnapKit

import RxSwift
import RxCocoa

class SettingContentsModalVC : ModalVCCustom{
    let textView = UITextView().then{
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.smallSize)
        $0.layer.cornerRadius = 15
        $0.backgroundColor = UIColor(named: "MainColor")
        $0.textColor = .label
        $0.isEditable = false
        $0.isSelectable = false
    }
    
    let bag = DisposeBag()
    let settingContentsViewModel : SettingContentsModalViewModelProtocol
    
    init(modalHeight: CGFloat, btnTitle: String, mainTitle: String, subTitle: String, viewModel : SettingContentsModalViewModelProtocol) {
        self.settingContentsViewModel = viewModel
        
        super.init(modalHeight: modalHeight, btnTitle: btnTitle, mainTitle: mainTitle, subTitle: subTitle)
        self.bind(self.settingContentsViewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attirbute()
        self.layout()
    }
}

extension SettingContentsModalVC{
    private func attirbute(){
        self.okBtn!.addTarget(self, action: #selector(self.modalDismiss), for: .touchUpInside)
    }
    
    private func layout(){
        self.mainBG.addSubview(self.textView)
        self.textView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.top.equalTo(self.subTitle.snp.bottom).offset(10)
            $0.bottom.equalTo(self.okBtn!.snp.top).offset(-10)
        }
    }
    
    func bind(_ viewModel : SettingContentsModalViewModelProtocol){
        viewModel.contents
            .drive(self.textView.rx.text)
            .disposed(by: self.bag)
    }
}
