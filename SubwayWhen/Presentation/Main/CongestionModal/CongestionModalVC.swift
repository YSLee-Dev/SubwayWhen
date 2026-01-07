//
//  CongestionModalVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 1/6/26.
//

import UIKit

import SwiftUI
import SnapKit
import ComposableArchitecture

class CongestionModalVC : ModalVCCustom {
    
    // MARK: - Properties
    
    private let modalView: CongestionModalView
    
    // MARK: - LifeCycle
    
    init(store: StoreOf<CongestionModalFeature>) {
        self.modalView = CongestionModalView(store: store)
        super.init(modalHeight: 500, btnTitle: Strings.Common.close, mainTitle: "mainTitle", subTitle: "subTitle")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.layout()
    }
}

// MARK: - Methods

private extension CongestionModalVC {
    func layout() {
        let modalSwiftUIView = UIHostingController(rootView: self.modalView)
        let modalView = modalSwiftUIView.view!
        
        self.addChild(modalSwiftUIView)
        self.mainBG.addSubview(modalView)
        modalView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.top.equalTo(self.subTitle.snp.bottom).offset(20)
            $0.bottom.equalTo(self.okBtn!.snp.top).offset(-10)
        }
    }
}
