//
//  ReportCheckModalVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/21.
//

import UIKit

import RxSwift
import RxCocoa

import MessageUI
import Lottie

class ReportCheckModalVC : ModalVCCustom{
    let textView = UITextView().then{
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.smallSize)
        $0.layer.cornerRadius = 15
        $0.backgroundColor = UIColor(named: "MainColor")
        $0.textColor = .label
        $0.isEditable = false
    }
    
    lazy var successIcon =  LottieAnimationView(name: "CheckMark")
    
    let checkModalViewModel : ReportCheckModalViewModel
    var msgVC = MFMessageComposeViewController()
    
    var status : Bool = false
    
    let bag = DisposeBag()
    
    init(modalHeight: CGFloat, viewModel : ReportCheckModalViewModel) {
        self.checkModalViewModel = viewModel
        super.init(modalHeight: modalHeight, btnTitle: "접수", mainTitle: "지하철 민원", subTitle: "하단 내용으로 민원을 접수할까요?")
        self.bind(self.checkModalViewModel)
    }
    
    deinit{
        print("ReportCheckModalVC DEINIT")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attribute()
        self.layout()
    }
}

extension ReportCheckModalVC {
    private func attribute(){
        self.msgVC.messageComposeDelegate = self
    }
    
    private func layout(){
        self.mainBG.addSubview(self.textView)
        self.textView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.top.equalTo(self.subTitle.snp.bottom).offset(10)
            $0.bottom.equalTo(self.okBtn.snp.top).offset(-10)
        }
    }
    
    private func bind(_ viewModel : ReportCheckModalViewModel){
        // VIEWMODEL -> VIEW
        viewModel.msg
            .drive(self.rx.contentsSet)
            .disposed(by: self.bag)
        
        viewModel.number
            .drive(self.rx.msgVCPresent)
            .disposed(by: self.bag)
        
        // VIEW - > VIEWMODEL
        self.okBtn.rx.tap
            .bind(to: viewModel.okBtnClick)
            .disposed(by: self.bag)
    }
    
    override func modalDismiss() {
        if self.status {
            self.checkModalViewModel.msgSeedDismiss.accept(Void())
        }
        super.modalDismiss()
    }
    
    private func successIconSet(){
        self.mainBG.addSubview(self.successIcon)
        self.successIcon.snp.makeConstraints{
            $0.center.equalToSuperview()
            $0.size.equalTo(100)
        }
        
        self.successIcon.animationSpeed = 2.5
        
        self.successIcon.play()
    }
    
    func msgSendSuccess(){
        self.textView.removeFromSuperview()
        self.okBtn.removeFromSuperview()
        self.mainTitle.text = "민원접수가 완료되었어요."
        self.subTitle.text = "본앱에서의 민원접수는 문자메세지로의 접수를 도와주는 기능이에요.\n민원결과 및 처리내용은 문자메세지로 확인할 수 있어요."
        self.subTitle.textColor = .systemRed
        
        // success icon
        self.successIconSet()
        
        // Status
        self.status = true
    }
}

extension ReportCheckModalVC : MFMessageComposeViewControllerDelegate{
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result{
        case .sent:
            dismiss(animated: true){[weak self] in
                self?.msgSendSuccess()
            }
        case .cancelled:
            dismiss(animated: true){[weak self] in
                self?.msgVC = MFMessageComposeViewController()
                self?.msgVC.messageComposeDelegate = self
            }
        case .failed:
            dismiss(animated: true){[weak self] in
                self?.msgVC = MFMessageComposeViewController()
                self?.msgVC.messageComposeDelegate = self
            }
        default:
            print("Error")
            break
        }
    }
}

extension Reactive where Base : ReportCheckModalVC{
    var contentsSet : Binder<String>{
        return Binder(base){base, text in
            base.textView.text = text
        }
    }
    
    var msgVCPresent : Binder<String>{
        return Binder(base){base, number in
            base.msgVC.recipients = [number]
            base.msgVC.body = base.textView.text
            
            print(number)
            
            #if DEBUG
            base.msgSendSuccess()
            #else
            base.present(base.msgVC, animated: true)
            #endif
        }
    }
}
