//
//  SettingVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/16.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

import AcknowList

class SettingVC : TableVCCustom{
    let settingVC : SettingViewModelProtocol
    let bag = DisposeBag()
    
    init(viewModel : SettingViewModelProtocol) {
        self.settingVC = viewModel
        super.init(title: "설정", titleViewHeight: 30)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attibute()
        self.layout()
        self.bind(self.settingVC)
    }
}

extension SettingVC{
    private func attibute(){
        self.topView.backBtn.isHidden = true
        self.topView.subTitleLabel.font = .boldSystemFont(ofSize: ViewStyle.FontSize.largeSize)
        self.titleView.mainTitleLabel.numberOfLines = 1
        
        self.tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: "SettingTableViewCell")
        self.tableView.rowHeight = 65
    }
    
    private func layout(){
        self.topView.subTitleLabel.snp.remakeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
        }
        
        self.titleView.mainTitleLabel.snp.updateConstraints{
            $0.centerY.equalToSuperview().offset(-5)
        }
    }
    
    private func bind(_ viewModel : SettingViewModelProtocol){
        let dataSource = RxTableViewSectionedAnimatedDataSource<SettingTableViewCellSection>(animationConfiguration: .init(reloadAnimation: .fade)){_, tv, index, data in
            guard let cell = tv.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: index) as? SettingTableViewCell else {return UITableViewCell()}
            cell.titleSet(title: data.settingTitle, index: index)
            cell.cellStyleSet(data.inputType, defaultValue: data.defaultData)
            cell.bind(viewModel.settingTableViewCellModel)
            
            // 셀에 따른 추가 설정
            if data.settingTitle == "혼잡도 이모지"{
                cell.tfMaxText(1)
            }
            return cell
        }
        
        dataSource.titleForHeaderInSection = { data, row in
            data[row].sectionName
        }
        
        self.tableView.rx.modelSelected(SettingTableViewCellData.self)
            .bind(to: viewModel.cellClick)
            .disposed(by: self.bag)
        
        viewModel.cellData
            .drive(self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.bag)
        
        viewModel.keyboardClose
            .drive(self.rx.keyboardClose)
            .disposed(by: self.bag)
    }
}

extension Reactive where Base : SettingVC{
    var keyboardClose : Binder<Void>{
        return Binder(base){ base, _ in
            base.view.endEditing(true)
        }
    }
}
