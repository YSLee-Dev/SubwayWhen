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
                    .init(title: "환영합니다 👏",
                          contents: UIImage(systemName: "doc.text")!,
                          btnTitle: "지하철 민실씨 알아보기"
                         ),
                    .init(title: "홈화면의 + 버튼이나, 검색 버튼을 이용하여 선호하는 지하철역을 추가할 수 있어요.",
                          contents: UIImage(named: "Tutorial_One") ?? UIImage(systemName: "doc.text")!,
                          btnTitle: "다음 1/5"
                         ),
                    .init(title: "지하철역을 추가할 때 원하지 않는 행선지는 제외 할 수 있어요.",
                          contents: UIImage(named: "Tutorial_Two") ?? UIImage(systemName: "doc.text")!,
                          btnTitle: "다음 2/5"
                         ),
                    .init(title: "상세화면에서는 제외했던 행선지를 포함해서 일회성으로 확인할 수 있어요.",
                          contents: UIImage(named: "Tutorial_Three") ?? UIImage(systemName: "doc.text")!,
                          btnTitle: "다음 3/5"
                         ),
                    .init(title: "출퇴근 시간에 맞춰서 알림을 받고, 해당 그룹으로 이동할 수 있어요.",
                          contents: UIImage(named: "Tutorial_Four") ?? UIImage(systemName: "doc.text")!,
                          btnTitle: "다음 4/5"
                         ),
                    .init(title: "지하철 민원 접수 시 원하는 메시지를 직접 보낼 수 있어요.",
                          contents: UIImage(named: "Tutorial_Five") ?? UIImage(systemName: "doc.text")!,
                          btnTitle: "다음 5/5"
                         ),
                    .init(title: "버튼을 눌러 민실씨를 바로 사용해 보세요!",
                          contents: UIImage(systemName: "doc.text")!,
                          btnTitle: "시작하기"
                         )
                ])
            ])
            return Disposables.create()
        }
    }
}
