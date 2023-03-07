//
//  ReportCheckModalViewModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2023/02/21.
//

import Foundation

import RxSwift
import RxCocoa

class ReportCheckModalViewModel{
    // INPUT
    let msgData = BehaviorSubject<ReportMSGData>(value: .init(line: .not, nowStation: "", destination: "", trainCar: "", contants: "", brand: ""))
    let okBtnClick = PublishRelay<Void>()
    
    // OUTPUT
    let msg : Driver<String>
    let number : Driver<String>
    
    init(){
        self.msg = self.msgData
            .map{ data -> String in
            let nowHour = Calendar.current.component(.hour, from: Date())
            let nowMin = Calendar.current.component(.minute, from: Date())
        
              return  """
            호선: \(data.line.rawValue)
            행선지: \(data.destination)행
            열차번호(칸 위치): \(data.trainCar)
            현재위치: (\(nowHour)시 \(nowMin)분) \(data.nowStation)역
            \(data.contants)
            """
            }
            .asDriver(onErrorDriveWith: .empty())
        
        self.number = self.okBtnClick
            .withLatestFrom(self.msgData)
            .map{data in
                if data.line == .two || data.line == .five || data.line == .six || data.line == .seven || data.line == .eight || (data.line == .one && data.brand == "Y") || (data.line == .three && data.brand == "N") || (data.line == .four && data.brand == "N"){
                    // 서울교통공사
                    return "1577-1234"
                }else if data.line == .nine{
                    // 9호선
                    return "1544-4009"
                }else if data.line == .shinbundang{
                    // 신분당선
                    return "031-8018-7777"
                }else if data.line == .gyeongui || data.line == .gyeongchun || data.line == .airport || data.line == .suinbundang || (data.line == .one && data.brand == "N") || (data.line == .three && data.brand == "Y") || (data.line == .four && data.brand == "Y"){
                    // 코레일
                    return "1544-7769"
                }else {
                    return ""
                }
            }
            .asDriver(onErrorDriveWith: .empty())
    }

    deinit{
        print("ReportCheckModalViewModel DEINIT")
    }
}
