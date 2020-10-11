//
//  ViewController.swift
//  PageControlView
//
//  Created by pikachu987 on 10/11/2020.
//  Copyright (c) 2020 pikachu987. All rights reserved.
//

import UIKit
import PageControlView

class ViewController: UIViewController {
    private let pageControlView: PageControlView = {
        let pageControlView = PageControlView()
        pageControlView.translatesAutoresizingMaskIntoConstraints = false
        pageControlView.numberOfPages = 4
        return pageControlView
    }()

    private let pageControlViewCustom: PageControlView = {
        let pageControlView = PageControlView()
        pageControlView.translatesAutoresizingMaskIntoConstraints = false
        pageControlView.numberOfPages = 4
        pageControlView.pageWidth = 20
        pageControlView.pageHeight = 4
        pageControlView.pageRadius = 2
        pageControlView.currentPageWidth = 24
        pageControlView.currentPageHeight = 12
        pageControlView.currentPageRadius = 6
        return pageControlView
    }()

    private let leftButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("◀︎", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        return button
    }()

    private let rightButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("▶︎", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        return button
    }()

    private let pageSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 1
        slider.maximumValue = 50
        slider.value = 4
        return slider
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.addSubview(self.pageControlView)
        self.view.addSubview(self.pageControlViewCustom)
        self.view.addSubview(self.leftButton)
        self.view.addSubview(self.rightButton)
        self.view.addSubview(self.pageSlider)
        
        self.pageControlView.delegate = self
        self.pageControlViewCustom.delegate = self

        self.leftButton.addTarget(self, action: #selector(self.leftTap(_:)), for: .touchUpInside)
        self.rightButton.addTarget(self, action: #selector(self.rightTap(_:)), for: .touchUpInside)
        self.pageSlider.addTarget(self, action: #selector(self.pageCountValueChagned(_:)), for: .valueChanged)
        
        self.pageControlView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        self.pageControlView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        self.pageControlView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: UIApplication.shared.statusBarFrame.height + 12).isActive = true

        self.pageControlViewCustom.topAnchor.constraint(equalTo: self.pageControlView.bottomAnchor, constant: -20).isActive = true
        self.pageControlViewCustom.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        self.pageControlViewCustom.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true

        self.leftButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        self.leftButton.topAnchor.constraint(equalTo: self.pageControlViewCustom.bottomAnchor, constant: -20).isActive = true
        
        self.pageSlider.leadingAnchor.constraint(equalTo: self.leftButton.trailingAnchor, constant: 20).isActive = true
        self.pageSlider.centerYAnchor.constraint(equalTo: self.leftButton.centerYAnchor, constant: 0).isActive = true
        
        self.rightButton.leadingAnchor.constraint(equalTo: self.pageSlider.trailingAnchor, constant: 20).isActive = true
        self.rightButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        self.rightButton.centerYAnchor.constraint(equalTo: self.leftButton.centerYAnchor, constant: 0).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc private func leftTap(_ sender: UIButton) {
        self.pageControlView.updateCurrentPage(self.pageControlView.currentPage - 1, withDuration: 0.3, centerDuration: 0.3, callback: nil)
        self.pageControlViewCustom.updateCurrentPage(self.pageControlViewCustom.currentPage - 1, withDuration: 0.3, centerDuration: 0.3, callback: nil)
    }
    
    @objc private func rightTap(_ sender: UIButton) {
        self.pageControlView.updateCurrentPage(self.pageControlView.currentPage + 1, withDuration: 0.3, centerDuration: 0.3, callback: nil)
        self.pageControlViewCustom.updateCurrentPage(self.pageControlViewCustom.currentPage + 1, withDuration: 0.3, centerDuration: 0.3, callback: nil)
    }
    
    @objc private func pageCountValueChagned(_ sender: UISlider) {
        if self.pageControlView.currentPage >= Int(sender.value) {
            self.pageControlView.currentPage = 0
        }
        self.pageControlView.numberOfPages = Int(sender.value)
        if self.pageControlViewCustom.currentPage >= Int(sender.value) {
            self.pageControlViewCustom.currentPage = 0
        }
        self.pageControlViewCustom.numberOfPages = Int(sender.value)
    }
    
}

// MARK: PageControlViewDelegate
extension ViewController: PageControlViewDelegate {
    func pageControlTap(_ view: PageControlView, index: Int) {
        self.pageControlView.updateCurrentPage(index, withDuration: 0.3, centerDuration: 0.3, callback: nil)
        self.pageControlViewCustom.updateCurrentPage(index, withDuration: 0.3, centerDuration: 0.3, callback: nil)
    }
}
