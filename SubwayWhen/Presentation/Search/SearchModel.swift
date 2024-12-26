//
//  SearchModel.swift
//  SubwayWhen
//
//  Created by 이윤수 on 2022/11/28.
//

import Foundation

import RxSwift
import RxCocoa
import FirebaseDatabase

class SearchModel : SearchModelProtocol{
    let totalLoadModel : TotalLoadProtocol
    
    init(
        model : TotalLoadModel = .init()
    ){
        self.totalLoadModel = model
    }
    
    func fireBaseDefaultViewListLoad() -> Observable<[DefaultSectionData]>{
        let stringList = self.totalLoadModel.defaultViewListLoad()
        return stringList.map { data in
            data.map {
                DefaultCellData(title: $0)
            }
        }
        .map {
            [DefaultSectionData(id: UUID().uuidString, items: $0)]
        }
    }
    
    func stationNameSearchRequest(_ name : String) -> Observable<SearchStaion>{
        self.totalLoadModel.stationNameSearchReponse(name)
    }
    
    func searchStationToResultVCSection(_ searchData : SearchStaion) -> [ResultVCSection]{
        
        let data = searchData.SearchInfoBySubwayNameService.row
        // 기본 값 제거
        if data.count == 5 && data[0].stationName == "용답"{
            return []
        }else{
            let section = data.map{
                return ResultVCSection(section: "\($0.stationCode)\($0.lineCode)", items: [ResultVCCellData(stationName: $0.stationName, lineNumber: $0.lineNumber.rawValue, stationCode: $0.stationCode, useLine: $0.useLine, lineCode: $0.lineCode)])
            }
            return section
        }
    }
    
  
}
