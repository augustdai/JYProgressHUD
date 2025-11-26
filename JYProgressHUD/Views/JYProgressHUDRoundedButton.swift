//
//  JYProgressHUDRoundedButton.swift
//  JYProgressHUD
//
//  Created by fuyong.dai on 2025.11.27
//  Copyright © 2025. All rights reserved.
//

import UIKit

/// 圆角按钮
@objc public class JYProgressHUDRoundedButton: UIButton {
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        layer.borderWidth = 1.0
    }
    
    // MARK: - Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = ceil(bounds.height / 2.0)
    }
    
    public override var intrinsicContentSize: CGSize {
        guard allControlEvents != [] && (title(for: .normal)?.count ?? 0) > 0 else {
            return .zero
        }
        
        var size = super.intrinsicContentSize
        size.width += 20.0
        return size
    }
    
    // MARK: - Appearance
    
    public override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        super.setTitleColor(color, for: state)
        layer.borderColor = color?.cgColor
        updateHighlighted()
    }
    
    public override var isHighlighted: Bool {
        didSet {
            updateHighlighted()
        }
    }
    
    private func updateHighlighted() {
        let baseColor = titleColor(for: .selected) ?? titleColor(for: .normal)
        backgroundColor = isHighlighted ? baseColor?.withAlphaComponent(0.1) : .clear
    }
}

