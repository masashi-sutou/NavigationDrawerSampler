//
//  UIViewController+AutoLayout.swift
//  NavigationDrawerTransition
//
//  Created by 須藤将史 on 2018/12/06.
//  Copyright © 2018 須藤将史. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addSubviewAndFit(_ subView: UIView) {
        view.addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                subView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                subView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                subView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                subView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
                ])
        } else {
            NSLayoutConstraint.activate([
                subView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
                subView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                subView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                subView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
        }
    }
}
