/*
 DeclarativeViewController -> Context -> Stack -> StackItem
 */

import UIKit

open class DeclarativeViewController: UIViewController {
    open func build() -> DZStack { return DZColumn(children:[]) }
    open lazy var context: DZContext = DZContext(child: build())
    override open func viewDidLoad() {
        super.viewDidLoad()
        context = DZContext(child: build())
    }
    public func rebuild(_ block: () -> Void) {
        block()
        context.rootView.removeFromSuperview()
        context = DZContext(child: build())
    }
}

open class DeclarativeView: UIView {
    open func build() -> DZStack { return DZColumn(children:[]) }
    open lazy var context: DZContext = DZContext(child: build())
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        context = DZContext(child: build())
    }
    public func rebuild(_ block: () -> Void) {
        block()
        context.rootView.removeFromSuperview()
        context = DZContext(child: build())
    }
}

public protocol DZStackItem: UIView {}

extension UIView: DZStackItem {}

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
    public var child: DZStack
    
    public init(child: DZStack) {
        self.child = child
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
        return child.stackView
    }
    
    private func findCurrentStackView(item: DZStackItem) -> UIStackView? {
        return item.superview as? UIStackView
    }
    
    private func findPreviousView(_ item: DZStackItem) -> UIView? {
        guard
            let currentStackView = findCurrentStackView(item: item),
            let currentIndex = currentStackView.arrangedSubviews.firstIndex(where: { $0 === item })
            else { return nil }
        return currentStackView.arrangedSubviews[0...currentIndex].last
    }
    
}

public protocol DZStack {
    var children: [DZStackItem] { get set }
    var stackView: UIStackView { get set }
}

extension DZStack {
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

public class DZRow: UIView, DZStack {
    
    public var children: [DZStackItem]
    public var stackView = UIStackView()
    public init(mainAxisAlignment: UIStackView.Distribution = .fill,
                crossAxisAlignment: UIStackView.Alignment = .top,
                children: [DZStackItem]) {
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

public class DZColumn: UIView, DZStack {
    
    public var children: [DZStackItem]
    public var stackView = UIStackView()
    
    public init(mainAxisAlignment: UIStackView.Distribution = .fill,
                crossAxisAlignment: UIStackView.Alignment = .leading,
                children: [DZStackItem])  {
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

class DZMockView: UIView { }

public extension UIStackView {
    
    // How can I create UIStackView with variable spacing between views?
    // https://stackoverflow.com/questions/32999159/how-can-i-create-uistackview-with-variable-spacing-between-views
    func addCustomSpacing(_ spacing: CGFloat, after arrangedSubview: UIView) {
        if #available(iOS 11.0, *) {
            self.setCustomSpacing(spacing, after: arrangedSubview)
        } else {
            if let index = self.arrangedSubviews.firstIndex(of: arrangedSubview) {
                let nextIndex = index+1
                if nextIndex < self.arrangedSubviews.count, let separatorView = self.arrangedSubviews[nextIndex] as? DZMockView {
                    separatorView.removeFromSuperview()
                }
                let separatorView = DZMockView(frame: .zero)
                separatorView.translatesAutoresizingMaskIntoConstraints = false
                switch axis {
                case .horizontal:
                    separatorView.widthAnchor.constraint(equalToConstant: spacing).isActive = true
                case .vertical:
                    separatorView.heightAnchor.constraint(equalToConstant: spacing).isActive = true
                @unknown default:
                    fatalError()
                }
                insertArrangedSubview(separatorView, at: nextIndex)
            }
        }
    }
    
    func removeCustomSpacing(after arrangedSubview: UIView) {
        addCustomSpacing(0, after: arrangedSubview)
    }
    
    func addArrangedSubviews(_ views: [UIView?]) {
        views
            .compactMap({ $0 })
            .forEach { addArrangedSubview($0) }
    }
    
    func insertArrangedSubview(_ view: UIView?, after: UIView?) {
        guard let after = after, let view = view else { return }
        guard let targetIndex = arrangedSubviews.firstIndex(of: after) else { return }
        if targetIndex <= arrangedSubviews.count - 1 {
            insertArrangedSubview(view, at: targetIndex)
        }
    }
    
    func insertArrangedSubview(_ view: UIView?, before: UIView?) {
        guard let before = before, let view = view else { return }
        guard let targetIndex = arrangedSubviews.firstIndex(of: before) else { return }
        if targetIndex > 0 {
            insertArrangedSubview(view, at: targetIndex)
        }
    }
    
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach { removeArrangedSubview($0) }
    }
    
    func setHidden(_ isHidden: Bool, arrangedSubview: UIView?) {
        guard let arrangedSubview = arrangedSubview else { return }
        if #available(iOS 11.0, *) {
            arrangedSubview.isHidden = isHidden
        } else {
            arrangedSubview.isHidden = isHidden
            if let index = self.arrangedSubviews.firstIndex(of: arrangedSubview) {
                let nextIndex = index+1
                if nextIndex < self.arrangedSubviews.count, let separatorView = self.arrangedSubviews[nextIndex] as? DZMockView {
                    separatorView.isHidden = isHidden
                }
                
                if isHidden {
                    for view in self.arrangedSubviews.reversed() {
                        if view.isHidden == isHidden {
                            continue
                        }
                        if view is DZMockView {
                            view.isHidden = isHidden
                        }
                        break
                    }
                }
                else {
                    let preIndex = index-1
                    if preIndex >= 0, let separatorView = self.arrangedSubviews[preIndex] as? DZMockView {
                        separatorView.isHidden = isHidden
                    }
                }
            }
        }
    }
    
}
