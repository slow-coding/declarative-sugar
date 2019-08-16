/*
 DeclarativeViewController -> Context -> Stack -> StackItem
 */

import UIKit

/// Root type, nothing fancy.
public protocol DZWidget {}

extension DZWidget {
    
    // find first UIView in view hierachy
    public func toView(_ widget: DZWidget? = nil) -> UIView? {
        
        if let view = self as? UIView {
            return view
        }
        
        if let sChild = (widget ?? self) as? DZSingleChildWidget {
            if let view = sChild.child as? UIView {
                return view
            }
            else if sChild.child is DZSingleChildWidget {
                return toView(sChild.child)
            }
        }
        
        return nil
    }
    
    // find innermost UIView in view hierachy
    // cast return value to real type: UIView or UIView's subtypes
    public func findRootView(_ widget: DZWidget? = nil) -> DZWidget? {
        if let sChild = (widget ?? self) as? DZSingleChildWidget {
            if sChild.child is DZSingleChildWidget {
                return findRootView(sChild.child)
            }
            else {
                return sChild.child
            }
        }
        return self
    }
    
}

// A widget can be a UIView
extension UIView: DZWidget {}

// A widget can be a class with another widget
public protocol DZSingleChildWidget: DZWidget {
    var child: DZWidget { get set }
}

// A widget can be a class with a stack of widgets
public protocol DZStackableWidget: DZWidget {
    var children: [DZWidget] { get set }
    var stackView: UIStackView { get set }
}

extension DZStackableWidget {
    
    public func buildStackView() {
        var previousView: UIView?
        for (index, viewType) in children.enumerated() {
            if let spacing = viewType as? DZSpacer {
                let spacingValue = spacing.spacing
                if let previousViewValue = previousView {
                    stackView.addCustomSpacing(spacingValue, after: previousViewValue)
                    if index == children.count - 1 {
                        let mockView = UIView()
                        stackView.addArrangedSubview(mockView)
                        previousView = mockView
                        stackView.addCustomSpacing(spacingValue, after: mockView)
                    }
                }
                else {
                    let mockView = DZMockView()
                    stackView.addArrangedSubview(mockView)
                    previousView = mockView
                    stackView.addCustomSpacing(spacingValue, after: mockView)
                }
            }
            if let view = viewType.toView()  {
                stackView.addArrangedSubview(view)
                previousView = view
            }
            
        }
    }
    
}

/// A context dealing with UIStackView
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
    
    public var rootView: UIView? {
        
        if let stackable = rootWidget as? DZStackableWidget {
            return stackable.stackView
        }
        
        if let view = rootWidget as? UIView {
            return view
        }
        
        if let sChild = rootWidget as? DZSingleChildWidget,
            let view = sChild.child as? UIView {
            return view
        }
        
        return nil
    }
    
    private func findCurrentStackView(item: DZWidget) -> UIStackView? {
        return (item as? UIView)?.superview as? UIStackView
    }
    
    private func findPreviousView(_ item: DZWidget) -> UIView? {
        guard
            let currentStackView = findCurrentStackView(item: item),
            let item  = item as? UIView,
            let currentIndex = currentStackView.arrangedSubviews.firstIndex(where: { $0 === item })
            else { return nil }
        return currentStackView.arrangedSubviews[0...currentIndex].last
    }
    
}

enum DZViewState<T> {
    case none
    case loading
    case data(T?)
}
