/*
 DeclarativeViewController -> Context -> Stack -> StackItem
 */

import UIKit

public protocol DZWidget: UIView {}
extension UIView: DZWidget {}

public protocol DZSingleChildWidget: DZWidget {
    var child: DZWidget { get set }
}

public protocol DZStackableWidget: DZWidget {
    var children: [DZWidget] { get set }
    var stackView: UIStackView { get set }
}

extension DZStackableWidget {
    public func buildStackView() {
        var previousView: UIView?
        for viewType in children {
            if let spacing = viewType as? DZSpacer {
                let spacingValue = spacing.spacing
                if let previousView = previousView {
                    stackView.addCustomSpacing(spacingValue, after: previousView)
                }
                else {
                    let mockView = UIView()
                    stackView.addArrangedSubview(mockView)
                    previousView = mockView
                    stackView.addCustomSpacing(spacingValue, after: mockView)
                }
            }
            stackView.addArrangedSubview(viewType)
            previousView = viewType
        }
    }
}



public struct DZEdgeInsets {
    
    public var left: CGFloat = 0
    public var top: CGFloat = 0
    public var right: CGFloat = 0
    public var bottom: CGFloat = 0
    public static func only(left: CGFloat = 0,
                            top: CGFloat = 0,
                            right: CGFloat = 0,
                            bottom: CGFloat = 0) -> DZEdgeInsets {
        var edgeInsets = DZEdgeInsets()
        edgeInsets.left = left
        edgeInsets.top = top
        edgeInsets.right = right
        edgeInsets.bottom = bottom
        return edgeInsets
    }
    
    public static func fromLTRB(left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat) -> DZEdgeInsets {
        return only(left: left, top: top, right: right, bottom: bottom)
    }
    
    public static func all(_ value: CGFloat) -> DZEdgeInsets {
        return only(left: value, top: value, right: value, bottom: value)
    }
    
    public static func symmetric(vertical: CGFloat = 0, horizontal: CGFloat = 0) -> DZEdgeInsets {
        return only(left: horizontal, top: vertical, right: horizontal, bottom: vertical)
    }
    
}


public class DZSpacer: UIView {
    
    public var spacing: CGFloat
    
    public init(_ spacing: CGFloat) {
        self.spacing = spacing
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class DZContext {
    public var rootWidget: DZWidget
    
    public init(rootWidget: DZWidget) {
        self.rootWidget = rootWidget
    }
    
    public func setHidden(_ hidden: Bool, for view: UIView) {
        guard
            let currentStackView = findCurrentStackView(item: view)
            else { return }
        currentStackView.setHidden(hidden, arrangedSubview: view)
    }
    
    public func setSpacing(_ newValue: CGFloat, for spacer: DZSpacer) {
        guard
            let currentStackView = findCurrentStackView(item: spacer)
            else { return }
        spacer.spacing = newValue
        if let view = findPreviousView(spacer) {
            currentStackView.addCustomSpacing(spacer.spacing, after: view)
        }
    }
    
    public var rootView: UIView {
        if let single = rootWidget as? DZSingleChildWidget {
            return single
        }
            
        if let stackable = rootWidget as? DZStackableWidget {
            return stackable.stackView
        }
   
        return UIView()
    }
    
    private func findCurrentStackView(item: DZWidget) -> UIStackView? {
        return item.superview as? UIStackView
    }
    
    private func findPreviousView(_ item: DZWidget) -> UIView? {
        guard
            let currentStackView = findCurrentStackView(item: item),
            let currentIndex = currentStackView.arrangedSubviews.firstIndex(where: { $0 === item })
            else { return nil }
        return currentStackView.arrangedSubviews[0...currentIndex].last
    }
    
}


public class DZRow: UIView, DZStackableWidget {
    
    public var children: [DZWidget]
    public var stackView = UIStackView()
    public init(mainAxisAlignment: UIStackView.Distribution = .fillProportionally,
                crossAxisAlignment: UIStackView.Alignment = .leading,
                children: [DZWidget]) {
        self.children = children
        super.init(frame: .zero)
        
        addSubview(stackView)
        stackView.alignment = crossAxisAlignment
        stackView.distribution = mainAxisAlignment
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: .directionMask, metrics: nil, views: ["stackView":stackView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: .directionMask, metrics: nil, views: ["stackView":stackView]))
        buildStackView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public class DZColumn: UIView, DZStackableWidget {
    
    public var children: [DZWidget]
    public var stackView = UIStackView()
    
    public init(mainAxisAlignment: UIStackView.Distribution = .fill,
                crossAxisAlignment: UIStackView.Alignment = .top,
                children: [DZWidget])  {
        self.children = children
        super.init(frame: .zero)
        
        addSubview(stackView)
        stackView.alignment = crossAxisAlignment
        stackView.distribution = mainAxisAlignment
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: .directionMask, metrics: nil, views: ["stackView":stackView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: .directionMask, metrics: nil, views: ["stackView":stackView]))
        buildStackView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


public class DZPadding: UIView, DZSingleChildWidget {
    
    public var edgeInsets: DZEdgeInsets = DZEdgeInsets()
    
    public var child: DZWidget
    
    required public init(edgeInsets: DZEdgeInsets,
                         child: DZWidget)  {
        self.child = child
        self.edgeInsets = edgeInsets
        super.init(frame: .zero)
        
        
        addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        let metrics = [
            "left": edgeInsets.left,
            "right": edgeInsets.right,
            "top": edgeInsets.top,
            "bottom": edgeInsets.bottom,
        ]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-top-[child]-bottom-|", options: .directionMask, metrics: metrics, views: ["child":child]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-left-[child]-right-|", options: .directionMask, metrics: metrics, views: ["child":child]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
