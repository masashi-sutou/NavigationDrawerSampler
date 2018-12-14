//
//  NavigationDrawerAnimationDismisser.swift
//  NavigationDrawerTransition
//
//  Created by 須藤将史 on 2018/12/05.
//  Copyright © 2018 須藤将史. All rights reserved.
//

import UIKit

final class NavigationDrawerAnimationDismisser: NSObject, UIViewControllerAnimatedTransitioning {
    
    private weak var gestureDarkView: UIView?
    private let isInteractive: Bool
    
    init(gestureDarkView: UIView, isInteractive: Bool) {
        self.gestureDarkView = gestureDarkView
        self.isInteractive = isInteractive
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isInteractive ? 0.1 : 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let drawerView = transitionContext.view(forKey: .from) else { return }
        guard let rightView = transitionContext.view(forKey: .to) else { return }
        
        /*
         * インタラクティブな動作の場合
         *  - delayは0より大きくなければ、iOS9-11でアニメーションが散らつく
         *  - AnimationOptionsは、curveLinearにしないと指と動作が合わない
         */
        let duration: TimeInterval = transitionDuration(using: transitionContext)
        let delay: TimeInterval = isInteractive ? duration : 0
        let options: UIView.AnimationOptions = isInteractive ? .curveLinear : .curveEaseOut
        
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
            
            drawerView.frame = CGRect(x: -drawerView.frame.width, y: 0, width: drawerView.frame.width, height: drawerView.frame.height)
            rightView.frame = CGRect(origin: .zero, size: rightView.frame.size)
            self.gestureDarkView?.frame = rightView.frame
            self.gestureDarkView?.alpha = 0
            
        }, completion: { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
