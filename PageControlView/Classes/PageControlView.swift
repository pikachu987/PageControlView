//Copyright (c) 2020 pikachu987 <pikachu77769@gmail.com>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

import UIKit

public protocol PageControlViewDelegate: class {
    func pageControlTap(_ view: PageControlView, index: Int)
}

open class PageControlView: UIView {
    public weak var delegate: PageControlViewDelegate?

    public var numberOfPages: Int {
        get {
            return self.pages.count
        }
        set {
            self.scrollView.subviews.forEach({ $0.removeConstraints($0.constraints) })
            self.scrollView.removeConstraints(self.scrollView.constraints)
            self.scrollView.subviews.forEach({ $0.removeFromSuperview() })
            
            let isPageSameRate = self.pageWidth == 0 && self.pageHeight == 0
            let isCurrentPageSameRate = self.currentPageWidth == 0 && self.currentPageHeight == 0

            for _ in 0..<newValue {
                let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                containerView.translatesAutoresizingMaskIntoConstraints = false
                containerView.isUserInteractionEnabled = true
                let lastView = self.scrollView.subviews.last
                self.scrollView.addSubview(containerView)
                containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tabGesture(_:))))

                self.scrollView.addConstraints([
                    NSLayoutConstraint(item: self.scrollView, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: self.scrollView, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: self.scrollView, attribute: .height, relatedBy: .equal, toItem: containerView, attribute: .height, multiplier: 1, constant: 0)
                ])
                if let lastView = lastView {
                    self.scrollView.addConstraints([
                        NSLayoutConstraint(item: lastView, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1, constant: 0)
                    ])
                } else {
                    let leadingConstraint = NSLayoutConstraint(item: containerView, attribute: .leading, relatedBy: .equal, toItem: self.scrollView, attribute: .leading, multiplier: 1, constant: self.margin - self.padding/2)
                    leadingConstraint.identifier = "leadingMargin"
                    self.scrollView.addConstraints([
                        leadingConstraint
                    ])
                }

                let pageView = UIView()
                pageView.translatesAutoresizingMaskIntoConstraints = false
                containerView.addSubview(pageView)
                if isPageSameRate {
                    pageView.layer.cornerRadius = self.pageSize/2
                } else {
                    pageView.layer.cornerRadius = self.pageRadius
                }
                pageView.backgroundColor = self.pageIndicatorTintColor

                let widthConstraint: NSLayoutConstraint
                let heightConstraint: NSLayoutConstraint
                if isPageSameRate {
                    widthConstraint = NSLayoutConstraint(item: pageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: self.pageSize)
                    heightConstraint = NSLayoutConstraint(item: pageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: self.pageSize)
                } else {
                    widthConstraint = NSLayoutConstraint(item: pageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: self.pageWidth)
                    heightConstraint = NSLayoutConstraint(item: pageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: self.pageHeight)
                }
                widthConstraint.identifier = "width"
                heightConstraint.identifier = "height"
                pageView.addConstraints([
                    widthConstraint, heightConstraint
                ])
                let paddingLeadingConstraint = NSLayoutConstraint(item: containerView, attribute: .leading, relatedBy: .equal, toItem: pageView, attribute: .leading, multiplier: 1, constant: -self.padding/2)
                paddingLeadingConstraint.identifier = "leadingPadding"
                let paddingTrailingConstraint = NSLayoutConstraint(item: containerView, attribute: .trailing, relatedBy: .equal, toItem: pageView, attribute: .trailing, multiplier: 1, constant: self.padding/2)
                paddingTrailingConstraint.identifier = "trailingPadding"
                containerView.addConstraints([
                    NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: pageView, attribute: .centerY, multiplier: 1, constant: 0),
                    paddingLeadingConstraint,
                    paddingTrailingConstraint
                ])
            }

            if let lastView = self.scrollView.subviews.last {
                let trailingConstraint = NSLayoutConstraint(item: self.scrollView, attribute: .trailing, relatedBy: .equal, toItem: lastView, attribute: .trailing, multiplier: 1, constant: self.margin - self.padding/2)
                trailingConstraint.identifier = "trailingMargin"
                self.scrollView.addConstraints([
                    trailingConstraint
                ])
            }

            self.scrollView.addSubview(self.currentPageView)
            self.currentPageView.backgroundColor = self.currentPageIndicatorTintColor
            if isCurrentPageSameRate {
                self.currentPageView.layer.cornerRadius = self.pageSize/2
            } else {
                self.currentPageView.layer.cornerRadius = self.currentPageRadius
            }

            let leadingConstraint = NSLayoutConstraint(item: self.scrollView, attribute: .leading, relatedBy: .equal, toItem: self.currentPageView, attribute: .leading, multiplier: 1, constant: 0)
            leadingConstraint.identifier = "currentPage"
            self.scrollView.addConstraints([
                NSLayoutConstraint(item: self.scrollView, attribute: .centerY, relatedBy: .equal, toItem: self.currentPageView, attribute: .centerY, multiplier: 1, constant: 0),
                leadingConstraint
            ])
            let widthConstraint: NSLayoutConstraint
            let heightConstraint: NSLayoutConstraint
            if isCurrentPageSameRate {
                widthConstraint = NSLayoutConstraint(item: self.currentPageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: self.pageSize)
                heightConstraint = NSLayoutConstraint(item: self.currentPageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: self.pageSize)
            } else {
                widthConstraint = NSLayoutConstraint(item: self.currentPageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: self.currentPageWidth)
                heightConstraint = NSLayoutConstraint(item: self.currentPageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: self.currentPageHeight)
            }
            widthConstraint.identifier = "width"
            heightConstraint.identifier = "height"
            self.currentPageView.addConstraints([
                widthConstraint,
                heightConstraint
            ])

            self.layoutIfNeeded()
            self.horizontalFrameCenter()

            let currentPage = self.currentPage
            self.currentPage = currentPage
        }
    }

    public var currentPage: Int = 0 {
        didSet {
            if self.currentPage < 0 { return }
            if self.currentPage >= self.pages.count { return }
            
            let pageWidth = self.pages.first?.subviews.first?.constraints.filter({ $0.identifier == "width" }).first?.constant ?? 0
            let centerX = (self.margin - self.padding/2) + (CGFloat(self.currentPage) * (pageWidth + self.padding)) + (pageWidth + self.padding)/2
            let currentPageWidth = self.currentPageView.constraints.filter({ $0.identifier == "width" }).first?.constant ?? 0
            let constant = centerX - (currentPageWidth/2)
            self.scrollView.constraints.filter({ $0.identifier == "currentPage" }).first?.constant = -constant
        }
    }

    public var margin: CGFloat = 20 {
        didSet {
            self.scrollView.constraints.filter({ $0.identifier == "leadingMargin" }).first?.constant = self.margin - self.padding/2
            self.scrollView.constraints.filter({ $0.identifier == "trailingMargin" }).first?.constant = self.margin - self.padding/2
            let currentPage = self.currentPage
            self.currentPage = currentPage
        }
    }

    public var padding: CGFloat = 12 {
        didSet {
            self.pages.forEach { (view) in
                view.constraints.filter({ $0.identifier == "leadingPadding" }).first?.constant = -self.padding/2
                view.constraints.filter({ $0.identifier == "trailingPadding" }).first?.constant = self.padding/2
            }
            let margin = self.margin
            self.margin = margin
        }
    }

    public var pageSize: CGFloat = 16 {
        didSet {
            self.pages.forEach { (view) in
                view.subviews.first?.layer.cornerRadius = self.pageSize/2
                view.subviews.first?.constraints.filter({ $0.identifier == "width" || $0.identifier == "height" }).forEach({ $0.constant = self.pageSize })
            }
            self.currentPageView.constraints.filter({ $0.identifier == "width" || $0.identifier == "height" }).forEach({ $0.constant = self.pageSize })
            self.currentPageView.layer.cornerRadius = self.pageSize/2
            let currentPage = self.currentPage
            self.currentPage = currentPage
        }
    }

    public var pageWidth: CGFloat = 0 {
        didSet {
            self.pages.forEach { (view) in
                view.subviews.first?.constraints.filter({ $0.identifier == "width" }).forEach({ $0.constant = self.pageWidth })
            }
            let currentPage = self.currentPage
            self.currentPage = currentPage
        }
    }

    public var pageHeight: CGFloat = 0 {
        didSet {
            self.pages.forEach { (view) in
                view.subviews.first?.constraints.filter({ $0.identifier == "height" }).forEach({ $0.constant = self.pageHeight })
            }
            let currentPage = self.currentPage
            self.currentPage = currentPage
        }
    }

    public var pageRadius: CGFloat = 0 {
        didSet {
            self.pages.forEach { (view) in
                view.subviews.first?.layer.cornerRadius = self.pageRadius
            }
        }
    }

    public var currentPageWidth: CGFloat = 0 {
        didSet {
            self.currentPageView.constraints.filter({ $0.identifier == "width" }).forEach({ $0.constant = self.currentPageWidth })
            let currentPage = self.currentPage
            self.currentPage = currentPage
        }
    }

    public var currentPageHeight: CGFloat = 0 {
        didSet {
            self.currentPageView.constraints.filter({ $0.identifier == "height" }).forEach({ $0.constant = self.currentPageHeight })
            let currentPage = self.currentPage
            self.currentPage = currentPage
        }
    }

    public var currentPageRadius: CGFloat = 0 {
        didSet {
            self.currentPageView.layer.cornerRadius = self.currentPageRadius
        }
    }

    public var pageIndicatorTintColor: UIColor = UIColor.lightGray {
        didSet {
            self.pages.forEach { (view) in
                view.backgroundColor = self.pageIndicatorTintColor
            }
        }
    }

    public var currentPageIndicatorTintColor: UIColor = UIColor(light: .black, dark: .white) {
        didSet {
            self.currentPageView.backgroundColor = self.currentPageIndicatorTintColor
        }
    }

    public var transparencyColor: UIColor = UIColor(light: .white, dark: .black) {
        didSet {
            self.leftGradientLayer.colors = [
                self.transparencyColor.withAlphaComponent(1.0).cgColor,
                self.transparencyColor.withAlphaComponent(0.1).cgColor,
                self.transparencyColor.withAlphaComponent(0.0).cgColor
            ]

            self.rightGradientLayer.colors = [
                self.transparencyColor.withAlphaComponent(0.0).cgColor,
                self.transparencyColor.withAlphaComponent(0.1).cgColor,
                self.transparencyColor.withAlphaComponent(1.0).cgColor
            ]
        }
    }

    public var transparencyLeftWidth: CGFloat = 24 {
        didSet {
            self.leftTransparencyView.constraints.filter({ $0.identifier == "leadingTransWidth" }).first?.constant = self.transparencyLeftWidth
            self.leftGradientLayer.frame = CGRect(x: 0, y: 0, width: self.transparencyLeftWidth, height: self.bounds.height)
        }
    }

    public var transparencyRightWidth: CGFloat = 24 {
        didSet {
            self.rightTransparencyView.constraints.filter({ $0.identifier == "trailingTransWidth" }).first?.constant = self.transparencyRightWidth
            self.rightGradientLayer.frame = CGRect(x: 0, y: 0, width: self.transparencyRightWidth, height: self.bounds.height)
        }
    }

    public let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private var pages: [UIView] {
        return self.scrollView.subviews.filter { (view) -> Bool in
            if view as? UIImageView != nil { return false }
            let viewClassName = NSStringFromClass(type(of: view))
            if viewClassName == "_UIScrollViewScrollIndicator" { return false }
            return view != self.currentPageView
        }
    }

    public let currentPageView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public let leftTransparencyView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private let leftGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.locations = [0.0, 0.6, 1.0]
        return gradientLayer
    }()

    public let rightTransparencyView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private let rightGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.locations = [0.0, 0.6, 1.0]
        return gradientLayer
    }()

    private var frameWidth: CGFloat = -1

    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.scrollView)
        self.addSubview(self.leftTransparencyView)
        self.addSubview(self.rightTransparencyView)
        self.leftTransparencyView.layer.addSublayer(self.leftGradientLayer)
        self.rightTransparencyView.layer.addSublayer(self.rightGradientLayer)

        let heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 56)
        heightConstraint.priority = UILayoutPriority(rawValue: 800)

        self.addConstraints([
            heightConstraint
        ])

        let leadingConstraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: self.scrollView, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.scrollView, attribute: .trailing, multiplier: 1, constant: 0)
        leadingConstraint.identifier = "leading"
        trailingConstraint.identifier = "trailing"
        self.addConstraints([
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: self.scrollView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.scrollView, attribute: .bottom, multiplier: 1, constant: 0),
            leadingConstraint,
            trailingConstraint
        ])

        self.addConstraints([
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: self.leftTransparencyView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.leftTransparencyView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: self.leftTransparencyView, attribute: .leading, multiplier: 1, constant: 0)
        ])
        let leftTransWidthConstraint = NSLayoutConstraint(item: self.leftTransparencyView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 0)
        leftTransWidthConstraint.identifier = "leadingTransWidth"
        self.leftTransparencyView.addConstraints([
            leftTransWidthConstraint
        ])

        self.addConstraints([
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: self.rightTransparencyView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.rightTransparencyView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.rightTransparencyView, attribute: .trailing, multiplier: 1, constant: 0)
        ])
        let rightTransWidthConstraint = NSLayoutConstraint(item: self.rightTransparencyView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 0)
        rightTransWidthConstraint.identifier = "trailingTransWidth"
        self.rightTransparencyView.addConstraints([
            rightTransWidthConstraint
        ])

        self.leftGradientLayer.colors = [
            self.transparencyColor.withAlphaComponent(1.0).cgColor,
            self.transparencyColor.withAlphaComponent(0.1).cgColor,
            self.transparencyColor.withAlphaComponent(0.0).cgColor
        ]

        self.rightGradientLayer.colors = [
            self.transparencyColor.withAlphaComponent(0.0).cgColor,
            self.transparencyColor.withAlphaComponent(0.1).cgColor,
            self.transparencyColor.withAlphaComponent(1.0).cgColor
        ]
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func updateCurrentPage(_ currentPage: Int, withDuration: TimeInterval = 0.3, centerDuration: TimeInterval = 0.3, callback: (() -> Void)? = nil) {
        if currentPage < 0 { return }
        if currentPage >= self.pages.count { return }
        self.currentPage = currentPage
        UIView.animate(withDuration: withDuration, animations: {
            self.layoutIfNeeded()
        }) { (_) in
            let remainWidth = (self.frameWidth - self.scrollView.contentSize.width) / 2
            if remainWidth <= 0 {
                UIView.animate(withDuration: centerDuration) {
                    self.horizontalCenter()
                    callback?()
                }
            }
        }
    }

    public func horizontalCenter() {
        let width = self.pages.first?.subviews.first?.constraints.filter({ $0.identifier == "width" }).first?.constant ?? 0
        let showCount = self.scrollView.bounds.width / (width + self.padding)
        let centerPage = Int(ceil(showCount / 2))
        if self.currentPage > centerPage && self.currentPage <= (self.numberOfPages - centerPage) {
            self.scrollView.contentOffset.x = self.pages[self.currentPage].frame.origin.x - (self.scrollView.bounds.width / 2)
        } else if self.currentPage > centerPage {
            self.scrollView.contentOffset.x = self.scrollView.contentSize.width - self.scrollView.bounds.width
        } else {
            self.scrollView.contentOffset.x = 0
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        if self.frameWidth == -1 {
            self.frameWidth = self.bounds.width
        }
        self.horizontalFrameCenter()
        let transparencyLeftWidth = self.transparencyLeftWidth
        self.transparencyLeftWidth = transparencyLeftWidth
        let transparencyRightWidth = self.transparencyRightWidth
        self.transparencyRightWidth = transparencyRightWidth
    }

    private func horizontalFrameCenter() {
        if self.frameWidth == -1 { return }
        if self.numberOfPages == 0 { return }
        let remainWidth = (self.frameWidth - self.scrollView.contentSize.width) / 2
        self.constraints.filter({ $0.identifier == "leading" }).first?.constant = remainWidth > 0 ? -remainWidth : 0
        self.constraints.filter({ $0.identifier == "trailing" }).first?.constant = remainWidth > 0 ? remainWidth : 0
    }

    @objc private func tabGesture(_ gesture: UITapGestureRecognizer) {
        guard let index = self.pages.firstIndex(where: { $0 == gesture.view }) else { return }
        self.delegate?.pageControlTap(self, index: index)
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            let transparencyColor = self.transparencyColor
            self.transparencyColor = transparencyColor
        }
    }
}
