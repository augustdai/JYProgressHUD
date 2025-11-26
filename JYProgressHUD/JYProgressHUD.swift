//
//  JYProgressHUD.swift
//  JYProgressHUD
//
//  Created by fuyong.dai on 2025.11.27
//  Copyright © 2025. All rights reserved.
//

import UIKit
import Combine

/// JYProgressHUD 主类
/// 显示一个简单的 HUD 窗口，包含进度指示器和可选的标签
@MainActor
@objc public class JYProgressHUD: UIView {
    
    // MARK: - Public Properties
    
    /// 显示模式，默认为不确定进度
    @objc public var mode: JYProgressHUDMode = .indeterminate {
        didSet { updateIndicators() }
    }
    
    /// 动画类型，默认为淡入淡出
    @objc public var animationType: JYProgressHUDAnimation = .fade
    
    /// 进度值 (0.0 - 1.0)，默认为 0.0
    @objc public var progress: Float = 0.0 {
        didSet { updateProgress() }
    }
    
    /// NSProgress 对象，用于自动更新进度
    @objc public var progressObject: Progress? {
        didSet { observeProgress() }
    }
    
    /// 内容颜色（标签、指示器等）
    @objc public var contentColor: UIColor? {
        didSet { updateViewsForColor() }
    }
    
    /// Bezel 偏移量，相对于视图中心
    @objc public var offset: CGPoint = .zero {
        didSet { setNeedsUpdateConstraints() }
    }
    
    /// 边距，HUD 边缘与元素之间的空间
    @objc public var margin: CGFloat = 30.0 {  // 增大默认边距
        didSet { setNeedsUpdateConstraints() }
    }
    
    /// 最小尺寸
    @objc public var minSize: CGSize = CGSize(width: 120, height: 120) {  // 设置默认最小尺寸
        didSet { setNeedsUpdateConstraints() }
    }
    
    /// 是否强制为正方形
    @objc public var isSquare: Bool = false {
        didSet { setNeedsUpdateConstraints() }
    }
    
    /// Grace Time（延迟显示时间），如果任务在 graceTime 内完成，HUD 不会显示
    @objc public var graceTime: TimeInterval = 0.0
    
    /// 最小显示时间，避免 HUD 闪烁
    @objc public var minShowTime: TimeInterval = 0.0
    
    /// 隐藏时自动从父视图移除
    @objc public var removeFromSuperViewOnHide: Bool = false
    
    /// 委托
    @objc public weak var delegate: JYProgressHUDDelegate?
    
    /// 完成回调
    @objc public var completionBlock: (() -> Void)?
    
    /// 是否启用默认运动效果
    @objc public var defaultMotionEffectsEnabled: Bool = false {
        didSet { updateBezelMotionEffects() }
    }
    
    // MARK: - View Properties
    
    /// 背景视图
    @objc public private(set) var backgroundView: JYBackgroundView!
    
    /// Bezel 视图（包含内容的容器）
    @objc public private(set) var bezelView: JYBackgroundView!
    
    /// 主标签
    @objc public private(set) var label: UILabel!
    
    /// 详情标签
    @objc public private(set) var detailsLabel: UILabel!
    
    /// 按钮
    @objc public private(set) var button: JYProgressHUDRoundedButton!
    
    /// 自定义视图
    @objc public var customView: UIView? {
        didSet {
            if mode == .customView {
                updateIndicators()
            }
        }
    }
    
    // MARK: - Private Properties
    
    private var indicator: UIView?
    private var topSpacer: UIView!
    private var bottomSpacer: UIView!
    
    private var bezelConstraints: [NSLayoutConstraint] = []
    private var paddingConstraints: [NSLayoutConstraint] = []
    
    private var showStarted: Date?
    private var finished: Bool = false
    private var useAnimation: Bool = true
    
    // 标记为 nonisolated(unsafe) 以便在 deinit 中访问
    nonisolated(unsafe) private var graceTimer: Timer?
    nonisolated(unsafe) private var minShowTimer: Timer?
    nonisolated(unsafe) private var hideDelayTimer: Timer?
    nonisolated(unsafe) private var progressCancellable: AnyCancellable?
    
    // MARK: - Constants
    
    private static let defaultPadding: CGFloat = 8.0  // 增大间距
    private static let defaultLabelFontSize: CGFloat = 18.0  // 增大主标签字体
    private static let defaultDetailsLabelFontSize: CGFloat = 14.0  // 增大详情标签字体
    
    // MARK: - Initialization
    
    /// 初始化方法
    /// - Parameter view: 要添加 HUD 的视图
    @objc public init(view: UIView) {
        // 初始化视图组件
        backgroundView = JYBackgroundView()
        bezelView = JYBackgroundView()
        label = UILabel()
        detailsLabel = UILabel()
        button = JYProgressHUDRoundedButton(type: .custom)
        topSpacer = UIView()
        bottomSpacer = UIView()
        
        super.init(frame: view.bounds)
        
        setupViews()
        updateIndicators()
        registerForNotifications()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        unregisterFromNotifications()
        invalidateAllTimers()
        progressCancellable?.cancel()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        // 设置自身属性
        isOpaque = false
        backgroundColor = .clear
        alpha = 0.0
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        layer.allowsGroupOpacity = false
        
        // 配置背景视图（添加遮罩效果）
        backgroundView.style = .solidColor
        backgroundView.backgroundColor = UIColor(white: 0.0, alpha: 0.4)  // 添加半透明黑色遮罩
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.alpha = 0.0
        addSubview(backgroundView)
        
        // 配置 Bezel 视图
        bezelView.translatesAutoresizingMaskIntoConstraints = false
        bezelView.layer.cornerRadius = 10.0  // 增大圆角
        bezelView.alpha = 0.0
        addSubview(bezelView)
        
        // 配置标签
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = false
        label.textAlignment = .center
        label.textColor = contentColor ?? defaultContentColor
        label.font = .boldSystemFont(ofSize: Self.defaultLabelFontSize)
        label.isOpaque = false
        label.backgroundColor = .clear
        bezelView.addSubview(label)
        
        // 配置详情标签
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.adjustsFontSizeToFitWidth = false
        detailsLabel.textAlignment = .center
        detailsLabel.textColor = contentColor ?? defaultContentColor
        detailsLabel.numberOfLines = 0
        detailsLabel.font = .boldSystemFont(ofSize: Self.defaultDetailsLabelFontSize)
        detailsLabel.isOpaque = false
        detailsLabel.backgroundColor = .clear
        bezelView.addSubview(detailsLabel)
        
        // 配置按钮
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .boldSystemFont(ofSize: Self.defaultDetailsLabelFontSize)
        button.setTitleColor(contentColor ?? defaultContentColor, for: .normal)
        bezelView.addSubview(button)
        
        // 配置 Spacer
        topSpacer.translatesAutoresizingMaskIntoConstraints = false
        topSpacer.isHidden = true
        bezelView.addSubview(topSpacer)
        
        bottomSpacer.translatesAutoresizingMaskIntoConstraints = false
        bottomSpacer.isHidden = true
        bezelView.addSubview(bottomSpacer)
        
        // 设置内容压缩优先级
        for view in [label, detailsLabel, button] {
            view?.setContentCompressionResistancePriority(UILayoutPriority(998), for: .horizontal)
            view?.setContentCompressionResistancePriority(UILayoutPriority(998), for: .vertical)
        }
    }
    
    private var defaultContentColor: UIColor {
        return .label.withAlphaComponent(0.7)
    }
    
    // MARK: - Show & Hide
    
    /// 显示 HUD
    /// - Parameter animated: 是否使用动画
    @objc public func show(animated: Bool) {
        assertMainThread()
        
        minShowTimer?.invalidate()
        useAnimation = animated
        finished = false
        
        // Grace Time 处理
        if graceTime > 0.0 {
            graceTimer = Timer.scheduledTimer(withTimeInterval: graceTime, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                // 在主线程检查 finished 状态并显示
                Task { @MainActor in
                    guard !self.finished else { return }
                    self.showUsingAnimation(self.useAnimation)
                }
            }
        } else {
            showUsingAnimation(useAnimation)
        }
    }
    
    /// 隐藏 HUD
    /// - Parameter animated: 是否使用动画
    @objc public func hide(animated: Bool) {
        assertMainThread()
        
        graceTimer?.invalidate()
        useAnimation = animated
        finished = true
        
        // Min Show Time 处理
        if minShowTime > 0.0, let showStarted = showStarted {
            let interval = Date().timeIntervalSince(showStarted)
            if interval < minShowTime {
                let useAnimation = self.useAnimation
                minShowTimer = Timer.scheduledTimer(withTimeInterval: minShowTime - interval, repeats: false) { [weak self] _ in
                    guard let self = self else { return }
                    Task { @MainActor in
                        self.hideUsingAnimation(useAnimation)
                    }
                }
                return
            }
        }
        
        hideUsingAnimation(useAnimation)
    }
    
    /// 延迟隐藏 HUD
    /// - Parameters:
    ///   - animated: 是否使用动画
    ///   - delay: 延迟时间（秒）
    @objc public func hide(animated: Bool, afterDelay delay: TimeInterval) {
        hideDelayTimer?.invalidate()
        
        // 使用闭包捕获 animated 值，因为 Timer.userInfo 是只读的
        hideDelayTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self, animated] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.hide(animated: animated)
            }
        }
    }
    
    // MARK: - Class Methods
    
    /// 显示 HUD 并添加到指定视图
    /// - Parameters:
    ///   - view: 要添加到的视图
    ///   - animated: 是否使用动画
    /// - Returns: 创建的 HUD 实例
    @objc public static func showHUDAdded(to view: UIView, animated: Bool) -> JYProgressHUD {
        let hud = JYProgressHUD(view: view)
        hud.removeFromSuperViewOnHide = true
        view.addSubview(hud)
        hud.show(animated: animated)
        return hud
    }
    
    /// 隐藏指定视图上的 HUD
    /// - Parameters:
    ///   - view: 要查找的视图
    ///   - animated: 是否使用动画
    /// - Returns: 是否找到并隐藏了 HUD
    @objc public static func hideHUD(for view: UIView, animated: Bool) -> Bool {
        guard let hud = HUD(for: view) else { return false }
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: animated)
        return true
    }
    
    /// 查找指定视图上的 HUD
    /// - Parameter view: 要查找的视图
    /// - Returns: 找到的 HUD 实例，如果没有则返回 nil
    @objc public static func HUD(for view: UIView) -> JYProgressHUD? {
        for subview in view.subviews.reversed() {
            if let hud = subview as? JYProgressHUD, !hud.finished {
                return hud
            }
        }
        return nil
    }
    
    // MARK: - Private Methods
    
    private func showUsingAnimation(_ animated: Bool) {
        // 取消之前的动画
        bezelView.layer.removeAllAnimations()
        backgroundView.layer.removeAllAnimations()
        
        // 取消延迟隐藏
        hideDelayTimer?.invalidate()
        
        showStarted = Date()
        alpha = 1.0
        
        // 启用进度观察
        setNSProgressDisplayLinkEnabled(true)
        
        // 更新运动效果
        updateBezelMotionEffects()
        
        if animated {
            animateIn(animatingIn: true, type: animationType, completion: nil)
        } else {
            bezelView.alpha = 1.0
            backgroundView.alpha = 1.0
        }
    }
    
    private func hideUsingAnimation(_ animated: Bool) {
        hideDelayTimer?.invalidate()
        
        if animated, showStarted != nil {
            showStarted = nil
            animateIn(animatingIn: false, type: animationType) { [weak self] finished in
                self?.done()
            }
        } else {
            showStarted = nil
            bezelView.alpha = 0.0
            backgroundView.alpha = 0.0
            done()
        }
    }
    
    private func done() {
        setNSProgressDisplayLinkEnabled(false)
        
        if finished {
            alpha = 0.0
            if removeFromSuperViewOnHide {
                removeFromSuperview()
            }
        }
        
        completionBlock?()
        delegate?.hudWasHidden?(self)
    }
    
    private func assertMainThread() {
        assert(Thread.isMainThread, "JYProgressHUD must be accessed on the main thread")
    }
    
    // MARK: - Update Indicators
    
    private func updateIndicators() {
        let currentIndicator = indicator
        
        // 移除当前指示器
        currentIndicator?.removeFromSuperview()
        
        var newIndicator: UIView?
        
        switch mode {
        case .indeterminate:
            let activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.color = contentColor ?? defaultContentColor
            activityIndicator.startAnimating()
            newIndicator = activityIndicator
            
        case .determinate, .annularDeterminate:
            let roundProgress = JYRoundProgressView()
            roundProgress.progressTintColor = contentColor ?? defaultContentColor
            roundProgress.backgroundTintColor = (contentColor ?? defaultContentColor).withAlphaComponent(0.1)
            if mode == .annularDeterminate {
                roundProgress.isAnnular = true
            }
            newIndicator = roundProgress
            
        case .determinateHorizontalBar:
            let barProgress = JYBarProgressView()
            barProgress.progressColor = contentColor ?? defaultContentColor
            barProgress.lineColor = contentColor ?? defaultContentColor
            newIndicator = barProgress
            
        case .customView:
            newIndicator = customView
            
        case .text:
            newIndicator = nil
        }
        
        // 添加新指示器
        if let indicator = newIndicator {
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.setContentCompressionResistancePriority(UILayoutPriority(998), for: .horizontal)
            indicator.setContentCompressionResistancePriority(UILayoutPriority(998), for: .vertical)
            bezelView.addSubview(indicator)
            
            // 更新进度
            if let roundProgress = indicator as? JYRoundProgressView {
                roundProgress.progress = progress
            } else if let barProgress = indicator as? JYBarProgressView {
                barProgress.progress = progress
            }
        }
        
        indicator = newIndicator
        updateViewsForColor()
        setNeedsUpdateConstraints()
    }
    
    private func updateProgress() {
        guard let indicator = indicator else { return }
        
        if let roundProgress = indicator as? JYRoundProgressView {
            roundProgress.progress = progress
        } else if let barProgress = indicator as? JYBarProgressView {
            barProgress.progress = progress
        }
    }
    
    // MARK: - Color Updates
    
    private func updateViewsForColor() {
        guard let color = contentColor else { return }
        
        label.textColor = color
        detailsLabel.textColor = color
        button.setTitleColor(color, for: .normal)
        
        // 更新指示器颜色
        if let activityIndicator = indicator as? UIActivityIndicatorView {
            activityIndicator.color = color
        } else if let roundProgress = indicator as? JYRoundProgressView {
            roundProgress.progressTintColor = color
            roundProgress.backgroundTintColor = color.withAlphaComponent(0.1)
        } else if let barProgress = indicator as? JYBarProgressView {
            barProgress.progressColor = color
            barProgress.lineColor = color
        } else {
            indicator?.tintColor = color
        }
    }
    
    // MARK: - Progress Protocol
    
    // MARK: - Timer Management
    
    nonisolated private func invalidateAllTimers() {
        graceTimer?.invalidate()
        minShowTimer?.invalidate()
        hideDelayTimer?.invalidate()
        graceTimer = nil
        minShowTimer = nil
        hideDelayTimer = nil
    }
    
    // MARK: - Animation
    
    private func animateIn(animatingIn: Bool, type: JYProgressHUDAnimation, completion: ((Bool) -> Void)?) {
        // 自动确定缩放动画类型
        var actualType = type
        if type == .zoom {
            actualType = animatingIn ? .zoomIn : .zoomOut
        }
        
        // 设置初始状态
        let bezelView = self.bezelView!
        let smallTransform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        let largeTransform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        if animatingIn && bezelView.alpha == 0.0 {
            switch actualType {
            case .zoomIn:
                bezelView.transform = smallTransform
            case .zoomOut:
                bezelView.transform = largeTransform
            default:
                break
            }
        }
        
        // 使用 UIViewPropertyAnimator
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            if animatingIn {
                bezelView.transform = .identity
            } else {
                switch actualType {
                case .zoomIn:
                    bezelView.transform = largeTransform
                case .zoomOut:
                    bezelView.transform = smallTransform
                default:
                    break
                }
            }
            
            let alpha: CGFloat = animatingIn ? 1.0 : 0.0
            bezelView.alpha = alpha
            self.backgroundView!.alpha = alpha
        }
        
        animator.addCompletion { position in
            completion?(position == .end)
        }
        
        animator.startAnimation()
    }
    
    // MARK: - Layout
    
    public override func updateConstraints() {
        let bezel = bezelView!
        let topSpacer = self.topSpacer!
        let bottomSpacer = self.bottomSpacer!
        let margin = self.margin
        
        // 移除旧约束
        removeConstraints(constraints)
        topSpacer.removeConstraints(topSpacer.constraints)
        bottomSpacer.removeConstraints(bottomSpacer.constraints)
        
        if !bezelConstraints.isEmpty {
            bezel.removeConstraints(bezelConstraints)
            bezelConstraints.removeAll()
        }
        
        // 构建子视图数组
        var subviews: [UIView] = [topSpacer]
        if let indicator = indicator {
            subviews.append(indicator)
        }
        subviews.append(contentsOf: [label, detailsLabel, button, bottomSpacer])
        
        // 1. 居中约束（带偏移）
        let centerXConstraint = bezel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: offset.x)
        let centerYConstraint = bezel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: offset.y)
        centerXConstraint.priority = UILayoutPriority(998)
        centerYConstraint.priority = UILayoutPriority(998)
        addConstraints([centerXConstraint, centerYConstraint])
        
        // 2. 边距约束
        let leadingConstraint = bezel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: margin)
        let trailingConstraint = trailingAnchor.constraint(greaterThanOrEqualTo: bezel.trailingAnchor, constant: margin)
        let topConstraint = bezel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: margin)
        let bottomConstraint = bottomAnchor.constraint(greaterThanOrEqualTo: bezel.bottomAnchor, constant: margin)
        
        let sideConstraints = [leadingConstraint, trailingConstraint, topConstraint, bottomConstraint]
        for constraint in sideConstraints {
            constraint.priority = UILayoutPriority(999)
        }
        addConstraints(sideConstraints)
        
        // 3. 最小尺寸约束
        if minSize != .zero {
            let minWidthConstraint = bezel.widthAnchor.constraint(greaterThanOrEqualToConstant: minSize.width)
            let minHeightConstraint = bezel.heightAnchor.constraint(greaterThanOrEqualToConstant: minSize.height)
            minWidthConstraint.priority = UILayoutPriority(997)
            minHeightConstraint.priority = UILayoutPriority(997)
            bezelConstraints.append(contentsOf: [minWidthConstraint, minHeightConstraint])
        }
        
        // 4. 正方形约束
        if isSquare {
            let squareConstraint = bezel.heightAnchor.constraint(equalTo: bezel.widthAnchor)
            squareConstraint.priority = UILayoutPriority(997)
            bezelConstraints.append(squareConstraint)
        }
        
        // 5. Spacer 高度约束
        let topSpacerHeight = topSpacer.heightAnchor.constraint(greaterThanOrEqualToConstant: margin)
        let bottomSpacerHeight = bottomSpacer.heightAnchor.constraint(greaterThanOrEqualToConstant: margin)
        let spacerEqualHeight = topSpacer.heightAnchor.constraint(equalTo: bottomSpacer.heightAnchor)
        
        topSpacer.addConstraint(topSpacerHeight)
        bottomSpacer.addConstraint(bottomSpacerHeight)
        bezelConstraints.append(spacerEqualHeight)
        
        // 6. 子视图布局约束
        var newPaddingConstraints: [NSLayoutConstraint] = []
        
        for (index, view) in subviews.enumerated() {
            // 水平居中
            let centerX = view.centerXAnchor.constraint(equalTo: bezel.centerXAnchor)
            bezelConstraints.append(centerX)
            
            // 水平边距
            let leading = view.leadingAnchor.constraint(greaterThanOrEqualTo: bezel.leadingAnchor, constant: margin)
            let trailing = bezel.trailingAnchor.constraint(greaterThanOrEqualTo: view.trailingAnchor, constant: margin)
            bezelConstraints.append(contentsOf: [leading, trailing])
            
            // 垂直布局
            if index == 0 {
                // 第一个视图：顶部对齐
                let top = view.topAnchor.constraint(equalTo: bezel.topAnchor)
                bezelConstraints.append(top)
            } else if index == subviews.count - 1 {
                // 最后一个视图：底部对齐
                let bottom = bezel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                bezelConstraints.append(bottom)
            }
            
            if index > 0 {
                // 与前一个视图的间距
                let padding = view.topAnchor.constraint(equalTo: subviews[index - 1].bottomAnchor)
                bezelConstraints.append(padding)
                newPaddingConstraints.append(padding)
            }
        }
        
        bezel.addConstraints(bezelConstraints)
        paddingConstraints = newPaddingConstraints
        updatePaddingConstraints()
        
        super.updateConstraints()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if !needsUpdateConstraints() {
            updatePaddingConstraints()
        }
    }
    
    private func updatePaddingConstraints() {
        var hasVisibleAncestors = false
        
        for padding in paddingConstraints {
            guard let firstView = padding.firstItem as? UIView,
                  let secondView = padding.secondItem as? UIView else {
                continue
            }
            
            let firstVisible = !firstView.isHidden && firstView.intrinsicContentSize != .zero
            let secondVisible = !secondView.isHidden && secondView.intrinsicContentSize != .zero
            
            // 如果两个视图都可见，或者有可见的祖先视图，则设置间距
            padding.constant = (firstVisible && (secondVisible || hasVisibleAncestors)) ? Self.defaultPadding : 0.0
            
            hasVisibleAncestors = hasVisibleAncestors || secondVisible
        }
    }
    
    // MARK: - NSProgress
    
    private func observeProgress() {
        progressCancellable?.cancel()
        
        guard let progressObject = progressObject else {
            return
        }
        
        // 使用 Combine 观察进度变化
        progressCancellable = progressObject.publisher(for: \.fractionCompleted)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] fractionCompleted in
                self?.progress = Float(fractionCompleted)
            }
    }
    
    private func setNSProgressDisplayLinkEnabled(_ enabled: Bool) {
        if enabled, progressObject != nil {
            if progressCancellable == nil {
                observeProgress()
            }
        } else {
            progressCancellable?.cancel()
            progressCancellable = nil
        }
    }
    
    // MARK: - Motion Effects
    
    private func updateBezelMotionEffects() {
        guard defaultMotionEffectsEnabled else {
            // 移除现有效果
            bezelView.motionEffects.forEach { bezelView.removeMotionEffect($0) }
            return
        }
        
        // 添加运动效果
        let effectOffset: CGFloat = 10.0
        
        let effectX = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        effectX.maximumRelativeValue = effectOffset
        effectX.minimumRelativeValue = -effectOffset
        
        let effectY = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        effectY.maximumRelativeValue = effectOffset
        effectY.minimumRelativeValue = -effectOffset
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [effectX, effectY]
        
        bezelView.addMotionEffect(group)
    }
    
    // MARK: - Notifications
    
    private func registerForNotifications() {
        // iOS 17.0+ 不需要监听状态栏方向变化，Auto Layout 会自动处理
        // 已移除已弃用的 UIApplication.didChangeStatusBarOrientationNotification
    }
    
    nonisolated private func unregisterFromNotifications() {
        // iOS 17.0+ 不需要移除通知观察者
    }
    
    private func updateForCurrentOrientation(animated: Bool) {
        guard let superview = superview else { return }
        // iOS 17.0+ 不需要手动处理旋转，Auto Layout 会自动处理
        frame = superview.bounds
    }
}


