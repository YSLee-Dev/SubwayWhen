//
//  SubwayWhenHomeWidgetBundle.swift
//  SubwayWhenHomeWidget
//
//  Created by 이윤수 on 3/28/24.
//

import WidgetKit
import SwiftUI
import Firebase

@main
struct SubwayWhenHomeWidgetBundle: WidgetBundle {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Widget {
        SubwayWhenHomeWidget()
    }
}
