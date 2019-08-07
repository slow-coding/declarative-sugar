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
        addSubview(context.rootView)
        context.rootView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[rootView]|", options: .directionMask, metrics: nil, views: ["rootView":context.rootView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[rootView]|", options: .directionMask, metrics: nil, views: ["rootView":context.rootView]))
    }
    public func rebuild(_ block: () -> Void) {
        block()
        context.rootView.removeFromSuperview()
        context = DZContext(rootWidget: build())
    }
}
