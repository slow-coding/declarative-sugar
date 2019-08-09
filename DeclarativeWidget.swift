//
//  DeclarativeNoneView.swift
//  DeclarativeSugar
//
//  Created by Darren Zheng on 2019/8/9.
//

import Foundation


public class DZSpacer: DZNonViewWidget {
    
    public var spacing: CGFloat
    
    public init(_ spacing: CGFloat) {
        self.spacing = spacing
    }
}
