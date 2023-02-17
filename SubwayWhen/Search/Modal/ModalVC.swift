//
//  ModalVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

class ModalVC : ModalVCCustom{
    let modalViewModel : ModalViewModel
    let bag = DisposeBag()
    
    let titleLabel = UILabel().then{
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.largeSize)
    }
    
    let line = UILabel().then{
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 35
        $0.backgroundColor = UIColor(hue: 0.9333, saturation: 0.89, brightness: 0.9, alpha: 1.0)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mediumSize)
    }
    
    let upBtn = ModalCustomButton().then{
        $0.backgroundColor = .systemRed
        $0.setTitle("상행", for: .normal)
    }
    
    let downBtn = ModalCustomButton().then{
        $0.backgroundColor = .systemBlue
        $0.setTitle("하행", for: .normal)
    }
    
    let groupBtn = ModalCustomButton().then{
        $0.backgroundColor = .systemGray
        $0.setTitle("출근", for: .normal)
    }
    
    let notServiceBtn = ModalCustomButton().then{
        $0.backgroundColor = .black
        $0.setTitle("해당 노선은 서비스를 지원하지 않아요.", for: .normal)
        $0.isHidden = true
    }
    
    let exceptionLastStationTF = UITextField().then{
        $0.placeholder = "중간 종착역 제거 (1개이상 콤마 이용)"
        $0.textAlignment = .center
        $0.layer.cornerRadius = ViewStyle.Layer.shadowRadius
        $0.layer.borderColor = UIColor.systemGray.cgColor
        $0.layer.borderWidth = 0.5
        $0.layer.masksToBounds = true
        $0.font = UIFont.systemFont(ofSize: ViewStyle.FontSize.superSmallSize)
    }
    
    deinit{
        print("DEINIT MODAL")
    }
    
    init(_ viewModel : ModalViewModel, modalHeight : CGFloat){
        self.modalViewModel = viewModel
        super.init(modalHeight: modalHeight)
        self.bind(self.modalViewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attibute()
        self.layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
}

extension ModalVC{
    private func attibute(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func layout(){
        [self.titleLabel, self.line, self.upBtn, self.downBtn, self.groupBtn, self.exceptionLastStationTF, self.notServiceBtn]
            .forEach{
                self.mainBG.addSubview($0)
            }
        
        self.upBtn.snp.makeConstraints{
            $0.leading.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.bottom.equalTo(self.grayBG).inset(35)
            $0.height.equalTo(50)
            $0.trailing.equalTo(self.view.snp.centerX).offset(-5)
        }
        self.downBtn.snp.makeConstraints{
            $0.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.height.equalTo(50)
            $0.bottom.equalTo(self.grayBG).inset(35)
            $0.leading.equalTo(self.view.snp.centerX).offset(5)
        }
        self.line.snp.makeConstraints{
            $0.leading.equalTo(self.upBtn)
            $0.top.equalToSuperview().inset(30)
            $0.size.equalTo(70)
        }
        self.titleLabel.snp.makeConstraints{
            $0.leading.equalTo(self.line.snp.trailing).offset(15)
            $0.centerY.equalTo(self.line)
        }
        self.groupBtn.snp.makeConstraints{
            $0.leading.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.bottom.equalTo(self.downBtn.snp.top).inset(-10)
            $0.height.equalTo(50)
            $0.trailing.equalTo(self.view.snp.centerX).offset(-5)
        }
        self.exceptionLastStationTF.snp.makeConstraints{
            $0.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.height.equalTo(50)
            $0.bottom.equalTo(self.downBtn.snp.top).inset(-10)
            $0.leading.equalTo(self.view.snp.centerX).offset(5)
        }
        self.notServiceBtn.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.height.equalTo(50)
            $0.bottom.equalTo(self.grayBG).inset(35)
        }
        
    }
    
    private func bind(_ viewModel : ModalViewModel){
        // VIEW -> VIEWMODEL
        self.upBtn.rx.tap
            .map{
                true
            }
            .bind(to: viewModel.upDownBtnClick)
            .disposed(by: self.bag)
        
        self.downBtn.rx.tap
            .map{
                false
            }
            .bind(to: viewModel.upDownBtnClick)
            .disposed(by: self.bag)
        
        self.notServiceBtn.rx.tap.asObservable()
            .bind(to: viewModel.grayBgClick)
            .disposed(by: self.bag)
        
        self.groupBtn.rx.tap
            .map{ [weak self] _ -> SaveStationGroup in
                if self?.groupBtn.titleLabel!.text == "출근"{
                    self?.groupBtn.setTitle("퇴근", for: .normal)
                    return .two
                }else{
                    self?.groupBtn.setTitle("출근", for: .normal)
                    return .one
                }
                
            }
            .bind(to: viewModel.groupClick)
            .disposed(by: self.bag)
        
        self.exceptionLastStationTF.rx.text
            .bind(to: viewModel.exceptionLastStationText)
            .disposed(by: self.bag)
        
        // VIEW
        self.exceptionLastStationTF.rx.controlEvent(.editingDidEndOnExit)
            .bind(to: self.rx.keyboardReturnBtn)
            .disposed(by: self.bag)
        
        // VIEWMODEL -> VIEW
        viewModel.modalData
            .drive(self.rx.modalLabelSet)
            .disposed(by: self.bag)
        
        viewModel.modalClose
            .drive(self.rx.modalClose)
            .disposed(by: self.bag)
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
    
}

extension Reactive where Base : ModalVC{
    var modalLabelSet : Binder<ResultVCCellData>{
        return Binder(base){ base, info in
            base.line.text = info.useLine
            base.line.backgroundColor = UIColor(named: info.lineNumber)
            base.titleLabel.text = info.stationName
            
            if info.lineCode == ""{
                [base.upBtn, base.downBtn, base.groupBtn]
                    .forEach{
                        $0.isHidden = true
                    }
                base.exceptionLastStationTF.isHidden = true
                base.notServiceBtn.isHidden = false
            }
            
            if info.lineNumber == "02호선"{
                base.upBtn.setTitle("내선", for: .normal)
                base.downBtn.setTitle("외선", for: .normal)
            }else{
                base.upBtn.setTitle("상행", for: .normal)
                base.downBtn.setTitle("하행", for: .normal)
            }
        }
    }
    
    var keyboardReturnBtn : Binder<Void>{
        return Binder(base){base, _ in
            base.becomeFirstResponder()
        }
    }
    
    var modalClose : Binder<Void>{
        return Binder(base){base, _ in
            base.modalDismiss()
        }
    }
    
}
