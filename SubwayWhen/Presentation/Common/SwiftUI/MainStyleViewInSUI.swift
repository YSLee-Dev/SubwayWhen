//
//  MainStyleViewInSUI.swift
//  SubwayWhen
//
//  Created by 이윤수 on 8/26/24.
//

import SwiftUI

struct MainStyleViewInSUI<Contents>: View where Contents: View {
    @ViewBuilder var contents: Contents
    
    var body: some View {
        self.contents
            .background {
                RoundedRectangle(cornerRadius: ViewStyle.Layer.radius)
                    .fill(Color("MainColor"))
            }
    }
}
