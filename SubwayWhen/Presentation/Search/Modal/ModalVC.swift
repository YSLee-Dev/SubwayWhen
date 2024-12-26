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
    
    let upBtn = ModalCustomButton(bgColor: UIColor.systemRed, customTappedBG: nil).then{
        $0.setTitle("상행", for: .normal)
    }
    
    let downBtn = ModalCustomButton(bgColor: UIColor.systemBlue, customTappedBG: nil).then{
        $0.setTitle("하행", for: .normal)
    }
    
    let groupBtn = ModalCustomButton(bgColor: UIColor(named: "MainColor") ?? .gray , customTappedBG: nil).then{
        $0.setTitleColor(.label, for: .normal)
        $0.setTitle("출근", for: .normal)
        $0.layer.borderColor = UIColor.systemGray.cgColor
        $0.layer.borderWidth = 0.5
    }
    
    let notServiceBtn = ModalCustomButton(bgColor: .black, customTappedBG: nil).then{
        $0.setTitle("해당 노선은 서비스를 지원하지 않아요.", for: .normal)
        $0.isHidden = true
    }
    
    let exceptionLastStationTF = UITextField().then{
        $0.placeholder = "중간 종착역 제거 (1개이상 콤마 이용)"
        $0.textAlignment = .center
        $0.layer.cornerRadius = ViewStyle.Layer.radius
        $0.layer.borderColor = UIColor.systemGray.cgColor
        $0.layer.borderWidth = 0.5
        $0.layer.masksToBounds = true
        $0.font = UIFont.systemFont(ofSize: ViewStyle.FontSize.superSmallSize)
    }
    
    let disposableView = DisposableView()
    
    let didDisappear = PublishSubject<Void>()
    let modalGesture = PublishSubject<Void>()
    
    deinit{
        print("DEINIT MODAL")
    }
    
    init(_ viewModel : ModalViewModel, modalHeight : CGFloat){
        self.modalViewModel = viewModel
        super.init(modalHeight: modalHeight, btnTitle: "", mainTitle: "지하철 역 추가", subTitle: "그룹, 제외 행을 선택 후 상/하행 버튼을 누르면 저장할 수 있어요.")
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.layout()
        self.atiribute()
    }
    
    override func viewAnimation() {
        super.viewAnimation()
        self.disposableView.showAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.didDisappear.onNext(Void())
    }
    
    override func modalDismiss() {
        self.disposableView.hiddenAnimation()
        
        UIView.animate(withDuration: 0.25, delay: 0, animations: {
            self.mainBG.transform = CGAffineTransform(translationX: 0, y: self.modalHeight)
            self.mainBGContainer.transform = CGAffineTransform(translationX: 0, y: self.modalHeight)
            self.grayBG.backgroundColor = .clear
        }, completion: { _ in
            self.modalGesture.onNext(Void())
        })
    }
}

extension ModalVC{
    private func atiribute(){
        self.disposableView.upDownLabelSet(up: self.upBtn.title(for: .normal) ?? "상행", down: self.downBtn.title(for: .normal) ?? "하행")
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
            $0.top.equalTo(self.subTitle.snp.bottom).offset(30)
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
        
        self.view.addSubview(self.disposableView)
        self.disposableView.snp.makeConstraints{
            $0.bottom.equalTo(self.mainBG.snp.top).offset(-ViewStyle.padding.mainStyleViewTB)
            $0.leading.trailing.equalToSuperview().inset(5)
            $0.height.equalTo(50)
        }
        
    }
    
    private func bind(){
        // VIEW -> VIEWMODEL
        let upBtnTap = self.upBtn.rx.tap
            .map{
                true
            }
        
        let downBtnTap = self.downBtn.rx.tap
            .map{
                false
            }
        
        let updownBtnTap = Observable.merge(upBtnTap, downBtnTap)
        
        let groupTap = self.groupBtn.rx.tap
            .map{ [weak self] _ -> SaveStationGroup in
                if self?.groupBtn.titleLabel!.text == "출근"{
                    self?.groupBtn.setTitle("퇴근", for: .normal)
                    return .two
                }else{
                    self?.groupBtn.setTitle("출근", for: .normal)
                    return .one
                }
            }
            .startWith(.one)
        
       let exceptionLValue = self.exceptionLastStationTF.rx.text
            .skip(1)
            .startWith("")
        
       let disposableUpBtn =  self.disposableView.upBtn.rx.tap
            .map{
                true
            }
        
        let disposableDownBtn =  self.disposableView.downBtn.rx.tap
            .map{
                false
            }
        
        let disposableUpDownBtn = Observable.merge(disposableUpBtn, disposableDownBtn)
        
        let input = ModalViewModel.Input(
                upDownBtnClick: updownBtnTap,
                notService: self.notServiceBtn.rx.tap.asObservable(),
                groupClick: groupTap,
                exceptionLastStationText: exceptionLValue,
                disposableBtnTap: disposableUpDownBtn,
                didDisappear: self.didDisappear.asObservable(),
                modalGesture: self.modalGesture.asObservable()
            )
        
        let output = self.modalViewModel.transform(input: input)
        
        output.modalData
            .drive(self.rx.modalLabelSet)
            .disposed(by: self.bag)
        
        output.modalClose
            .drive(self.rx.modalClose)
            .disposed(by: self.bag)
        
        
        self.exceptionLastStationTF.rx.controlEvent(.editingDidEndOnExit)
            .bind(to: self.rx.keyboardReturnBtn)
            .disposed(by: self.bag)
    }
}

extension Reactive where Base : ModalVC{
    var modalLabelSet : Binder<searchStationInfo>{
        return Binder(base){ base, info in
            base.line.text = info.line.useLine
            base.line.backgroundColor = UIColor(named: info.line.rawValue)
            base.titleLabel.text = info.stationName
            
            if info.line.lineCode == ""{
                [base.upBtn, base.downBtn, base.groupBtn, base.disposableView]
                    .forEach{
                        $0.isHidden = true
                    }
                base.exceptionLastStationTF.isHidden = true
                base.notServiceBtn.isHidden = false
                
            }else{
                if info.line.rawValue == "02호선"{
                    base.upBtn.setTitle("내선", for: .normal)
                    base.downBtn.setTitle("외선", for: .normal)
                }else{
                    base.upBtn.setTitle("상행", for: .normal)
                    base.downBtn.setTitle("하행", for: .normal)
                }
            }
        }
    }
    
    var keyboardReturnBtn : Binder<Void>{
        return Binder(base){base, _ in
            base.becomeFirstResponder()
        }
    }
    
    var modalClose: Binder<Void> {
        return Binder(base) { base, _ in
            base.modalDismiss()
        }
    }
}
