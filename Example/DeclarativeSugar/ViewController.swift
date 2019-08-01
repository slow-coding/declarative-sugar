//
//  ViewController.swift
//  DeclarativeSugar
//
//  Created by 623767307@qq.com on 08/01/2019.
//  Copyright (c) 2019 623767307@qq.com. All rights reserved.
//

import UIKit
import SnapKit
import DeclarativeSugar
import Then

class ViewController: DeclarativeViewController {
    
    var label = UILabel().then { $0.text = "hello world" }
    var spacer = DZSpacer(10);
    var hide = false

    override func build() -> DZStack {
        return DZColumn(
            crossAxisAlignment: .leading,
            children: [
                DZRow(
                    crossAxisAlignment: .bottom,
                    children: [
                        UILabel().then { $0.text = "hello world"; $0.isHidden = self.hide },
                        UIView().then {
                            $0.backgroundColor = .red
                            $0.snp.makeConstraints { make in
                                make.size.equalTo(CGSize(width: 50, height: 100))
                            }
                        },
                        DZSpacer(40),
                        UIView().then {
                            $0.backgroundColor = .blue
                            $0.snp.makeConstraints { make in
                                make.size.equalTo(CGSize(width: 50, height: 50))
                            }
                        },
                    ]),
                DZSpacer(self.hide ? 10 : 50),
                UIView().then {
                    $0.backgroundColor = .orange
                    $0.snp.makeConstraints { make in
                        make.size.equalTo(CGSize(width: 50, height: 50))
                    }
                },
                DZSpacer(10),
                UILabel().then {
                    $0.numberOfLines = 0
                    $0.text =
                    """
                    Swift is a general-purpose, multi-paradigm, compiled programming language created for iOS, OS X, watchOS, tvOS and Linux development by Apple Inc. Swift is designed to work with Apple's Cocoa and Cocoa Touch frameworks and the large body of existing Objective-C code written for Apple products
                    """
                },
            ])
            .then {
                view.addSubview($0)
                $0.snp.makeConstraints {
                    $0.top.equalToSuperview().offset(300)
                    $0.left.right.equalToSuperview()
                }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.rebuild {
            self.hide = !self.hide
        }
    }
    
    
}


