//
//  DeclarativeViewController.swift
//  DeclarativeSugar
//
//  Created by Darren Zheng on 2019/8/5.
//

import UIKit

open class DeclarativeViewController: UIViewController {
    open func build() -> DZWidget { return DZColumn(children:[]) }
    open lazy var context: DZContext = DZContext(rootWidget: build())
    override open func viewDidLoad() {
        super.viewDidLoad()
        context = DZContext(rootWidget: build())
    }
    public func rebuild(_ block: () -> Void) {
        block()
        context.rootView.removeFromSuperview()
        context = DZContext(rootWidget: build())
    }
}
