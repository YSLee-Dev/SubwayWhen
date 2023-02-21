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
    
    var handBar = UIView().then{
        $0.backgroundColor = .gray.withAlphaComponent(0.7)
        $0.layer.cornerRadius = 2.5
    }
    
    private var moveTranslation : CGPoint = CGPoint(x: 0, y: 0)
    private var moveVelocity : CGPoint = CGPoint(x: 0, y: 0)
    
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
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ModalVCCustom{
    private func attribute(){
        self.view.backgroundColor = .clear
        self.mainBG.transform = CGAffineTransform(translationX: 0, y: self.modalHeight)
        
        self.mainBG.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.gestureAction(_ :))))
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        
        self.mainBG.addSubview(self.handBar)
        self.handBar.snp.makeConstraints{
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(50)
            $0.height.equalTo(5)
        }
    }
    
    private func viewAnimation(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.75){[weak self] in
            self?.mainBG.transform = .identity
            self?.grayBG.backgroundColor = .gray.withAlphaComponent(0.5)
        }
    }
    
    @objc
    func modalDismiss(){
        UIView.animate(withDuration: 0.25, delay: 0, animations: {
            self.mainBG.transform = CGAffineTransform(translationX: 0, y: self.modalHeight)
            self.grayBG.backgroundColor = .clear
        }, completion: {_ in
            self.dismiss(animated: false)
        })
    }
    
    
    @objc
    private func keyboardWillShow(_ sender: Notification) {
        let userInfo:NSDictionary = sender.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height - 15
        
        self.grayBG.snp.updateConstraints{
            $0.bottom.equalToSuperview().inset(keyboardHeight)
        }
        UIView.animate(withDuration: 0.25){[weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func keyboardWillHide(_ sender: Notification) {
        self.grayBG.snp.updateConstraints{
            $0.bottom.equalToSuperview().inset(0)
        }
        UIView.animate(withDuration: 0.25){[weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func grayBGClickModalDismiss(_ sender:Any){
        self.modalDismiss()
    }
    
    @objc
    private func gestureAction(_ sender : UIPanGestureRecognizer){
        self.moveTranslation = sender.translation(in: self.mainBG)
        self.moveVelocity = sender.velocity(in: self.mainBG)
        
        switch sender.state{
        case .ended:
            if self.moveTranslation.y > 75 {
                self.modalDismiss()
            }else{
                self.mainBG.snp.updateConstraints{
                    $0.height.equalTo(self.modalHeight)
                }
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.75){
                    self.view.layoutIfNeeded()
                }
            }
        case .changed:
            if self.moveTranslation.y > 0 || self.moveVelocity.y > 0{
                self.mainBG.snp.updateConstraints{
                    $0.height.equalTo(self.modalHeight - self.moveTranslation.y)
                }
            }else{
                self.mainBG.snp.updateConstraints{
                    $0.height.equalTo(self.modalHeight + -(self.moveTranslation.y))
                }
            }
            
            UIView.animate(withDuration: 0.125){
                self.view.layoutIfNeeded()
            }
        case .cancelled:
            self.mainBG.snp.updateConstraints{
                $0.height.equalTo(self.modalHeight)
            }
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.75){
                self.view.layoutIfNeeded()
            }
        default:
            break
        }
    }
}
