/*
 DeclarativeViewController -> Context -> Stack -> StackItem
 */

import UIKit



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
    public init(mainAxisAlignment: UIStackView.Distribution = .fillProportionally,
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


public class DZListSection: NSObject {
    public var headerView: UIView? = nil
    public var footerView: UIView? = nil
    public var headerTitle: String? = nil
    public var footerTitle: String? = nil
    public var headerHeight: CGFloat = 0
    public var footerHeight: CGFloat = 0
    public var rows: [DZListCell] = []
    
    public init(rows: [DZListCell]) {
        self.rows = rows
    }
}

public class DZListCell: NSObject {
    public var stack: DZStack
    public var configureCell: ((UITableViewCell) -> Void)? = nil
    public var identifier: String = String(Int.random(in: 0 ... 9999))
    public var cellClass: AnyClass? = nil
    public var height: CGFloat? = nil
    public var estimatedHeight: CGFloat? = nil
    public var onTap: ((IndexPath) -> Void)? = nil
    public var willDisplay: ((IndexPath) -> Void)? = nil
    public var shouldHighlightRow: ((IndexPath) -> Void)? = nil
    private var currentCell: UITableViewCell? = nil
    
    public init(stack: DZStack) {
        self.stack = stack
    }
    
}


public class DZListView: UIView {
    
    let sections: [DZListSection]
    let tableView: UITableView
    
    public init(tableView: UITableView, sections: [DZListSection]) {
        self.sections = sections
        self.tableView = tableView
        
        super.init(frame: .zero)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: .directionMask, metrics: nil, views: ["tableView":tableView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: .directionMask, metrics: nil, views: ["tableView":tableView]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension DZListView: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sections[section].headerView
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return sections[section].footerView
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].headerTitle
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footerTitle
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sections[section].footerHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].headerHeight
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]
        let identifier = row.identifier
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = DZListBaseCell(row: row, style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
        }
        row.configureCell?(cell!)
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = sections[indexPath.section].rows[indexPath.row]
        row.onTap?(indexPath)
    }
}

public class DZListBaseCell: UITableViewCell {
    
    let row: DZListCell
    init(row: DZListCell, style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.row = row
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        if let stack = DZContext(child: row.stack).child as? UIView {
            contentView.addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stack]|", options: .directionMask, metrics: nil, views: ["stack":stack]))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stack]|", options: .directionMask, metrics: nil, views: ["stack":stack]))
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
