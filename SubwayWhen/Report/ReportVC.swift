//
//  ReportVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/21.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

class ReportVC : TableVCCustom{
    let bag = DisposeBag()
    let reportViewModel = ReportViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bind(self.reportViewModel)
        self.attribute()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ReportVC{
    private func attribute(){
        self.tableView.register(ReportTableViewLineCell.self, forCellReuseIdentifier: "ReportTableViewLineCell")
        self.tableView.register(ReportTableViewTwoBtnCell.self, forCellReuseIdentifier: "ReportTableViewTwoBtnCell")
        self.tableView.register(ReportTableViewTextFieldCell.self, forCellReuseIdentifier: "ReportTableViewTextFieldCell")
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func bind(_ viewModel : ReportViewModel){
        let dataSources = RxTableViewSectionedAnimatedDataSource<ReportTableViewCellSection>(animationConfiguration: .init(insertAnimation: .top ,reloadAnimation: .top, deleteAnimation: .bottom)){dataSource, tv, index, data in
            
            switch index.section{
            case 0:
                guard let cell = tv.dequeueReusableCell(withIdentifier: "ReportTableViewLineCell", for: index) as? ReportTableViewLineCell else {return UITableViewCell()}
                cell.viewDataSet(data)
                cell.bind(viewModel.lineCellModel)
                
                return cell
                
            case 1:
                if data.type == .TwoBtn{
                    guard let cell = tv.dequeueReusableCell(withIdentifier: "ReportTableViewTwoBtnCell", for: index) as? ReportTableViewTwoBtnCell else {return UITableViewCell()}
                    if index.row == 0{
                        cell.viewDataSet(one: "상행", two: "하행", index: index, titleString: data.cellTitle)
                    }else{
                        cell.viewDataSet(one: "Y", two: "N", index: index, titleString: data.cellTitle)
                    }
                    cell.bind(viewModel.twoBtnCellModel)
                    return cell
                }else if data.type == .TextField{
                    guard let cell = tv.dequeueReusableCell(withIdentifier: "ReportTableViewTextFieldCell", for: index) as?
                            ReportTableViewTextFieldCell else {return UITableViewCell()}
                    cell.viewDataSet(data, index: index)
                    cell.bind(viewModel.textFieldCellModel)
                    return cell
                }else{
                    return UITableViewCell()
                }
                
            case 2:
                if data.type == .TextField{
                    guard let cell = tv.dequeueReusableCell(withIdentifier: "ReportTableViewTextFieldCell", for: index) as?
                            ReportTableViewTextFieldCell else {return UITableViewCell()}
                    cell.viewDataSet(data, index: index)
                    cell.bind(viewModel.textFieldCellModel)
                    return cell
                }else{
                    return UITableViewCell()
                }
            default:
                return UITableViewCell()
            }
        }
        
        dataSources.titleForHeaderInSection = { data, index in
            data[index].sectionName
        }
        
        viewModel.cellData
            .drive(self.tableView.rx.items(dataSource: dataSources))
            .disposed(by: self.bag)
        
        viewModel.keyboardClose
            .drive(self.rx.keyboardClose)
            .disposed(by: self.bag)
        
        viewModel.checkModalViewModel
            .drive(self.rx.modalPresent)
            .disposed(by: self.bag)
        
        viewModel.popVC
            .drive(self.rx.popVC)
            .disposed(by: self.bag)
    }
    
    @objc
    private func keyboardWillShow(_ sender: Notification) {
        let userInfo:NSDictionary = sender.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        self.tableView.snp.updateConstraints{
            $0.bottom.equalToSuperview().inset(keyboardHeight)
        }
        UIView.animate(withDuration: 0.25){[weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func keyboardWillHide(_ sender: Notification) {
        self.tableView.snp.updateConstraints{
            $0.bottom.equalToSuperview().inset(0)
        }
        UIView.animate(withDuration: 0.25){[weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}

extension Reactive where Base : ReportVC{
    var popVC : Binder<Void>{
        return Binder(base){ base, _ in
            base.navigationController?.popViewController(animated: true)
        }
    }
    
    var keyboardClose : Binder<Void>{
        return Binder(base){ base, _ in
            base.view.endEditing(true)
        }
    }
    
    var modalPresent : Binder<ReportCheckModalViewModel>{
        return Binder(base){base, model in
            let modal = ReportCheckModalVC(modalHeight: 400, viewModel: model)
            modal.modalPresentationStyle = .overFullScreen
            base.present(modal, animated: false)
        }
    }
}
