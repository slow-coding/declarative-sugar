# DeclarativeSugar

a Flutter-like declarative syntax sugar based on Swift and UIStackView

![](2019-08-05-13-56-56.png)

## Feature List

- [x] Declarative UI
- [x] Hide `UIStackView` complexity, use Flutter-ish API instead
- [x] Support composable view-hierachy as same as `UIStackView`
- [x] Support `build()` entry point and `rebuild()`   
- [x] Support `Row/Column`, , `Spacer` (`sizedBox` in Flutter)
- [x] Supoort `ListView` (`UITableView` in UIKit) 2019-08-03
- [x] Support `Padding` 2019-08-05

## Depolyment & Dependency

Depolyment: iOS 9, Swift 5
Dependency: UIKit, *nothing else*.

But I would suggest using [Then](https://github.com/devxoul/Then) for writing cleaner initializer.

## Usage

### 1. Inherite `DeclarativeViewController` or `DeclarativeView`

``` swift
class ViewController: DeclarativeViewController {
    ...
}
```

### 2. Provide your own view-hierachy

``` swift
override func build() -> DZWidget {
    return ...
}
```

### 3. Update state (full rebuild without animation)

``` swift
self.rebuild {
    self.hide = !self.hide
}
```

### 4. Update state (incremental update with animation)

``` swift
UIView.animate(withDuration: 0.5) {
    // incremental reload
    self.hide = !self.hide
    self.context.setSpacing(self.hide ? 50 : 10, for: self.spacer)
    self.context.setHidden(self.hide, for: self.label)
}
```

## Code Structure

![](2019-08-05-14-27-50.png)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

DeclarativeSugar is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DeclarativeSugar'
```

## Author

Darren Zheng 623767307@qq.com

## License

DeclarativeSugar is available under the MIT license. See the LICENSE file for more info.
