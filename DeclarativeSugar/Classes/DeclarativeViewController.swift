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
        setup()
        if let appBar = context.rootWidget as? DZAppBar {
            self.title = appBar.title
            self.navigationItem.rightBarButtonItem = appBar.rightBarButtonItem
        }
    }
    
    private func setup()  {
        context = DZContext(rootWidget: build())
        guard let rootView = context.rootView else { return }
        view.addSubview(rootView)
        view.backgroundColor = UIColor.white
        rootView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[rootView]|", options: .directionMask, metrics: nil, views: ["rootView":rootView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[rootView]|", options: .directionMask, metrics: nil, views: ["rootView":rootView]))
    }
    
    public func setState(_ block: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            block?()
            guard let rootView = self.context.rootView else { return }
            rootView.removeFromSuperview()
            self.setup()
        }
    }

}
