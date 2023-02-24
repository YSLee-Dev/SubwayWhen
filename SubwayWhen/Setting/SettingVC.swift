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

class SettingVC : TableVCCustom{
    let settingVC : SettingViewModel
    let bag = DisposeBag()
    
    override init(title: String, titleViewHeight: CGFloat) {
        self.settingVC = SettingViewModel()
        super.init(title: title, titleViewHeight: titleViewHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attibute()
        self.bind(self.settingVC)
    }
}

extension SettingVC{
    private func attibute(){
        self.topView.backBtn.isHidden = true
        self.topView.subTitleLabel.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mainTitleMediumSize)
        self.topView.subTitleLabel.snp.remakeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
        }
        
        self.titleView.mainTitleLabel.numberOfLines = 1
        
        self.tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: "SettingTableViewCell")
        self.tableView.rowHeight = 65
    }
    
    private func bind(_ viewModel : SettingViewModel){
        let dataSource = RxTableViewSectionedAnimatedDataSource<SettingTableViewCellSection>(animationConfiguration: .init(reloadAnimation: .top)){_, tv, index, data in
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
        
        viewModel.modalPresent
            .drive(self.rx.modalPresent)
            .disposed(by: self.bag)
    }
}

extension Reactive where Base : SettingVC{
    var keyboardClose : Binder<Void>{
        return Binder(base){ base, _ in
            base.view.endEditing(true)
        }
    }
    
    var modalPresent : Binder<SettingTableViewCellData>{
        return Binder(base){base, data in
            base.view.endEditing(true)
            if data.settingTitle == "특정 그룹 시간"{
                let modal = SettingGroupModalVC(modalHeight: 405, btnTitle: "저장", mainTitle: "특정 그룹 시간", subTitle: "정해진 시간에 맞게 출,퇴근 그룹을 자동으로 변경해주는 기능이에요.")
                modal.modalPresentationStyle = .overFullScreen
                
                base.present(modal, animated: false)
            }else if data.settingTitle == "기타"{
                let modal = SettingContentsModalVC(modalHeight: 400, btnTitle: "닫기", mainTitle: "기타", subTitle: "저작권 및 데이터 출처를 표시하는 공간이에요.")
                modal.modalPresentationStyle = .overFullScreen
                
                base.present(modal, animated: false)
            }
        }
    }
}
