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
    let modalViewModel : ModalViewModelProtocol
    let bag = DisposeBag()
    
    weak var delegate : ModalVCProtocol?
    
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
    
    deinit{
        print("DEINIT MODAL")
    }
    
    init(_ viewModel : ModalViewModelProtocol, modalHeight : CGFloat){
        self.modalViewModel = viewModel
        super.init(modalHeight: modalHeight, btnTitle: "", mainTitle: "지하철 역 추가", subTitle: "그룹, 제외 행을 선택 후 상/하행 버튼을 누르면 저장할 수 있어요.")
        self.bind(self.modalViewModel)
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
    
    override func modalDismiss() {
        super.modalDismiss()
        self.disposableView.hiddenAnimation()
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
    
    private func bind(_ viewModel : ModalViewModelProtocol){
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
            .bind(to: viewModel.notService)
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
            .skip(1)
            .bind(to: viewModel.exceptionLastStationText)
            .disposed(by: self.bag)
        
        self.disposableView.upBtn.rx.tap
            .map{
                true
            }
            .bind(to: viewModel.disposableBtnTap)
            .disposed(by: self.bag)
        
        self.disposableView.downBtn.rx.tap
            .map{
                false
            }
            .bind(to: viewModel.disposableBtnTap)
            .disposed(by: self.bag)
        
        // VIEW
        self.exceptionLastStationTF.rx.controlEvent(.editingDidEndOnExit)
            .bind(to: self.rx.keyboardReturnBtn)
            .disposed(by: self.bag)
        
        // VIEWMODEL -> VIEW
        viewModel.saveComplete
            .drive(self.rx.toastMagShow)
            .disposed(by: self.bag)
        
        viewModel.modalData
            .drive(self.rx.modalLabelSet)
            .disposed(by: self.bag)
        
        viewModel.modalClose
            .drive(self.rx.modalClose)
            .disposed(by: self.bag)
        
        viewModel.alertShow
            .drive(self.rx.noSaveAlert)
            .disposed(by: self.bag)
        
        viewModel.disposableDetailMove
            .drive(self.rx.disposableDetailPush)
            .disposed(by: self.bag)
    }
}

extension Reactive where Base : ModalVC{
    var modalLabelSet : Binder<ResultVCCellData>{
        return Binder(base){ base, info in
            base.line.text = info.useLine
            base.line.backgroundColor = UIColor(named: info.lineNumber)
            base.titleLabel.text = info.stationName
            
            if info.lineCode == ""{
                [base.upBtn, base.downBtn, base.groupBtn, base.disposableView]
                    .forEach{
                        $0.isHidden = true
                    }
                base.exceptionLastStationTF.isHidden = true
                base.notServiceBtn.isHidden = false
                
            }else{
                if info.lineNumber == "02호선"{
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
    
    var modalClose : Binder<Void>{
        return Binder(base){base, _ in
            base.modalDismiss()
        }
    }
    
    var toastMagShow : Binder<Void>{
        return Binder(base){base, _ in
            base.delegate?.stationSave()
        }
    }
    
    var noSaveAlert : Binder<Void>{
        return Binder(base){ base, _ in
            let alert = UIAlertController(title: "이미 저장된 지하철역이에요.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .cancel){_ in
                base.modalViewModel.overlapOkBtnTap.accept(Void())
            })
            
            base.present(alert, animated: true)
        }
    }
    
    var disposableDetailPush : Binder<DetailLoadData>{
        return Binder(base){base, data in
            base.delegate?.disposableDetailPush(data: data)
            base.modalDismiss()
        }
    }
}
