# DeclarativeSugar

> a Flutter-like declarative syntax sugar based on Swift and UIStackView  

[中文介绍](https://juejin.im/post/5d47ec49e51d45620b21c35c)

## Screenshot

![](2019-08-05-13-56-56.png)

## Feature List

- [x] Declarative UI
- [x] Hide `UIStackView` complexity, use Flutter-ish API instead
- [x] composable view-hierachy as same as `UIStackView`
- [x] entry point `build()` and update method `rebuild()`   
- [x] `Row/Column`, `Spacer` (`sizedBox` in Flutter)
- [x] `ListView` (`UITableView` in UIKit) #2019-08-03
- [x] `Padding` #2019-08-05
- [ ] `UICollectionView` #in coming

**Depolyment**: iOS 9, Swift 5  
**Dependency**: UIKit (*nothing else*)  

But I would suggest using [Then](https://github.com/devxoul/Then) for writing cleaner initializer.

## Setup

### Inherite `DeclarativeViewController` or `DeclarativeView`

``` swift
class ViewController: DeclarativeViewController {
    ...
}
```

### Provide your own view-hierachy

``` swift
override func build() -> DZWidget {
    return ...
}
```

## Layout

### Row

Layout views horizontally

``` swift
DZRow(
    mainAxisAlignment: ... // UIStackView.Distribution
    crossAxisAlignment: ... // UIStackView.Alignment
    children: [
       ...
    ])
```

### Column

Layout views vertically

``` swift
DZColumn(
    mainAxisAlignment: ... // UIStackView.Distribution
    crossAxisAlignment: ... // UIStackView.Alignment
    children: [
       ...
    ])
```

### Padding

Set padding for child widget

#### only

``` swift
 DZPadding(
    edgeInsets: DZEdgeInsets.only(left: 10, top: 8, right: 10, bottom: 8),
    child: UILabel().then { $0.text = "hello world" }
 ),
```

#### symmetric

``` swift
 DZPadding(
    edgeInsets: DZEdgeInsets.symmetric(vertical: 10, horizontal: 20),
    child: UILabel().then { $0.text = "hello world" }
 ),
```

#### all

``` swift
 DZPadding(
    edgeInsets: DZEdgeInsets.all(16),
    child: UILabel().then { $0.text = "hello world" }
 ),
```

### Spacer

For `Row`: it is a `SizedBox` with width value.

```
DZRow(
    children: [
        ...
        DZSpacer(20), 
        ...
    ]
)
```

For `Column`: it is a `SizedBox` with height value.

```
DZColumn(
    children: [
        ...
        DZSpacer(20), 
        ...
    ]
)
```

### ListView

Generally, you don't need delegate/datasource pattern and UITableViewCell

#### Static ListView

```
 DZListView(
    tableView: UITableView(),
    sections: [
        DZListSection(
            rows: [
                DZListCell(
                    widget: ...,
                DZListCell(
                    widget: ...,
            ]),
        DZListSection(
            rows: [
                DZListCell(widget: ...) }
            ])
    ])
```

#### Dynamic ListView

Using `rows:` for single section list view

``` swift

var models = ["a", "b", "c", "d", "e"]

return DZListView(
    tableView: UITableView(),
    rows: models.map { model in DZListCell(widget: UILabel().then { $0.text = model })})
    .then { view.addSubview($0); $0.snp.makeConstraints { $0.edges.equalToSuperview() }}
```

## Rebuild

### Update state (reset)

``` swift
self.rebuild {
    self.hide = !self.hide
}
```

### Update state (incremental)

``` swift
UIView.animate(withDuration: 0.5) {
    // incremental reload
    self.hide = !self.hide
    self.context.setSpacing(self.hide ? 50 : 10, for: self.spacer)
    self.context.setHidden(self.hide, for: self.label)
}
```

## Code Structure

![](2019-08-05-15-26-11.png)

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
