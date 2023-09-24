//
//  TutorialModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/09/24.
//

import Foundation

import RxSwift

protocol TutorialModelProtocol {
    func createTutorialList() -> Observable<[TutorialSectionData]>
}
