//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport

class MyViewController : DeclarativeViewController {
    
    override func build() -> DZWidget {
        return DZPadding(
            edgeInsets: UIEdgeInsets.only(left: 30, top: 30, right: 30, bottom: 20),
            child: DZColumn(
                mainAxisAlignment: .equalCentering,
                crossAxisAlignment: .fill,
                children: [
                    DZColumn(
                        crossAxisAlignment: .fill,
                        children: [
                            UILabel().then {
                                $0.text = "Hello world1"
                                $0.font = UIFont.systemFont(ofSize: 24)
                            },
                            DZSpacer(30),
                            UITextField().then {
                                $0.placeholder = "请输入手机号"
                                $0.borderStyle = .roundedRect
                            },
                            DZSpacer(15),
                            UITextField().then {
                                $0.placeholder = "请输入密码"
                                $0.borderStyle = .roundedRect
                            },
                            DZSpacer(20),
                            DZRow(
                                mainAxisAlignment: .equalCentering,
                                children: [
                                    UILabel().then {
                                        $0.text = "验证码登录"
                                        $0.font = UIFont.systemFont(ofSize: 12)
                                        $0.textColor = UIColor.gray
                                    },
                                    UILabel().then {
                                        $0.text = "忘记密码"
                                        $0.font = UIFont.systemFont(ofSize: 12)
                                        $0.textColor = UIColor.gray
                                    }
                                ]),
                        ]),
                    DZColumn(
                        crossAxisAlignment: .center,
                        children: [
                            UILabel().then {
                                $0.text = "更多登录方式"
                                $0.font = UIFont.systemFont(ofSize: 12)
                                $0.textColor = UIColor.gray
                            }]),
                ]))
        
    }
    
}
// Present the view controller in the Live View window
let vc = MyViewController()
vc.view.backgroundColor = UIColor.white
PlaygroundPage.current.liveView = vc
