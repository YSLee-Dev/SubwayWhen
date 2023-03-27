//
//  ReportContentsModalModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/03/27.
//

import Foundation

import RxSwift

class ReportContentsModalModel : ReportContentsModalModelProtocol{
    func reportList() -> Observable<[ReportContentsModalSection]>{
        Observable<[ReportContentsModalSection]>.create{
            let data : [ReportContentsModalCellData] = [
                .init(title: "차내 온도 높음", iconName: "thermometer.sun", contents: "차내 온도가 높습니다. 에어컨 조절 요청드립니다."),
                .init(title: "차내 온도 낮음", iconName: "thermometer.snowflake", contents: "차내 온도가 낮습니다. 난방 조절 요청드립니다."),
                .init(title: "차내 폭력 사건", iconName: "hand.raised.slash",  contents: "차내 폭력사건이 발생하였습니다."),
                .init(title: "차내 전도", iconName: "figure.wave",  contents: "차내 전도를 하고 있습니다."),
                .init(title: "차내 소음", iconName: "ear.trianglebadge.exclamationmark",  contents: "차내 소음을 유발하는 사람이 있습니다."),
                .init(title: "차내 취객", iconName: "figure.fall",  contents: "차내 취객이 있어 질서저해를 유발하고 있습니다."),
                .init(title: "차내 잡상인", iconName: "cart",  contents: "차내 잡상인이 물건을 팔고 있습니다."),
                .init(title: "차내 쓰레기", iconName: "trash",  contents: "차내 쓰레기가 널부러져 있습니다."),
                .init(title: "지연 심각", iconName: "tortoise",  contents: "열차 지연이 심각합니다. 정시운행 요청드립니다."),
            ]
            
            $0.onNext([.init(titleName: "", items: data)])
            
            $0.onCompleted()
            return Disposables.create()
        }
    }
}
