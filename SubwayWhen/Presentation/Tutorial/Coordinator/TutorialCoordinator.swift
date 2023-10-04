//
//  TutorialCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/09/22.
//

import UIKit

class TutorialCoordinator: Coordinator {
    var childCoordinator: [Coordinator] = []
    let navigationController: UINavigationController
    
    weak var deleagate: TutorialVCCoordinatorProtocol?
    
    init(
        navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }
    
    deinit {
        print("TutorialCoordinator DEINIT")
    }
    
    func start() {
        let viewModel = TutorialViewModel()
        let tutorialVC = TutorialVC(viewModel: viewModel)
        viewModel.delegate = self
        
        tutorialVC.modalPresentationStyle = .overFullScreen
        self.navigationController.present(tutorialVC, animated: false)
    }
}

extension TutorialCoordinator: TutorialVCAction {
    func didDisappear() {
        self.deleagate?.didDisappear(coordinator: self)
    }
    
    func lastBtnTap() {
        self.deleagate?.lastBtnTap()
    }
}
