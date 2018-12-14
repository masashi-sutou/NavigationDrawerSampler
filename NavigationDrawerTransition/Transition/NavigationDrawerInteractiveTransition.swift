//
//  NavigationDrawerInteractiveTransition.swift
//  NavigationDrawerTransition
//
//  Created by 須藤将史 on 2018/12/05.
//  Copyright © 2018 須藤将史. All rights reserved.
//

import UIKit

final class NavigationDrawerInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    var isStart = false
    var isFinish: Bool {
        return percentComplete >= percentCompleteThreshold
    }
    
    private let percentCompleteThreshold: CGFloat = 0.2
    
    override init() {
        super.init()
        completionCurve = .easeOut
    }
    
    override func cancel() {
        completionSpeed = percentCompleteThreshold
        super.cancel()
    }
    
    override func finish() {
        completionSpeed = 1 - percentCompleteThreshold
        super.finish()
    }
}

