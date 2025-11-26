# JYProgressHUD

一个现代化的 iOS 进度指示器库，专为 iOS 17.0+ 设计。

## 特性

- ✅ 支持多种显示模式（不确定进度、确定进度、自定义视图、文本）
- ✅ 流畅的动画效果（淡入淡出、缩放）
- ✅ 支持 NSProgress 自动更新进度
- ✅ 完全使用 Swift 编写，类型安全
- ✅ 支持 iOS 17.0+，使用最新 API
- ✅ 简洁易用的 API
- ✅ 支持 CocoaPods 安装

## 要求

- iOS 17.0+
- Swift 5.9+
- Xcode 15.0+

## 安装

### CocoaPods

在 `Podfile` 中添加：

```ruby
pod 'JYProgressHUD', '~> 1.0.0'
```

然后运行：

```bash
pod install
```

## 使用方法

### 基本使用

```swift
import JYProgressHUD

// 显示不确定进度
let hud = JYProgressHUD.show(on: view)
hud.label.text = "Loading..."

// 在后台任务完成后隐藏
DispatchQueue.global().async {
    // 执行任务
    DispatchQueue.main.async {
        hud.hide(animated: true)
    }
}
```

### 显示进度

```swift
let hud = JYProgressHUD.show(on: view)
hud.mode = .determinate
hud.label.text = "Loading..."

DispatchQueue.global().async {
    var progress: Float = 0.0
    while progress < 1.0 {
        progress += 0.01
        DispatchQueue.main.async {
            hud.progress = progress
        }
        usleep(50000)
    }
    DispatchQueue.main.async {
        hud.hide(animated: true)
    }
}
```

### 使用 NSProgress

```swift
let hud = JYProgressHUD.show(on: view)
hud.mode = .determinate
hud.label.text = "Downloading..."

let progress = Progress(totalUnitCount: 100)
hud.progressObject = progress

// 配置取消按钮
hud.button.setTitle("Cancel", for: .normal)
hud.button.addTarget(progress, action: #selector(Progress.cancel), for: .touchUpInside)

DispatchQueue.global().async {
    while progress.fractionCompleted < 1.0 {
        if progress.isCancelled { break }
        progress.completedUnitCount += 1
        usleep(50000)
    }
    DispatchQueue.main.async {
        hud.hide(animated: true)
    }
}
```

### 自定义视图

```swift
let hud = JYProgressHUD.show(on: view)
hud.mode = .customView

let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
imageView.tintColor = .systemGreen
hud.customView = imageView
hud.label.text = "Success!"

hud.hide(animated: true, afterDelay: 2.0)
```

### 文本提示

```swift
let hud = JYProgressHUD.show(on: view)
hud.mode = .text
hud.label.text = "Message here!"
hud.offset = CGPoint(x: 0, y: JYProgressMaxOffset)

hud.hide(animated: true, afterDelay: 3.0)
```

### 链式调用

```swift
let hud = JYProgressHUD.show(on: view)
    .withMode(.determinate)
    .withLabel("Loading...")
    .withProgress(0.5)
    .withAnimation(.zoom)
```

### UIView 扩展

```swift
// 显示
view.showProgressHUD()

// 隐藏
view.hideProgressHUD()

// 获取当前 HUD
if let hud = view.progressHUD() {
    hud.progress = 0.8
}
```

## API 文档

### JYProgressHUD

主要的 HUD 类。

#### 属性

- `mode: JYProgressHUDMode` - 显示模式
- `animationType: JYProgressHUDAnimation` - 动画类型
- `progress: Float` - 进度值 (0.0 - 1.0)
- `progressObject: Progress?` - NSProgress 对象
- `contentColor: UIColor?` - 内容颜色
- `label: UILabel` - 主标签
- `detailsLabel: UILabel` - 详情标签
- `button: JYProgressHUDRoundedButton` - 按钮
- `customView: UIView?` - 自定义视图

#### 方法

- `show(animated:)` - 显示 HUD
- `hide(animated:)` - 隐藏 HUD
- `hide(animated:afterDelay:)` - 延迟隐藏
- `showHUDAdded(to:animated:)` - 类方法：显示并添加到视图
- `hideHUD(for:animated:)` - 类方法：隐藏视图上的 HUD
- `HUD(for:)` - 类方法：查找视图上的 HUD

## 许可证

Apache License 2.0

Copyright 2025 上海即言软件开发有限公司

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## 作者

上海即言软件开发有限公司

