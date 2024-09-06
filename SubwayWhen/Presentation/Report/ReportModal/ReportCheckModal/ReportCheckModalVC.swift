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
    }
    
    lazy var successIcon =  LottieAnimationView(name: "CheckMark")
    
    let checkModalViewModel : ReportCheckModalViewModel
    var msgVC = MFMessageComposeViewController()
    
    var status : Bool = false
    
    let bag = DisposeBag()
    
    init(modalHeight: CGFloat, viewModel : ReportCheckModalViewModel) {
        self.checkModalViewModel = viewModel
        super.init(modalHeight: modalHeight, btnTitle: "접수", mainTitle: "지하철 민원", subTitle: "하단의 내용으로 민원을 접수할까요?\n민원내용은 화면을 눌러 수정할 수 있어요.")
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
            $0.bottom.equalTo(self.okBtn!.snp.top).offset(-10)
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
        
        viewModel.msg
            .filter {$0.count >= 70}
            .map {($0, true)}
            .drive(self.rx.msgLengthCheck)
            .disposed(by: self.bag)
        
        // VIEW - > VIEWMODEL
        self.okBtn!.rx.tap
            .withLatestFrom(self.textView.rx.text)
            .filter {$0 != nil}
            .map {$0!}
            .bind(to: viewModel.okBtnClick)
            .disposed(by: self.bag)
        
        self.textView.rx.text
            .skip(1) // 초기 기본 값
            .filter {$0 != nil}
            .map {($0!, false)}
            .bind(to: self.rx.msgLengthCheck)
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
        self.okBtn!.removeFromSuperview()
        self.mainTitle.text = "민원접수가 완료되었어요."
        self.subTitle.text = "본앱에서의 민원접수는 문자메세지로의 접수를 도와주는 기능이에요."
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
    
    var msgLengthCheck: Binder<(String, Bool)> {
        return Binder(base) { base, value in
            if value.0.count >= 70 {
                base.subTitle.text = "현재 글자 수(\(value.0.count))가 길어 해당 기관에 메세지가 전달되지 않을 수 있어요.\n메세지를 편집하여 메세지를 보내주세요."
                base.textView.isEditable = true
                
                if value.1 {
                    base.textView.becomeFirstResponder()
                }
            } else {
                base.subTitle.text = "하단의 내용으로 민원을 접수할까요?"
            }
        }
    }
}
