//
//  ReportTableViewTextFieldCell.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/21.
//

import UIKit

import RxSwift
import RxCocoa
import RxOptional

class ReportTableViewTextFieldCell : UITableViewCell{
    let mainBG = MainStyleUIView()
    
    let textField = UITextField().then{
        $0.textAlignment = .right
    }
    
    lazy var tfToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 50)).then{
        $0.backgroundColor = .systemBackground
        $0.sizeToFit()
    }
    
    lazy var doneBarBtn = UIBarButtonItem(title: "완료", style: .done, target: nil, action: nil)
    
    var bag = DisposeBag()
    
    var index = IndexPath(row: 0, section: 0)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.attribute()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.bag = DisposeBag()
        self.textField.text = ""
    }
}

extension ReportTableViewTextFieldCell{
    private func attribute(){
        self.selectionStyle = .none
        
        self.tfToolBar.items = [self.doneBarBtn]
        self.textField.inputAccessoryView = self.tfToolBar
    }
    
    private func layout(){
        self.contentView.addSubview(self.mainBG)
        self.mainBG.snp.makeConstraints{
            $0.top.bottom.equalToSuperview().inset(ViewStyle.padding.mainStyleViewTB)
            $0.leading.trailing.equalToSuperview().inset(ViewStyle.padding.mainStyleViewLR)
            $0.height.equalTo(60)
        }
        
        self.mainBG.addSubview(self.textField)
        self.textField.snp.makeConstraints{
            $0.edges.equalToSuperview().inset(15)
        }
    }
    
    func bind(_ cellModel : ReportTableViewTextFieldCellModel){
      let doenTap =  self.doneBarBtn.rx.tap
            .withLatestFrom(self.textField.rx.text)
            .map{ data -> String? in
                guard let nowString = data else {return nil}
                
                if nowString.isEmpty{
                    return nil
                }else{
                    return nowString
                }
            }
            .filterNil()
        
        doenTap
            .bind(to: cellModel.doenBtnClick)
            .disposed(by: self.bag)
        
        doenTap
            .map{[weak self] _  in
                self?.unseleted()
                return self?.index ?? IndexPath(row: 0, section: 0)
            }
            .bind(to: cellModel.identityIndex)
            .disposed(by: self.bag)
    }
    
    func unseleted(){
        self.textField.isEnabled = false
        self.mainBG.alpha = 0.5
    }
    
    func viewDataSet(_ data : ReportTableViewCellData, index : IndexPath){
        self.textField.placeholder = data.cellTitle
        self.index = index
    }
}
