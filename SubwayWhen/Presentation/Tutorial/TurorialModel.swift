//
//  TurorialModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/09/24.
//

import Foundation

import RxSwift

class TutorialModel: TutorialModelProtocol {
    func createTutorialList() -> Observable<[TutorialSectionData]> {
        return Observable<[TutorialSectionData]>.create {
            $0.onNext([
                .init(sectionName: "first", items: [
                    .init(title: "버튼을 눌러, 민실씨의 기능을 확인해보세요!",
                          contents: UIImage(systemName: "doc.text")!,
                          btnTitle: "시작하기"
                         ),
                    .init(title: "홈화면의 + 버튼이나, 검색 버튼을 이용하여 선호하는 지하철 역을 추가할 수 있어요.",
                          contents: UIImage(named: "Tutorial_One") ?? UIImage(systemName: "doc.text")!,
                          btnTitle: "다음 1/5"
                         ),
                    .init(title: "지하철 역을 추가할 때 원하지 않는 행선지는 할 수 있어요.",
                          contents: UIImage(named: "Tutorial_Two") ?? UIImage(systemName: "doc.text")!,
                          btnTitle: "다음 2/5"
                         ),
                    .init(title: "출퇴근 시간에 맞춰서 알림을 받고, 해당 그룹으로 이동할 수 있어요.",
                          contents: UIImage(named: "Tutorial_Three") ?? UIImage(systemName: "doc.text")!,
                          btnTitle: "다음 3/5"
                         ),
                    .init(title: "지하철 역을 추가할 때 원하지 않는 행선지는 제거하고 확인할 수 있어요.",
                          contents: UIImage(named: "Tutorial_Two") ?? UIImage(systemName: "doc.text")!,
                          btnTitle: "다음 4/5"
                         ),
                    .init(title: "지하철 역을 추가할 때 원하지 않는 행선지는 제거하고 확인할 수 있어요.",
                          contents: UIImage(named: "Tutorial_Two") ?? UIImage(systemName: "doc.text")!,
                          btnTitle: "다음 5/5"
                         ),
                ])
            ])
            return Disposables.create()
        }
    }
}
