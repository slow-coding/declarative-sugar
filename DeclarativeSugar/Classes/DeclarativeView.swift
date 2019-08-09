//
//  DeclarativeView.swift
//  DeclarativeSugar
//
//  Created by Darren Zheng on 2019/8/5.
//

import UIKit

open class DeclarativeView: UIView {
    open func build() -> DZWidget { return DZColumn(children:[]) }
    open lazy var context: DZContext = DZContext(rootWidget: build())
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        context = DZContext(rootWidget: build())
        guard let rootView = context.rootView else { return }
        addSubview(rootView)
        rootView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[rootView]|", options: .directionMask, metrics: nil, views: ["rootView":rootView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[rootView]|", options: .directionMask, metrics: nil, views: ["rootView":rootView]))
    }
    public func rebuild(_ block: () -> Void) {
        block()
        guard let rootView = context.rootView else { return }
        rootView.removeFromSuperview()
        context = DZContext(rootWidget: build())
    }
}
