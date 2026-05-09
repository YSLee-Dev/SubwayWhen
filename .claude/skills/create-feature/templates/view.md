# {Name}View.swift 템플릿

```swift
//
//  {Name}.swift
//  {타겟}
//
//  Created by 이윤수 on {날짜: MM/DD/YY}
//

import SwiftUI
import ComposableArchitecture

struct {Name}View: View {
    
    // MARK: - Properties
    
    @Bindable var store: StoreOf<{Name}Feature>
    
    // MARK: - View
    
    var body: some View {
        EmptyView()
            .onAppear {
                store.send(.onAppear)
            }
    }
}

#Preview {
    {Name}View(
        store: .init(
            initialState: {Name}Feature.State(),
            reducer: { {Name}Feature() }
        )
    )
}
```
