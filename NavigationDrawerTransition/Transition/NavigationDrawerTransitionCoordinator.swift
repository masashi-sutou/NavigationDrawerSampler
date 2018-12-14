//
//  NavigationDrawerTransitionCoordinator.swift
//  NavigationDrawerTransition
//
//  Created by 須藤将史 on 2018/12/05.
//  Copyright © 2018 須藤将史. All rights reserved.
//

import UIKit

final public class NavigationDrawerTransitionCoordinator: NSObject {
    
    private var isShowDrawer: Bool
    private var drawerSize: CGSize
    private let gestureDarkView: UIView
    private let interactiveTransition: NavigationDrawerInteractiveTransition
    private weak var root: UIViewController?
    
    private var navigationDrawerViewController: NavigationDrawerViewController? {
        didSet {
            guard navigationDrawerViewController == nil else { return }
            gestureDarkView.alpha = 0
            isShowDrawer = false
        }
    }
    
    public init(rootViewController: UIViewController) {
        
        isShowDrawer = false
        drawerSize = {
            let drawerWidth = UIDevice.isiPad ? 300 : rootViewController.view.frame.width * 0.8
            return CGSize(width: drawerWidth, height: rootViewController.view.frame.height)
        }()

        gestureDarkView = UIView()
        gestureDarkView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        gestureDarkView.alpha = 0
        gestureDarkView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        interactiveTransition = NavigationDrawerInteractiveTransition()
        
        root = rootViewController
        
        super.init()
        
        // ドロワーメニューをドラッグで開く
        let openDrawerPanGesture = UIPanGestureRecognizer()
        openDrawerPanGesture.maximumNumberOfTouches = 1
        openDrawerPanGesture.minimumNumberOfTouches = 1
        openDrawerPanGesture.delegate = self
        openDrawerPanGesture.addTarget(self, action: #selector(draggedOpenNavigationDrawer(_:)))
        root?.view.addGestureRecognizer(openDrawerPanGesture)
        
        // ドロワーメニューをドラッグで閉じる
        let closeDrawerPanGesture = UIPanGestureRecognizer()
        closeDrawerPanGesture.maximumNumberOfTouches = 1
        closeDrawerPanGesture.minimumNumberOfTouches = 1
        closeDrawerPanGesture.delegate = self
        closeDrawerPanGesture.addTarget(self, action: #selector(draggedClosedNavigationDrawer(_:)))
        gestureDarkView.addGestureRecognizer(closeDrawerPanGesture)
        
        // タップで閉じる
        let closeDrawerTapGesture = UITapGestureRecognizer()
        closeDrawerTapGesture.numberOfTapsRequired = 1
        closeDrawerTapGesture.addTarget(self, action: #selector(tappedGestureView(_:)))
        gestureDarkView.addGestureRecognizer(closeDrawerTapGesture)
    }
    
    // MARK: - ドロワーメニューを初期化
    
    private func setupNavigationDrawerViewController() -> NavigationDrawerViewController {
        let navigationDrawer = NavigationDrawerViewController(drawerSize: drawerSize, interactiveTransition: interactiveTransition, gestureDarkView: gestureDarkView, delegate: self)
        let closeDrawerPanGesture = UIPanGestureRecognizer()
        closeDrawerPanGesture.maximumNumberOfTouches = 1
        closeDrawerPanGesture.minimumNumberOfTouches = 1
        closeDrawerPanGesture.delegate = self
        closeDrawerPanGesture.addTarget(self, action: #selector(draggedClosedNavigationDrawer(_:)))
        navigationDrawer.view.addGestureRecognizer(closeDrawerPanGesture)
        return navigationDrawer
    }
    
    // MARK: - 回転対応
    
    internal func resizeWhenViewWillTransition(size: CGSize) {
        drawerSize.height = size.height
    }
    
    // MARK: - ドロワーメニューをインタラクティブに開く
    
    @objc private func draggedOpenNavigationDrawer(_ sender: UIPanGestureRecognizer) {
        
        guard drawerSize != .zero else {
            return
        }
        
        let transitonX: CGFloat = sender.translation(in: sender.view).x
        let draggedDirectionRatio: CGFloat = transitonX < 0 ? 0 : 1
        let progress: CGFloat = transitonX / drawerSize.width * draggedDirectionRatio
        let transitionProgress = max(min(progress, 1.0), 0.0)
        
        switch sender.state {
        case .began:
            interactiveTransition.isStart = true
            if root?.navigationController?.presentedViewController != nil {
                root?.navigationController?.dismiss(animated: false, completion: nil)
            }
            
            guard let navigationDrawer = navigationDrawerViewController else {
                return
            }
            root?.navigationController?.present(navigationDrawer, animated: true, completion: nil)
            interactiveTransition.update(transitionProgress)
        case .changed:
            interactiveTransition.update(transitionProgress)
        case .ended:
            interactiveTransition.isStart = false
            guard interactiveTransition.isFinish else {
                interactiveTransition.cancel()
                navigationDrawerViewController = nil
                return
            }
            
            interactiveTransition.finish()
            isShowDrawer = true
        case .cancelled, .failed:
            interactiveTransition.isStart = false
            interactiveTransition.cancel()
            navigationDrawerViewController = nil
        case .possible:
            break
        }
    }
    
    // MARK: - ドロワーメニューをインタラクティブに閉じる
    
    @objc private func draggedClosedNavigationDrawer(_ sender: UIPanGestureRecognizer) {
        
        guard drawerSize != .zero else {
            return
        }
        
        let transitonX: CGFloat = sender.translation(in: sender.view).x
        let draggedDirectionRatio: CGFloat = transitonX < 0 ? -1 : 0
        let progress: CGFloat = transitonX / drawerSize.width * draggedDirectionRatio
        let transitionProgress = max(min(progress, 1.0), 0.0)
        
        switch sender.state {
        case .began:
            interactiveTransition.isStart = true
            navigationDrawerViewController?.dismiss(animated: true, completion: nil)
            interactiveTransition.update(transitionProgress)
        case .changed:
            interactiveTransition.update(transitionProgress)
        case .ended:
            interactiveTransition.isStart = false
            guard interactiveTransition.isFinish else {
                interactiveTransition.cancel()
                isShowDrawer = true
                return
            }
            
            interactiveTransition.finish()
            navigationDrawerViewController = nil
        case .cancelled, .failed:
            interactiveTransition.isStart = false
            interactiveTransition.cancel()
            isShowDrawer = true
        case .possible:
            break
        }
    }
    
    // MARK: - タップ処理
    
    @objc private func tappedGestureView(_ sender: UITapGestureRecognizer) {
        dismissNavigationDrawerViewController()
    }
    
    // MARK: - ドロワーメニューをタップで閉じる
    
    private func dismissNavigationDrawerViewController() {
        navigationDrawerViewController?.dismiss(animated: true, completion: {
            self.navigationDrawerViewController = nil
        })
    }
    
    // MARK: - 左上ナビゲーションボタンの設定
    
    public func setupDrawerNavigationItemLeftBarButton() {
        root?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "open", style: .done, target: self, action: #selector(tappedDrawerButton(_:)))
    }
    
    // MARK: - 左上ナビゲーションボタンでドロワーメニューを開く
    
    @objc private func tappedDrawerButton(_ sender: UIBarButtonItem) {
        navigationDrawerViewController = setupNavigationDrawerViewController()
        root?.navigationController?.present(navigationDrawerViewController!, animated: true, completion: {
            self.isShowDrawer = true
        })
    }
}

// MARK: - UIGestureRecognizerDelegate

extension NavigationDrawerTransitionCoordinator: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        
        guard !isShowDrawer else {
            return true
        }
        
        navigationDrawerViewController = setupNavigationDrawerViewController()
        
        guard panGesture.translation(in: gestureRecognizer.view).x > 0 else {
            // 右へスクロールしたとき
            return true
        }
        
        return true
    }
}

// MARK: - NavigationDrawerViewControllerDelegate

extension NavigationDrawerTransitionCoordinator: NavigationDrawerViewControllerDelegate {
    
    func willViewRotation(in: NavigationDrawerViewController) {
        dismissNavigationDrawerViewController()
    }
    
    func didTapMenuItem(in: NavigationDrawerViewController, next: UIViewController) {
        dismissNavigationDrawerViewController()
        root?.navigationController?.pushViewController(next, animated: false)
    }
}
