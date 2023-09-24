//
//  TutorialCellData.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/09/24.
//

import UIKit

import RxDataSources

struct TutorialCellData {
    let title: String
    let contents: UIImage
    let btnTitle: String
}

extension TutorialCellData: IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: String{
        self.title
    }
}
