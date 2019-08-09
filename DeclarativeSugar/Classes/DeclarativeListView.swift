//
//  DeclarativeListView.swift
//  DeclarativeSugar
//
//  Created by Darren Zheng on 2019/8/5.
//

import UIKit

public class DZSection: UIView {
    
    public var headerView: UIView?
    public var footerView: UIView?
    public var headerTitle: String?
    public var footerTitle: String?
    public var headerHeight: CGFloat?
    public var footerHeight: CGFloat?
    public var cells: [DZCell] = []
    
    public init(headerView: UIView? = nil,
                footerView: UIView? = nil,
                headerTitle: String? = nil,
                footerTitle: String? = nil,
                headerHeight: CGFloat? = 0,
                footerHeight: CGFloat? = 0,
                cells: [DZCell]) {
        self.cells = cells
        self.headerView = headerView
        self.footerView = footerView
        self.headerTitle = headerTitle
        self.footerTitle = footerTitle
        self.headerHeight = headerHeight
        self.footerHeight = footerHeight
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class DZCell: UIView {
    
    public var widget: DZWidget
    public var configureCell: ((UITableViewCell) -> Void)?
    public var identifier: String
    public var cellClass: AnyClass?
    public var onTap: ((IndexPath) -> Void)?
    public var willDisplay: ((IndexPath) -> Void)?
    public var shouldHighlightRow: ((IndexPath) -> Bool)?
    public var cellHeight: CGFloat? = nil
    
    private var currentCell: UITableViewCell? = nil
    
    public init(configureCell: ((UITableViewCell) -> Void)? = nil,
                identifier: String = String(Int.random(in: 0 ... 9999)),
                cellClass: AnyClass? = nil,
                onTap: ((IndexPath) -> Void)? = nil,
                willDisplay: ((IndexPath) -> Void)? = nil,
                shouldHighlightRow: ((IndexPath) -> Bool)? = nil,
                cellHeight: CGFloat? = nil,
                widget: DZWidget) {
        self.widget = widget
        self.configureCell = configureCell
        self.identifier = identifier
        self.cellClass = cellClass
        self.onTap = onTap
        self.willDisplay = willDisplay
        self.shouldHighlightRow = shouldHighlightRow
        self.cellHeight = cellHeight
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public class DZListView: UIView {
    
    let sections: [DZSection]
    let tableView: UITableView
    
    public init(tableView: UITableView, sections: [DZSection]) {
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
    
    public convenience init(tableView: UITableView, cells: [DZCell]) {
        self.init(tableView: tableView, sections: [DZSection(cells: cells)])
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
        return sections[section].footerHeight ?? 0
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].headerHeight ?? 0
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = sections[indexPath.section].cells[indexPath.row]
        return row.cellHeight ?? UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = sections[indexPath.section].cells[indexPath.row]
        row.willDisplay?(indexPath)
    }
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let row = sections[indexPath.section].cells[indexPath.row]
        return row.shouldHighlightRow?(indexPath) ?? false
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].cells[indexPath.row]
        let identifier = row.identifier
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = DZListBaseCell(row: row, style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
        }
        row.configureCell?(cell!)
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = sections[indexPath.section].cells[indexPath.row]
        row.onTap?(indexPath)
    }
}

public class DZListBaseCell: UITableViewCell {
    
    let row: DZCell
    init(row: DZCell, style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.row = row
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        guard let rootView = DZContext(rootWidget: row.widget).rootView else { return }
        contentView.addSubview(rootView)
        rootView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[rootView]|", options: .directionMask, metrics: nil, views: ["rootView":rootView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[rootView]|", options: .directionMask, metrics: nil, views: ["rootView":rootView]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
