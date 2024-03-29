//
//  AppIntent.swift
//  SubwayWhenHomeWidget
//
//  Created by 이윤수 on 3/28/24.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "위젯에서 보고 싶은 지하철역을 골라주세요."
    
    @Parameter(title: "지하철역 선택", optionsProvider: SaveStationProvider())
    var seletedStation: String
    
    struct SaveStationProvider: DynamicOptionsProvider {
        typealias Result = [String]
        
        func results() async throws -> Result {
            guard let data = UserDefaults.shared.data(forKey: "saveStation") ,
                  let list = try? PropertyListDecoder().decode([SaveStation].self, from: data)
            else {return []}
            
            return list.map {$0.widgetUseText}
        }
    }
}

