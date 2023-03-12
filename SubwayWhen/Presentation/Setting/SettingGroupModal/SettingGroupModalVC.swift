//
//  SettingGroupModalVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/17.
//

import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa
import RxOptional

class SettingGroupModalVC : ModalVCCustom{
    let bag = DisposeBag()
    let settingGroupViewModel : SettingGroupModalViewModel
    
    let groupOneTitle = UILabel().then{
        $0.text = "출근시간"
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.largeSize, weight: .bold)
        $0.textColor = .label
    }
    
    let groupOneHour = SettingGroupModalTF()
    
    let groupTwoTitle = UILabel().then{
        $0.text = "퇴근시간"
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.largeSize, weight: .bold)
        $0.textColor = .label
    }
    
    let groupTwoHour = SettingGroupModalTF()
    
    let groupOneStepper = UIStepper().then{
        $0.maximumValue = 23
    }
    let groupTwoStepper = UIStepper().then{
        $0.maximumValue = 23
    }
    
    override init(modalHeight: CGFloat, btnTitle : String, mainTitle : String, subTitle : String) {
        self.settingGroupViewModel = SettingGroupModalViewModel()
        super.init(modalHeight: modalHeight, btnTitle: btnTitle, mainTitle: mainTitle, subTitle: subTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.layout()
        self.bind(self.settingGroupViewModel)
    }
}

extension SettingGroupModalVC{
    private func layout(){
        [self.groupOneTitle, self.groupOneHour, self.groupOneStepper, self.groupTwoHour, self.groupTwoTitle, self.groupTwoStepper].forEach{
            self.mainBG.addSubview($0)
        }
        
        self.groupOneTitle.snp.makeConstraints{
            $0.leading.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.top.equalTo(self.subTitle.snp.bottom).offset(35)
        }
        
        self.groupOneHour.snp.makeConstraints{
            $0.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.leading.equalTo(self.groupOneStepper.snp.leading)
            $0.bottom.equalTo(self.groupOneTitle.snp.centerY).offset(-5)
            $0.height.equalTo(20)
        }
        
        self.groupOneStepper.snp.makeConstraints{
            $0.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.top.equalTo(self.groupOneTitle.snp.centerY).offset(5)
            $0.height.equalTo(20)
        }
        
        self.groupTwoTitle.snp.makeConstraints{
            $0.leading.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.top.equalTo(self.groupOneStepper.snp.bottom).offset(62.5)
        }
        
        self.groupTwoHour.snp.makeConstraints{
            $0.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.leading.equalTo(self.groupTwoStepper.snp.leading)
            $0.bottom.equalTo(self.groupTwoTitle.snp.centerY).offset(-5)
            $0.height.equalTo(20)
        }
        
        self.groupTwoStepper.snp.makeConstraints{
            $0.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.top.equalTo(self.groupTwoTitle.snp.centerY).offset(5)
            $0.height.equalTo(20)
        }
    }
    
    private func bind(_ viewModel : SettingGroupModalViewModel){
        // VIEWMODEL -> VIEW
        viewModel.groupOneDefaultValue
            .map{
                String($0)
            }
            .drive(self.groupOneHour.tf.rx.text)
            .disposed(by: self.bag)
        
        viewModel.groupTwoDefaultValue
            .map{
                String($0)
            }
            .drive(self.groupTwoHour.tf.rx.text)
            .disposed(by: self.bag)
        
        viewModel.modalClose
            .drive(self.rx.modalDismiss)
            .disposed(by: self.bag)
        
        // VIEW -> VIEWMODEL
        self.groupOneHour.tf.rx.text
            .map{
                Int($0 ?? "")
            }
            .filterNil()
            .bind(to: viewModel.groupOneHourValue)
            .disposed(by: self.bag)
        
        self.groupTwoHour.tf.rx.text
            .map{
                Int($0 ?? "")
            }
            .filterNil()
            .bind(to: viewModel.groupTwoHourValue)
            .disposed(by: self.bag)
        
        self.okBtn!.rx.tap
            .bind(to: viewModel.saveBtnClick)
            .disposed(by: self.bag)
        
        // VIEW
        self.groupOneHour.tf.rx.text
            .map{
                Double($0 ?? "0.0")
            }
            .filterNil()
            .bind(to: self.groupOneStepper.rx.value)
            .disposed(by: self.bag)
        
        self.groupTwoHour.tf.rx.text
            .map{
                Double($0 ?? "0.0")
            }
            .filterNil()
            .bind(to: self.groupTwoStepper.rx.value)
            .disposed(by: self.bag)
        
        self.groupOneHour.tf.rx.text
            .map{ data -> String? in
                guard let intValue = Int(data ?? "") else {return ""}
                
                if intValue < 24{
                    return "\(intValue)"
                }else{
                   return ""
                }
            }
            .bind(to: self.groupOneHour.tf.rx.text)
            .disposed(by: self.bag)
        
        
        self.groupTwoHour.tf.rx.text
            .map{ data -> String? in
                guard let intValue = Int(data ?? "") else {return ""}
                
                if intValue < 24{
                    return "\(intValue)"
                }else{
                   return ""
                }
            }
            .bind(to: self.groupTwoHour.tf.rx.text)
            .disposed(by: self.bag)
        
        // VIEWMODEL / VIEW
        let oneValue = self.groupOneStepper.rx.value
            .map{
                Int($0)
            }
            .share()
        
        oneValue
            .bind(to: viewModel.groupOneHourValue)
            .disposed(by: self.bag)
        
        oneValue
            .map{"\($0)"}
            .bind(to: self.groupOneHour.tf.rx.text)
            .disposed(by: self.bag)
        
        let twoValue = self.groupTwoStepper.rx.value
            .map{
                Int($0)
            }
            .share()
        
        twoValue
            .bind(to: viewModel.groupTwoHourValue)
            .disposed(by: self.bag)
        
        twoValue
            .map{"\($0)"}
            .bind(to: self.groupTwoHour.tf.rx.text)
            .disposed(by: self.bag)
    }
}

extension Reactive where Base : SettingGroupModalVC{
    var modalDismiss : Binder<Void>{
        return Binder(base){ base, _ in
            base.modalDismiss()
        }
    }
}
