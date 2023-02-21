//
//  MainVC.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa

class MainVC : TableVCCustom{
    let bag = DisposeBag()
    
    let mainTableView = MainTableView()
    let mainViewModel = MainViewModel()
    
    init(){
        super.init(title: "홈", titleViewHeight: 62)
        self.tableView = self.mainTableView
        self.tableView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bind(self.mainViewModel)
        self.attibute()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // view 다시 들어올 때 리프레시
        self.mainViewModel.reloadData
            .accept(Void())
    }
}
 
extension MainVC{
    private func attibute(){
        self.topView.backBtn.isHidden = true
        self.topView.subTitleLabel.snp.remakeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
        }
        
        self.topView.subTitleLabel.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mainTitleMediumSize)
        
        self.titleView.mainTitleLabel.snp.updateConstraints{
            $0.centerY.equalToSuperview().offset(-5)
        }
    }
    
    private func bind(_ viewModel : MainViewModel){
        self.mainTableView.bind(viewModel.mainTableViewModel)
        
        // VIEWMODEL -> VIEW
        viewModel.stationPlusBtnClick
            .drive(self.rx.tapChange)
            .disposed(by: self.bag)
        
        viewModel.clickCellData
            .drive(self.rx.detailVCPush)
            .disposed(by: self.bag)
        
        viewModel.editBtnClick
            .drive(self.rx.editVCPresent)
            .disposed(by: self.bag)
        
        viewModel.mainTitle
            .drive(self.rx.mainTitleSet)
            .disposed(by: self.bag)
        
        viewModel.mainTitleHidden
            .drive(self.rx.mainTitleHidden)
            .disposed(by: self.bag)
        
        viewModel.reportBtnClick
            .drive(self.rx.reportVCPush)
            .disposed(by: self.bag)
    }
}

extension Reactive where Base : MainVC {
    var mainTitleHidden : Binder<Void>{
        return Binder(base){base, _ in
            base.topView.isMainTitleHidden(true)
        }
    }
    
    var mainTitleSet : Binder<String>{
        return Binder(base){base, data in
            base.titleView.mainTitleLabel.text = data
        }
    }
    
    var tapChange : Binder<Void>{
        return Binder(base){base, _ in
            base.tabBarController?.selectedIndex = 1
        }
    }
    
    var editVCPresent : Binder<Void>{
        return Binder(base){base, _ in
            let editVC = EditVC(title: "편집")
            editVC.modalPresentationStyle = .fullScreen
            base.present(editVC, animated: true)
        }
    }
    
    var detailVCPush : Binder<MainTableViewCellData>{
        return Binder(base){base, data in
            let detail = DetailVC(title: "\(data.useLine) \(data.stationName)")
            detail.hidesBottomBarWhenPushed = true
            /*
            #if DEBUG
            viewModel.detailViewData.accept(.init(upDown: data.upDown, arrivalTime: "도착시간", previousStation: "설명", subPrevious: "서브설명", code: "0", subWayId: "123", stationName: "서울역", lastStation: "lastStation", lineNumber: data.lineNumber, isFast: "", useLine: data.useLine, group: data.group, id: data.id, stationCode: data.stationCode, exceptionLastStation: "", type: .real, backStationId: "1001000134", nextStationId: "1001000132", totalStationId: data.totalStationId))
            #else
             */
            var excption = data
            
            // 공항철도는 반대 (ID)
            if excption.useLine == "공항철도"{
                let next = excption.nextStationId
                excption.nextStationId = excption.backStationId
                excption.backStationId = next
            }
            
            detail.detailViewModel.detailViewData.accept(excption)
            
            //#endif
            
            
            base.navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    var reportVCPush : Binder<Void>{
        return Binder(base){base, _ in
            let reportVC = ReportVC(title: "지하철 민원")
            reportVC.hidesBottomBarWhenPushed = true
            base.navigationController?.pushViewController(reportVC, animated: true)
        }
    }
}
