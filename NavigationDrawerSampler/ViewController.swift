//
//  ViewController.swift
//  NavigationDrawerSampler
//
//  Created by 須藤将史 on 2018/12/15.
//  Copyright © 2018 須藤将史. All rights reserved.
//

import UIKit
import NavigationDrawerTransition

final class ViewController: UIViewController {
    
    private var navigationDrawerTransitionCoordinator: NavigationDrawerTransitionCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "NavigationDrawerSampler"
        
        navigationDrawerTransitionCoordinator = NavigationDrawerTransitionCoordinator(rootViewController: self)
        navigationDrawerTransitionCoordinator?.setupDrawerNavigationItemLeftBarButton()
    }
}
