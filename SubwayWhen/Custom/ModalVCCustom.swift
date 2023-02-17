//
//  ModalVCCustom.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/17.
//

import UIKit

class ModalVCCustom : UIViewController{
    let modalHeight : CGFloat
    
    let mainBG = UIView().then{
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 30
        $0.backgroundColor = .systemBackground
    }
    
    lazy var grayBG = UIButton().then{
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(self.grayBGClickModalDismiss(_:)), for: .touchUpInside)
    }
    
    init(modalHeight: CGFloat){
        self.modalHeight = modalHeight
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.layout(modalHeight: self.modalHeight)
        self.attribute()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewAnimation()
    }
}

extension ModalVCCustom{
    private func attribute(){
        self.view.backgroundColor = .clear
        self.mainBG.transform = CGAffineTransform(translationX: 0, y: self.modalHeight)
    }
    
    private func layout(modalHeight: CGFloat){
        self.view.addSubview(self.grayBG)
        self.grayBG.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
        
        self.grayBG.addSubview(self.mainBG)
        self.mainBG.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(modalHeight)
            $0.bottom.equalToSuperview().offset(25)
        }
    }
    
    private func viewAnimation(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.75){[weak self] in
            self?.mainBG.transform = .identity
            self?.grayBG.backgroundColor = .gray.withAlphaComponent(0.5)
        }
    }
    
    func modalDismiss(){
        UIView.animate(withDuration: 0.25, delay: 0, animations: {
            self.mainBG.transform = CGAffineTransform(translationX: 0, y: self.modalHeight)
            self.grayBG.backgroundColor = .clear
        }, completion: {_ in
            self.dismiss(animated: false)
        })
    }
    
    @objc
    private func grayBGClickModalDismiss(_ sender:Any){
        self.modalDismiss()
    }
}
