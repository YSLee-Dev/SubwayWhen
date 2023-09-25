//
//  TutorialCollectionViewCellModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/09/25.
//

import Foundation

import RxSwift

protocol TutorialCollectionViewCellModelProtocol {
    var nextBtnTap: PublishSubject<Void> {get}
}
