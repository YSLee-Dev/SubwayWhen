//
//  PopupModal.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/27.
//

import UIKit

class PopupModal : ModalVCCustom{
    let textView = UITextView().then{
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.mediumSize)
        $0.layer.cornerRadius = 15
        $0.backgroundColor = UIColor(named: "MainColor")
        $0.textColor = .label
    }
    
    init(modalHeight: CGFloat, popupTitle : String, subTitle : String,popupValue : String) {
        super.init(modalHeight: modalHeight, btnTitle: "확인", mainTitle: popupTitle, subTitle: subTitle)
        self.textView.text = popupValue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        print("PopupModal DEINIT")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.layout()
        self.attribute()
    }
}

extension PopupModal {
    private func attribute(){
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
}
