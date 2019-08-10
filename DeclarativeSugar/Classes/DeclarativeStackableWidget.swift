//
//  DeclarativeStackableWidget.swift
//  DeclarativeSugar
//
//  Created by Darren Zheng on 2019/8/9.
//

import UIKit

public class DZRow: UIView, DZStackableWidget {
    
    public var children: [DZWidget]
    public var stackView = UIStackView()
    public init(mainAxisAlignment: UIStackView.Distribution? = .fill,
                crossAxisAlignment: UIStackView.Alignment? = .fill,
                children: [DZWidget?]) {
        self.children = children.compactMap {$0}
        super.init(frame: .zero)
        
        addSubview(stackView)
        stackView.distribution = mainAxisAlignment ?? .fill
        stackView.alignment = crossAxisAlignment ?? .fill
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: .directionMask, metrics: nil, views: ["stackView":stackView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: .directionMask, metrics: nil, views: ["stackView":stackView]))
        buildStackView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var intrinsicContentSize: CGSize {
        return stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
}

public class DZColumn: UIView, DZStackableWidget {
    
    public var children: [DZWidget]
    public var stackView = UIStackView()
    
    public init(mainAxisAlignment: UIStackView.Distribution? = .fill,
                crossAxisAlignment: UIStackView.Alignment? = .fill,
                children: [DZWidget?])  {
        self.children = children.compactMap {$0}
        super.init(frame: .zero)
        
        addSubview(stackView)
        stackView.distribution = mainAxisAlignment ?? .fill
        stackView.alignment = crossAxisAlignment ?? .fill
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: .directionMask, metrics: nil, views: ["stackView":stackView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: .directionMask, metrics: nil, views: ["stackView":stackView]))
        buildStackView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var intrinsicContentSize: CGSize {
        return stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}

