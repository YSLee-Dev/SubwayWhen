//
//  SearchCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import UIKit

class SearchCoordinator : Coordinator{
    var childCoordinator: [Coordinator] = []
    var navigation : UINavigationController
    var viewModel: SearchViewModelProtocol?
    weak var delegate: SearchCoordinatorDelegate?
    
    init(){
        self.navigation = .init()
    }
    
    func start() {
        let viewModel = SearchViewModel()
        viewModel.delegate = self
        self.viewModel = viewModel
        
        let search = SearchVC(viewModel: viewModel)
        search.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "magnifyingglass"), tag: 1)
        self.navigation.pushViewController(search, animated: true)
    }
}

extension SearchCoordinator: SearchVCActionProtocol {
    func locationPresent() {
        let locationCoordinator = LocationModalCoordinator(navigation: self.navigation)
        locationCoordinator.delegate = self
        locationCoordinator.start()
        
        self.childCoordinator.append(locationCoordinator)
    }
    
    func modalPresent(data: ResultVCCellData) {
        let modalCoordinator = ModalCoordinator(navigation: self.navigation, data: data)
        modalCoordinator.delegate = self
        modalCoordinator.start()
        
        self.childCoordinator.append(modalCoordinator)
    }
}

extension SearchCoordinator: ModalCoordinatorProtocol {
    func dismiss() {
        self.navigation.dismiss(animated: false)
    }
    
    func stationSave() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){[weak self] in
            let popup = PopupModal(modalHeight: 400, popupTitle: "저장 완료", subTitle: "지하철 역이 저장되었어요.", iconName: "CheckMark", congratulations: true)
            popup.modalPresentationStyle = .overFullScreen
            self?.navigation.present(popup, animated: false)
        }
    }
    
    func disposableDetailPush(data: DetailSendModel) {
        let detailCoordinator = DetailCoordinator(navigation: self.navigation, data: data, isDisposable: true)
        detailCoordinator.start()
        detailCoordinator.delegate = self
        self.childCoordinator.append(detailCoordinator)
    }
    
    func didDisappear(modalCoordinator: Coordinator) {
        self.childCoordinator = self.childCoordinator.filter {
            $0 !== modalCoordinator
        }
    }
}

extension SearchCoordinator: DetailCoordinatorDelegate {
    func reportBtnTap(reportLine: ReportBrandData) {
        self.pop()
        self.delegate?.tempDetailViewToReportBtnTap(reportLine: reportLine)
    }
    
    func pop() {
        self.navigation.dismiss(animated: true)
    }
    
    func disappear(detailCoordinator: DetailCoordinator) {
        self.childCoordinator = self.childCoordinator.filter {
            $0 !== detailCoordinator
        }
    }
}

extension SearchCoordinator: LocationModalCoordinatorProtocol {
    func stationTap(stationName: String) {
        self.dismiss()
        
        guard let viewModel = self.viewModel else {return}
        viewModel.locationModalTap.onNext(stationName)
    }
    
    func didDisappear(locationModalCoordinator: Coordinator) {
        self.childCoordinator = self.childCoordinator.filter {
            $0 !== locationModalCoordinator
        }
    }
}
