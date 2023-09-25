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
                    .init(title: "버튼을 누르거나 스크롤 하여, 민실씨의 기능을 확인해보세요!", contents: UIImage(systemName: "doc.text")!, btnTitle: "다음"),
                    .init(title: "테스트1", contents: UIImage(systemName: "doc.text")!, btnTitle: "테스트2"),
                    .init(title: "테스트2\n테스트2", contents: UIImage(systemName: "doc.text")!, btnTitle: "완료")
                ])
            ])
            return Disposables.create()
        }
    }
}
