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
            print(self.childCoordinator)
        }
    }
    var navigation : UINavigationController
    var delegate : MainCoordinatorDelegate?
    
    init(){
        self.navigation = UINavigationController()
    }
    
    func start() {
        let viewModel = MainViewModel()
        viewModel.delegate = self
        
        let main = MainVC(viewModel: viewModel)
        main.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), tag: 0)
   
        self.navigation.setViewControllers([main], animated: true)
    }
    
    func notiTap(saveStation: SaveStation) {
        self.navigation.popToRootViewController(animated: true)
        self.navigation.dismiss(animated: true)
        
        let data = MainTableViewCellData(upDown: saveStation.updnLine, arrivalTime: "", previousStation: "", subPrevious: "", code: "", subWayId: saveStation.lineCode, stationName: saveStation.stationName, lastStation: "", lineNumber: saveStation.line, isFast: "", useLine: saveStation.useLine, group: saveStation.group.rawValue, id: saveStation.id, stationCode: saveStation.stationCode, exceptionLastStation: saveStation.exceptionLastStation, type: .real, backStationId: "", nextStationId: "", korailCode: saveStation.korailCode)
        
        let detailSendModel = DetailSendModel(upDown: data.upDown, stationName: data.stationName, lineNumber: data.lineNumber, stationCode: data.stationCode, lineCode: data.subWayId, exceptionLastStation: data.exceptionLastStation, korailCode: data.korailCode)
        
        let detail = DetailCoordinator(navigation: self.navigation, data: detailSendModel, isDisposable: false)
        self.childCoordinator.append(detail)
        detail.delegate = self
        
        detail.start()
    }
}

extension MainCoordinator : MainDelegate{
    func plusStationTap() {
        self.delegate?.stationPlusBtnTap(self)
    }
    
    func pushTap(action : MainCoordinatorAction) {
        switch action{
        case .Report(let seletedLine):
            DispatchQueue.main.asyncAfter(deadline: .now() + (seletedLine == nil ? 0 :  0.35)) {
                let report = ReportCoordinator(navigation: self.navigation)
                report.seletedLine = seletedLine
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
        let detailSendModel = DetailSendModel(upDown: data.upDown, stationName: data.stationName, lineNumber: data.lineNumber, stationCode: data.stationCode, lineCode: data.subWayId, exceptionLastStation: data.exceptionLastStation, korailCode: data.korailCode)
        let detail = DetailCoordinator(navigation: self.navigation, data: detailSendModel, isDisposable: false)
        self.childCoordinator.append(detail)
        detail.delegate = self
        
        detail.start()
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
    func reportBtnTap(reportLine: ReportBrandData) {
        self.pushTap(action: .Report(reportLine))
    }
    
    func disappear(detailCoordinator: DetailCoordinator) {
        self.childCoordinator = self.childCoordinator.filter{$0 !== detailCoordinator}
    }
}
