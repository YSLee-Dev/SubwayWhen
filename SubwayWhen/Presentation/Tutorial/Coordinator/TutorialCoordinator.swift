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
    
    init(
        navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }
    
    func start() {
        let tutorialVC = TutorialVC()
        self.navigationController.present(tutorialVC, animated: false)
    }
}
