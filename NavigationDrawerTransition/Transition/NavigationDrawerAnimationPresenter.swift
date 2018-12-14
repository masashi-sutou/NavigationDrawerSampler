//
//  NavigationDrawerAnimationPresenter.swift
//  NavigationDrawerTransition
//
//  Created by 須藤将史 on 2018/12/05.
//  Copyright © 2018 須藤将史. All rights reserved.
//

import UIKit

final class NavigationDrawerAnimationPresenter: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let drawerWidth: CGFloat
    private weak var gestureDarkView: UIView?
    private let isInteractive: Bool
    
    init(drawerWidth: CGFloat, gestureDarkView: UIView, isInteractive: Bool) {
        self.drawerWidth = drawerWidth
        self.gestureDarkView = gestureDarkView
        self.isInteractive = isInteractive
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isInteractive ? 0.1 : 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        guard let rightView = transitionContext.view(forKey: .from) else { return }
        guard let drawerView = transitionContext.view(forKey: .to) else { return }
        
        // ドロワーメニュー
        let startFrame = CGRect(x: -drawerWidth, y: 0, width: drawerWidth, height: drawerView.frame.height)
        drawerView.frame = startFrame
        containerView.addSubview(drawerView)
        
        // ドロワーメニューを開いたビュー
        self.gestureDarkView?.frame = rightView.frame
        containerView.addSubview(rightView)
        containerView.insertSubview(self.gestureDarkView!, aboveSubview: rightView)
        
        /*
         * インタラクティブな動作の場合
         *  - delayは0より大きくなければ、iOS9-11でアニメーションが散らつく
         *  - AnimationOptionsは、curveLinearにしないと指と動作が合わない
         */
        let duration: TimeInterval = transitionDuration(using: transitionContext)
        let delay: TimeInterval = isInteractive ? duration : 0
        let options: UIView.AnimationOptions = isInteractive ? .curveLinear : .curveEaseOut
        
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
            
            drawerView.frame = CGRect(origin: .zero, size: drawerView.frame.size)
            rightView.frame = CGRect(x: self.drawerWidth, y: 0, width: rightView.frame.width, height: rightView.frame.height)
            self.gestureDarkView?.frame = rightView.frame
            self.gestureDarkView?.alpha = 1
            
        }, completion: { (_) in
            
            guard !transitionContext.transitionWasCancelled else {
                transitionContext.completeTransition(false)
                return
            }
            
            transitionContext.completeTransition(true)
            
            /*
             * 遷移中のViewに遷移元のViewを貼り付けてスライドしてきた感じを演出
             * さらに遷移元のViewにタップとドラッグのジェスチャーを登録したViewを最前面に貼り付けて
             * タップとドラッグの両方で画面を閉じることを可能にする
             */
            containerView.addSubview(rightView)
            self.gestureDarkView?.frame = rightView.frame
            containerView.insertSubview(self.gestureDarkView!, aboveSubview: rightView)
        })
    }
}
