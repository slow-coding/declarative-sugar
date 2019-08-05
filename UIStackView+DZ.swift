//
//  UIStackView+DZ.swift
//  DeclarativeSugar
//
//  Created by Darren Zheng on 2019/8/5.
//

import UIKit

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
