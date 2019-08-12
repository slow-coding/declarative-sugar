//
//  DeclarativeSingleChildWidget.swift
//  DeclarativeSugar
//
//  Created by Darren Zheng on 2019/8/9.
//

import UIKit

public struct DZEdgeInsets {
    
    public var left: CGFloat?
    public var top: CGFloat?
    public var right: CGFloat?
    public var bottom: CGFloat?
    public static func only(left: CGFloat? = nil,
                            top: CGFloat? = nil,
                            right: CGFloat? = nil,
                            bottom: CGFloat? = nil) -> DZEdgeInsets {
        var edgeInsets = DZEdgeInsets()
        edgeInsets.left = left
        edgeInsets.top = top
        edgeInsets.right = right
        edgeInsets.bottom = bottom
        return edgeInsets
    }
    
    public static func fromLTRB(left: CGFloat?, top: CGFloat?, right: CGFloat?, bottom: CGFloat?) -> DZEdgeInsets {
        return only(left: left, top: top, right: right, bottom: bottom)
    }
    
    public static func all(_ value: CGFloat) -> DZEdgeInsets {
        return only(left: value, top: value, right: value, bottom: value)
    }
    
    public static func symmetric(vertical: CGFloat? = nil, horizontal: CGFloat? = nil) -> DZEdgeInsets {
        return only(left: horizontal, top: vertical, right: horizontal, bottom: vertical)
    }
    
}

public class DZPadding: UIView, DZSingleChildWidget {
    
    public var edgeInsets = DZEdgeInsets()
    
    public var child: DZWidget
    
    required public init(edgeInsets: DZEdgeInsets,
                         child: DZWidget)  {
        self.child = child
        self.edgeInsets = edgeInsets
        super.init(frame: .zero)
        
        guard let child = child.toView() else {
            return
        }
        
        addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        
        if edgeInsets.left != nil {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-left-[child]", options: .directionMask, metrics: [
                "left": edgeInsets.left ?? 0,
                ], views: ["child":child]))
        }
        if edgeInsets.right != nil {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[child]-right-|", options: .directionMask, metrics: [
                "right": edgeInsets.right ?? 0,
                ], views: ["child":child]))
        }
        
        if edgeInsets.top != nil {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-top-[child]", options: .directionMask, metrics: [
                "top": edgeInsets.top ?? 0,
                ], views: ["child":child]))
        }
        
        if edgeInsets.bottom != nil {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[child]-bottom-|", options: .directionMask, metrics: [
                "bottom": edgeInsets.bottom ?? 0,
                ], views: ["child":child]))
        }
        
        
    }
    
    public override var intrinsicContentSize: CGSize {
        return child.toView()?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public enum DZCenterDirection {
    case both, vertical, horizontal
}

public class DZCenter: UIView, DZSingleChildWidget {
    
    public var child: DZWidget
    
    required public init(
        direction: DZCenterDirection = .both,
        child: DZWidget)  {
        self.child = child
        super.init(frame: .zero)
        
        guard let child = child.toView() else {
            return
        }
        
        addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        
        if direction != .vertical  {
            let centerX = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: child, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
            addConstraint(centerX)
        }
        
        if direction != .horizontal {
            let centerY = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: child, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
            addConstraint(centerY)
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        return child.toView()?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class DZSizedBox: UIView, DZSingleChildWidget {
    
    public var child: DZWidget
    
    required public init(
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        child: DZWidget)  {
        self.child = child
        super.init(frame: .zero)
        
        guard let child = child.toView() else {
            return
        }
        
        addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        
        let widthVFL: String
        if let width = width {
            widthVFL = "H:|[child(\(width))]|"
        }
        else {
            widthVFL = "H:|[child]|"
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: widthVFL, options: .directionMask, metrics: nil, views: ["child":child]))
        
        let heightVFL: String
        if let height = height {
            heightVFL = "V:|[child(\(height))]|"
        }
        else {
            heightVFL = "V:|[child]|"
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: heightVFL, options: .directionMask, metrics: nil, views: ["child":child]))
    }
    
    public override var intrinsicContentSize: CGSize {
        return child.toView()?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public class DZStack: UIView, DZSingleChildWidget {
    
    public var child: DZWidget
    
    required public init(
        edgeInsets: DZEdgeInsets? = nil,
        direction: DZCenterDirection? = nil,
        base: DZWidget,
        target: DZWidget)  {
        self.child = base
        super.init(frame: .zero)
        
        guard let base = base.toView(), let target = target.toView() else {
            return
        }
        
        addSubview(base)
        base.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[base]|", options: .directionMask, metrics: nil, views: ["base":base]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[base]|", options: .directionMask, metrics: nil, views: ["base":base]))
        
        base.addSubview(target)
        target.translatesAutoresizingMaskIntoConstraints = false
        
        if direction != nil, direction != .vertical  {
            let centerX = NSLayoutConstraint(item: base, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: target, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
            base.addConstraint(centerX)
        }
        
        if direction != nil, direction != .horizontal {
            let centerY = NSLayoutConstraint(item: base, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: target, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
            base.addConstraint(centerY)
        }
        
        guard let edgeInsets = edgeInsets else {
            return
        }
        if edgeInsets.left != nil {
            base.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-left-[target]", options: .directionMask, metrics: [
                "left": edgeInsets.left ?? 0,
                ], views: ["target":target]))
        }
        if edgeInsets.right != nil {
            base.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[target]-right-|", options: .directionMask, metrics: [
                "right": edgeInsets.right ?? 0,
                ], views: ["target":target]))
        }
        
        if edgeInsets.top != nil {
            base.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-top-[target]", options: .directionMask, metrics: [
                "top": edgeInsets.top ?? 0,
                ], views: ["target":target]))
        }
        
        if edgeInsets.bottom != nil {
            base.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[target]-bottom-|", options: .directionMask, metrics: [
                "bottom": edgeInsets.bottom ?? 0,
                ], views: ["target":target]))
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        return child.toView()?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class DZAppBar: DZSingleChildWidget {
    
    public var child: DZWidget
    public var title: String?
    public var rightBarButtonItem: UIBarButtonItem?
    
    required public init(
        title: String? = nil,
        rightBarButtonItem: UIBarButtonItem? = nil,
        child: DZWidget
        )  {
        self.child = child
        self.title = title
        self.rightBarButtonItem = rightBarButtonItem
    }
}

public class DZGestureDetector: UIView, DZSingleChildWidget {
    
    public var child: DZWidget
    var onTap: (() -> Void)?
    
    required public init(
        onTap: (() -> Void)?,
        child: DZWidget
        )  {
        self.child = child
        self.onTap = onTap
        
        super.init(frame: .zero)
        
        guard let child = child.toView() else {
            return
        }
        addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[child]|", options: .directionMask, metrics: nil, views: ["child":child]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[child]|", options: .directionMask, metrics: nil, views: ["child":child]))
        
        guard let view = child.findRootView() else {
            return
        }
        if let btn = view as? UIButton {
            btn.addTarget(self, action: #selector(DZGestureDetector.selectorOnTap), for: UIControl.Event.touchUpInside)
        }
        else if let view = view as? UIView {
            view.isUserInteractionEnabled = true
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectorOnTap))
            view.addGestureRecognizer(tapRecognizer)
        }
        
        
    }
    
    public override var intrinsicContentSize: CGSize {
        return child.toView()?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func selectorOnTap() {
        onTap?()
    }
}

