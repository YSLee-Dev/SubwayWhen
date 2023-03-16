//
//  SettingTableViewCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/16.
//

import UIKit

import RxSwift
import RxCocoa
import RxOptional

class SettingTableViewCell : UITableViewCell{
    var bag = DisposeBag()
    
    let mainBG = MainStyleUIView()
    
    let settingTitle = UILabel().then{
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.mediumSize)
        $0.textColor = .label
    }
    
    lazy var textField = UITextField().then{
        $0.backgroundColor = UIColor(named: "MainColor")
        $0.layer.cornerRadius = ViewStyle.Layer.radius
        $0.textAlignment = .right
        $0.placeholder = "한 글자만 가능해요."
        $0.font = .systemFont(ofSize: ViewStyle.FontSize.mediumSize)
    }
    
    lazy var tfToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 50)).then{
        $0.backgroundColor = .systemBackground
        $0.sizeToFit()
    }
    lazy var doneBarBtn = UIBarButtonItem(title: "완료", style: .done, target: nil, action: nil)
    
    lazy var onoffSwitch = UISwitch().then{
        $0.onTintColor = UIColor(named: "AppIconColor")
    }
    
    var index : IndexPath = .init(row: 0, section: 0)
    
    override func prepareForReuse() {
        self.bag = DisposeBag()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layout()
        self.attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SettingTableViewCell{
    private func attribute(){
        self.selectionStyle = .none
    }
    private func layout(){
        self.contentView.addSubview(self.mainBG)
        self.mainBG.snp.makeConstraints{
            $0.top.equalToSuperview().offset(2.5)
            $0.bottom.equalToSuperview().inset(2.5)
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
        }
        
        self.mainBG.addSubview(self.settingTitle)
        self.settingTitle.snp.makeConstraints{
            $0.leading.equalToSuperview().inset(15)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(self.snp.centerX)
        }
    }
    
    func bind(_ cellModel : SettingTableViewCellModel){
        self.textField.rx.controlEvent(.editingDidEnd)
        .withLatestFrom(self.textField.rx.text)
            .bind(to: cellModel.tfValue)
            .disposed(by: self.bag)
        
        self.onoffSwitch.rx.isOn
            .bind(to: cellModel.switchValue)
            .disposed(by: self.bag)
        
        self.doneBarBtn.rx.tap
            .bind(to: cellModel.keyboardClose)
            .disposed(by: self.bag)
        
        Observable<Void>.merge(
            self.textField.rx.controlEvent(.editingDidEnd).asObservable(),
            self.onoffSwitch.rx.isOn.map{_ in Void()}.skip(1)
        )
        .map{[weak self] _ in
            self?.index ?? IndexPath(row: 9, section: 9)
        }
        .bind(to: cellModel.cellIndex)
        .disposed(by: self.bag)
    }
    
    func titleSet(title : String, index : IndexPath){
        self.settingTitle.text = title
        self.index = index
    }
    
    // 셀 스타일에 맞게 분배
    func cellStyleSet(_ type : SettingTableViewCellType, defaultValue : String){
        if type == .Switch{
            self.switchSet(defaultValue: defaultValue)
        }else if type == .TextField{
            self.tfSet(defaultValue: defaultValue)
        }else if type == .NewVC{
            self.newVCSet()
        }
    }
    
    func tfMaxText(_ max : Int){
        self.textField.rx.text
            .filterNil()
            .filter{$0.count > max}
            .map{
                String($0.first ?? "☹️")
            }
            .bind(to: self.textField.rx.text)
            .disposed(by: self.bag)
    }
    
    private func tfSet(defaultValue : String){
        self.mainBG.addSubview(self.textField)
        self.textField.snp.makeConstraints{
            $0.leading.equalTo(self.snp.centerX)
            $0.trailing.equalToSuperview().inset(15)
            $0.centerY.equalToSuperview()
        }
        
        self.textField.text = defaultValue
        
        self.tfToolBar.setItems([self.doneBarBtn], animated: true)
        self.textField.inputAccessoryView = self.tfToolBar
    }
    
    private func switchSet(defaultValue : String){
        self.mainBG.addSubview(self.onoffSwitch)
        self.onoffSwitch.snp.makeConstraints{
            $0.trailing.equalToSuperview().inset(15)
            $0.centerY.equalToSuperview()
        }
        
        let value = defaultValue == "true" ? true : false
        self.onoffSwitch.isOn = value
    }
    
    // 새로운 VC로 이동 
    private func newVCSet(){
        self.accessoryType = .disclosureIndicator
    }
}
