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
        super.init(title: "홈", titleViewHeight: 61)
        self.tableView = self.mainTableView
        self.tableView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attibute()
        self.bind(self.mainViewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // view 다시 들어올 때 리프레시
        self.mainViewModel.reloadData
            .accept(Void())
    }
}
 
extension MainVC{
    private func attibute(){
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        self.topView.backBtn.isHidden = true
        self.topView.subTitleLabel.snp.remakeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
        }
        
        self.topView.subTitleLabel.font = .boldSystemFont(ofSize: ViewStyle.FontSize.mainTitleSize)
        
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
            .drive(self.rx.detailVCPresent)
            .disposed(by: self.bag)
        
        viewModel.editBtnClick
            .drive(self.rx.editVCPresent)
            .disposed(by: self.bag)
        
        viewModel.mainTitle
            .drive(self.rx.mainTitleSet)
            .disposed(by: self.bag)
    }
}

extension Reactive where Base : MainVC {
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
    
    var detailVCPresent : Binder<MainTableViewCellData>{
        return Binder(base){base, data in
            let viewModel = DetailViewModel()
            
            let detail = DetailVC(title: "\(data.useLine) \(data.stationName)", viewModel: viewModel)
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
            
            viewModel.detailViewData.accept(excption)
            
            //#endif
            
            
            base.navigationController?.pushViewController(detail, animated: true)
        }
    }
}
