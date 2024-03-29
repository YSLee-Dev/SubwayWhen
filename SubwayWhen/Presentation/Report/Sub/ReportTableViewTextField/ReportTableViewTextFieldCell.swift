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

class ReportTableViewTextFieldCell : TableViewCellCustom{
    let textField = UITextField().then{
        $0.textAlignment = .right
    }
    
    var bag = DisposeBag()
    
    var index = IndexPath(row: 0, section: 0)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.bag = DisposeBag()
    }
}

extension ReportTableViewTextFieldCell{
    private func layout(){
        self.mainBG.addSubview(self.textField)
        self.textField.snp.makeConstraints{
            $0.edges.equalToSuperview().inset(15)
            $0.height.equalTo(40)
        }
    }
    
    func bind(_ cellModel : ReportTableViewTextFieldCellModelProtocol){
        let doenTap = self.textField.rx.controlEvent(.editingDidEnd)
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
        self.textField.text = data.cellData
        
        if !(data.cellData.isEmpty){
            self.unseleted()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150)){[weak self] in
            if data.focus{
                self?.textField.becomeFirstResponder()
            }else{
                self?.textField.resignFirstResponder()
            }
        }
       
    }
}
