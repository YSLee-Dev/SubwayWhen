//
//  LiveActivityWidgetBundle.swift
//  LiveActivityWidget
//
//  Created by 이윤수 on 2023/05/08.
//

import WidgetKit
import SwiftUI

@main
struct LiveActivityWidgetBundle: WidgetBundle {
    var body: some Widget {
        LiveActivityWidget()
        LiveActivityWidgetLiveActivity()
    }
}
