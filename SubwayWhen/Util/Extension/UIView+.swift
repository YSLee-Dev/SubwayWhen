//
//  UIView+.swift
//  SubwayWhen
//
//  Created by 이윤수 on 11/4/25.
//

import UIKit
import RxSwift
import RxCocoa

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            self.addSubview($0)
        }
    }
}

extension Reactive where Base: UIView {
    var tapGesture: Observable<UITapGestureRecognizer> {
        let gesture = UITapGestureRecognizer()
        base.addGestureRecognizer(gesture)
        base.isUserInteractionEnabled = true
        
        return gesture.rx.event.asObservable()
    }
    
    var viewTap: Observable<Void> {
        self.tapGesture.map { _ in }
    }
}
