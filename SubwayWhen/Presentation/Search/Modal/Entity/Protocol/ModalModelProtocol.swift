//
//  ModalModelProtocol.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/28.
//

import Foundation

protocol ModalModelProtocol{
    func useLineTokorailCode(_ useLine : String) -> String
    func updownFix(updown : Bool, line : String) -> String
}
