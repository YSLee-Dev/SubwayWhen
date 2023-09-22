//
//  ModalVCCustom.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/17.
//

import UIKit

class ModalVCCustom : UIViewController{
    let modalHeight : CGFloat
    let isBtn : Bool
    
    let mainBGContainer = UIView().then{
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 25
        $0.backgroundColor = .systemBackground
    }
    
    let mainBG = UIView()
    
    lazy var grayBG = UIButton().then{
        $0.backgroundColor = .clear
        $0.addTarget(self, action: #selector(self.grayBGClickModalDismiss(_:)), for: .touchUpInside)
    }
    
    var handBar = UIView().then{
        $0.backgroundColor = .gray.withAlphaComponent(0.5)
        $0.layer.cornerRadius = 2.5
    }
    
    let mainTitle = UILabel().then{
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.mainTitleMediumSize, weight: .heavy)
        $0.textColor = .label
    }
    
    let subTitle = UILabel().then{
        $0.numberOfLines = 2
        $0.lineBreakMode = .byCharWrapping
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.smallSize)
        $0.textColor = .gray
    }
    
    var okBtn : ModalCustomButton?
    
    private var moveTranslation : CGPoint = CGPoint(x: 0, y: 0)
    private var moveVelocity : CGPoint = CGPoint(x: 0, y: 0)
    
    init(modalHeight: CGFloat, btnTitle : String, mainTitle : String, subTitle : String){
        self.modalHeight = modalHeight
        self.isBtn = btnTitle != ""
        super.init(nibName: nil, bundle: nil)
        
        self.mainTitle.text = mainTitle
        self.subTitle.text = subTitle
        
        if self.isBtn{
            self.okBtn = ModalCustomButton(bgColor: UIColor(named: "MainColor") ?? .gray, customTappedBG: nil)
            self.okBtn!.setTitle(btnTitle, for: .normal)
            self.okBtn!.setTitleColor(.label, for: .normal)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.layout(modalHeight: self.modalHeight, isBtn: self.isBtn)
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
        
        self.mainBG.transform = CGAffineTransform(translationX: 0, y: 45)
        self.mainBG.alpha = 0.7
        
        self.mainBGContainer.transform = CGAffineTransform(translationX: 0, y: self.modalHeight)
        self.mainBGContainer.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.gestureAction(_ :))))
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func layout(modalHeight: CGFloat, isBtn : Bool){
        self.view.addSubview(self.grayBG)
        self.grayBG.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
        
        self.grayBG.addSubview(self.mainBGContainer)
        self.mainBGContainer.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(modalHeight)
            $0.bottom.equalToSuperview().offset(25)
        }
        
        self.mainBGContainer.addSubview(self.handBar)
        self.handBar.snp.makeConstraints{
            $0.top.equalToSuperview().offset(5)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(40)
            $0.height.equalTo(5)
        }
        
        self.mainBGContainer.addSubview(self.mainTitle)
        self.mainTitle.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.top.equalToSuperview().inset(30)
            $0.height.equalTo(25)
        }
        
        self.mainBGContainer.addSubview(self.subTitle)
        self.subTitle.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.top.equalTo(self.mainTitle.snp.bottom)
        }
        
        self.mainBGContainer.addSubview(self.mainBG)
        self.mainBG.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
        
        if isBtn{
            self.mainBG.addSubview(self.okBtn!)
            self.okBtn!.snp.makeConstraints{
                $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
                $0.height.equalTo(50)
                $0.bottom.equalTo(self.grayBG).inset(42.5)
            }
        }
    }
    
    @objc
    func viewAnimation(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.88, initialSpringVelocity: 0.75){[weak self] in
            self?.mainBGContainer.transform = .identity
            self?.grayBG.backgroundColor = UIColor(named: "GrayBGColor")
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.15, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.75){[weak self] in
            self?.mainBG.transform = .identity
            self?.mainBG.alpha = 1
        }
    }
    
    @objc
    func modalDismiss(){
        UIView.animate(withDuration: 0.25, delay: 0, animations: {
            self.mainBG.transform = CGAffineTransform(translationX: 0, y: self.modalHeight)
            self.mainBGContainer.transform = CGAffineTransform(translationX: 0, y: self.modalHeight)
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
                self.mainBGContainer.snp.updateConstraints{
                    $0.height.equalTo(self.modalHeight)
                }
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.75){
                    self.view.layoutIfNeeded()
                }
            }
        case .changed:
            if self.moveTranslation.y > 0 || self.moveVelocity.y > 0{
                self.mainBGContainer.snp.updateConstraints{
                    $0.height.equalTo(self.modalHeight - self.moveTranslation.y)
                }
            }else{
                self.mainBGContainer.snp.updateConstraints{
                    $0.height.equalTo(self.modalHeight + -(self.moveTranslation.y))
                }
            }
            
            UIView.animate(withDuration: 0.125){
                self.view.layoutIfNeeded()
            }
        case .cancelled:
            self.mainBGContainer.snp.updateConstraints{
                $0.height.equalTo(self.modalHeight)
            }
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.75){
                self.view.layoutIfNeeded()
            }
        default:
            break
        }
    }
}
