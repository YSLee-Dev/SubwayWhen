//
//  EditCoordinator.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/12.
//

import UIKit

class EditCoordinator: Coordinator {
    var childCoordinator: [Coordinator] = []
    var navigation: UINavigationController
    let editViewModel: EditViewModel
    
    var delegate: EditCoordinatorDelegate?
    
    init(navigation: UINavigationController){
        self.navigation = navigation
        self.editViewModel = EditViewModel()
    }
    
    func start() {
        let editVC = EditVC(viewModel: self.editViewModel)
        editVC.hidesBottomBarWhenPushed = true
        editViewModel.delegate = self
        
        self.navigation.pushViewController(editVC, animated: true)
    }
}

extension EditCoordinator: EditVCDelegate{
    func disappear() {
        self.navigation.interactivePopGestureRecognizer?.isEnabled = true
        self.delegate?.disappear(editCoordinatorDelegate: self)
    }
    
    func notSaveCheck() {
        self.notSaveAlert()
    }
    
    func pop() {
        self.delegate?.pop()
    }
}

private extension EditCoordinator {
    func notSaveAlert() {
        let alert = UIAlertController(
            title: "수정된 지하철역이 저장되지 않았어요.\n저장하지 않을 경우 변경된 내용은 적용되지 않아요.",
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "저장", style: .default) { [weak self] _ in
            self?.editViewModel.requestSave.onNext(Void())
            self?.pop()
        })
        alert.addAction(UIAlertAction(title: "저장하지 않음", style: .destructive) { [weak self] _ in
            self?.pop()
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        self.navigation.present(alert, animated: true)
    }
}
