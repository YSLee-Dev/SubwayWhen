//
//  ExpandedViewInSUI.swift
//  SubwayWhen
//
//  Created by 이윤수 on 12/6/24.
//

import SwiftUI

struct ExpandedViewInSUI<Contents>: View where Contents: View {
    let alignment: HorizontalAlignment
    @ViewBuilder let view: () -> Contents
    
    var body: some View {
        HStack(spacing: 0) {
            if self.alignment != .leading {
                Spacer()
            }
            self.view()
            if self.alignment != .trailing {
                Spacer()
            }
        }
    }
}

