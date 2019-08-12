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
        guard let rootView = context.rootView else { return }
        view.addSubview(rootView)
        view.backgroundColor = UIColor.white
        rootView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[rootView]|", options: .directionMask, metrics: nil, views: ["rootView":rootView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[rootView]|", options: .directionMask, metrics: nil, views: ["rootView":rootView]))
        if let appBar = context.rootWidget as? DZAppBar {
            self.title = appBar.title
            self.navigationItem.rightBarButtonItem = appBar.rightBarButtonItem
        }
    }
    public func rebuild(_ block: (() -> Void)? = nil) {
        block?()
        guard let rootView = context.rootView else { return }
        rootView.removeFromSuperview()
        context = DZContext(rootWidget: build())
    }
}
