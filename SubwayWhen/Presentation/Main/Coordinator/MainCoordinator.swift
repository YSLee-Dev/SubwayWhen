//
//  MainCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import UIKit

class MainCoordinator : Coordinator{
    var childCoordinator: [Coordinator] = []{
        didSet{
            AppLogger.coordinator.log(.debug, "MainCoordinator 자식: \(self.childCoordinator)")
        }
    }
    var navigation : UINavigationController
    var delegate : MainCoordinatorDelegate?
    private var nowNotiTapped = false
    private let viewModel: MainViewModel
    
    init(){
        self.navigation = UINavigationController()
        self.viewModel = MainViewModel()
    }
    
    func start() {
        self.viewModel.delegate = self
        
        let main = MainVC(viewModel: self.viewModel)
        main.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), tag: 0)
        
        if #available(iOS 26.0, *) {
            main.extendedLayoutIncludesOpaqueBars = true
            main.edgesForExtendedLayout = .all
        }
   
        self.navigation.setViewControllers([main], animated: true)
    }
    
    func notiTap(saveStation: SaveStation) {
        if self.nowNotiTapped {return}
        self.nowNotiTapped = true
        
        let isPushed = self.navigation.viewControllers.count != 1
        self.navigation.popToRootViewController(animated: true)
        self.navigation.dismiss(animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (isPushed && UIDevice.isiOS26OrLater ? 0.2 : 0)) {
            let data = MainTableViewCellData(upDown: saveStation.updnLine, arrivalTime: "", previousStation: "", subPrevious: "", code: "", stationName: saveStation.stationName, lastStation: "",  isFast: "",  group: saveStation.group.rawValue, id: saveStation.id, stationCode: saveStation.stationCode, exceptionLastStation: saveStation.exceptionLastStation, type: .real, backStationId: "",  nextStationId: "", korailCode: saveStation.korailCode, stateMSG: "", subwayLineData: .init(subwayId: saveStation.lineCode))
            
            let detailSendModel = DetailSendModel(upDown: data.upDown, stationName: data.stationName, lineNumber: data.subwayLineData.rawValue, stationCode: data.stationCode, lineCode: data.subwayLineData.lineCode, exceptionLastStation: data.exceptionLastStation, korailCode: data.korailCode)
            
            let detail = DetailCoordinator(navigation: self.navigation, data: detailSendModel, isDisposable: false)
            self.childCoordinator.append(detail)
            detail.delegate = self
            
            detail.start()
        }
       
        DispatchQueue.main.asyncAfter(deadline: .now() + (isPushed && UIDevice.isiOS26OrLater ? 0.2 : 0) + 0.2) {
            self.nowNotiTapped = false
        }
    }
    
    private func detailCoordinatorCreate(data: MainTableViewCellData) -> DetailCoordinator {
        let detailSendModel = DetailSendModel(upDown: data.upDown, stationName: data.stationName, lineNumber: data.subwayLineData.rawValue, stationCode: data.stationCode, lineCode: data.subwayLineData.lineCode, exceptionLastStation: data.exceptionLastStation, korailCode: data.korailCode)
        return DetailCoordinator(navigation: self.navigation, data: detailSendModel, isDisposable: false)
    }
}

extension MainCoordinator : MainDelegate {
    func detailLongPress(data: MainTableViewCellData) -> UIViewController? {
        let detail = self.detailCoordinatorCreate(data: data)
        return detail.createDetailVC()
    }
    
    func plusStationTap() {
        self.delegate?.stationPlusBtnTap(self)
    }
    
    func pushTap(action : MainCoordinatorAction) {
        switch action{
        case .Report(let seletedLine, let stationName):
            DispatchQueue.main.asyncAfter(deadline: .now() + (seletedLine == nil ? 0 :  0.35)) {
                let report = ReportCoordinator(navigation: self.navigation, initValue: (seletedLine, stationName))
                self.childCoordinator.append(report)
                report.delegate = self
              
                report.start()
            }
           
        case .Edit:
            let edit = EditCoordinator(navigation: self.navigation)
            self.childCoordinator.append(edit)
            edit.delegate = self
          
            edit.start()
        }
    }
    
    func pushDetailTap(data: MainTableViewCellData) {
        let detail = self.detailCoordinatorCreate(data: data)
        self.childCoordinator.append(detail)
        detail.delegate = self
        
        detail.start()
    }
    
    func importantTap(data: ImportantData) {
        self.executeAfterTransition { [weak self] in
            let modal = PopupModal(
                modalHeight: 400,
                popupTitle: Strings.Main.importantAlarm,
                subTitle: data.title,
                popupValue: data.contents
            )
            
            modal.modalPresentationStyle = .overFullScreen
            self?.navigation.present(modal, animated: false)
        }
    }
    
    func congestionTap() {
        self.executeAfterTransition { [weak self] in
            let congestion = CongestionModalCoordinator(navigation: self?.navigation ?? .init())
            self?.childCoordinator.append(congestion)
            congestion.delegate = self
            
            congestion.start()
        }
    }
    
    private func executeAfterTransition(_ action: @escaping () -> Void) {
        if let coordinator = self.navigation.transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { context in
                if !context.isCancelled {
                    action()
                }
            }
        } else {
            action()
        }
    }
}

extension MainCoordinator : ReportCoordinatorDelegate{
    func pop() {
        self.navigation.popViewController(animated: true)
    }
    
    func disappear(reportCoordinator: ReportCoordinator) {
        self.childCoordinator = self.childCoordinator.filter{$0 !== reportCoordinator}
    }
}

extension MainCoordinator : EditCoordinatorDelegate{
    func disappear(editCoordinatorDelegate: EditCoordinator) {
        self.childCoordinator = self.childCoordinator.filter{$0 !== editCoordinatorDelegate}
    }
}

extension MainCoordinator : DetailCoordinatorDelegate{
    func reportBtnTap(reportLine: SubwayLineData, stationName: String) {
        self.pushTap(action: .Report(reportLine, stationName))
    }
    
    func disappear(detailCoordinator: DetailCoordinator) {
        self.childCoordinator = self.childCoordinator.filter{$0 !== detailCoordinator}
    }
}

extension MainCoordinator: CongestionCoordinatorProtocol {
    func congestionStationChanged() {
        self.viewModel.congestionUpdate()
    }
    
    func didDisappear(coordinator: any Coordinator) {
        self.childCoordinator = self.childCoordinator.filter{$0 !== coordinator}
    }
    
    func dismiss() {
        self.navigation.dismiss(animated: false)
    }
}
