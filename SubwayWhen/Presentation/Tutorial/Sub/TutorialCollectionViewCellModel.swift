//
//  TutorialCollectionViewCellModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/09/25.
//

import Foundation

import RxSwift

class TutorialCollectionViewCellModel: TutorialCollectionViewCellModelProtocol {
    let nextBtnTap = PublishSubject<Void>()
}
