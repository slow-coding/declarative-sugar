//
//  DeclarativeListView.swift
//  DeclarativeSugar
//
//  Created by Darren Zheng on 2019/8/5.
//

import UIKit

public class DZListSection: UIView {
    public var headerView: UIView? = nil
    public var footerView: UIView? = nil
    public var headerTitle: String? = nil
    public var footerTitle: String? = nil
    public var headerHeight: CGFloat = 0
    public var footerHeight: CGFloat = 0
    public var rows: [DZListCell] = []
    
    public init(rows: [DZListCell]) {
        self.rows = rows
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class DZListCell: UIView {
    public var widget: DZWidget
    public var configureCell: ((UITableViewCell) -> Void)? = nil
    public var identifier: String = String(Int.random(in: 0 ... 9999))
    public var cellClass: AnyClass? = nil
    public var onTap: ((IndexPath) -> Void)? = nil
    public var willDisplay: ((IndexPath) -> Void)? = nil
    public var shouldHighlightRow: ((IndexPath) -> Bool)? = nil
    private var currentCell: UITableViewCell? = nil
    
    public init(widget: DZWidget) {
        self.widget = widget
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    public convenience init(tableView: UITableView, rows: [DZListCell]) {
        self.init(tableView: tableView, sections: [DZListSection(rows: rows)])
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
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = sections[indexPath.section].rows[indexPath.row]
        row.willDisplay?(indexPath)
    }
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let row = sections[indexPath.section].rows[indexPath.row]
        return row.shouldHighlightRow?(indexPath) ?? false
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
        let rootView = DZContext(rootWidget: row.widget).rootView
        contentView.addSubview(rootView)
        rootView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[rootView]|", options: .directionMask, metrics: nil, views: ["rootView":rootView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[rootView]|", options: .directionMask, metrics: nil, views: ["rootView":rootView]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
