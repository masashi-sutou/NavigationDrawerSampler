//
//  NavigationDrawerViewController.swift
//  NavigationDrawerTransition
//
//  Created by 須藤将史 on 2018/12/05.
//  Copyright © 2018 須藤将史. All rights reserved.
//

import UIKit

protocol NavigationDrawerViewControllerDelegate: class {
    func willViewRotation(in: NavigationDrawerViewController)
    func didTapMenuItem(in: NavigationDrawerViewController, next: UIViewController)
}

final class NavigationDrawerViewController: UIViewController {
    
    private let drawerSize: CGSize
    private let interactiveTransition: NavigationDrawerInteractiveTransition
    private let gestureDarkView: UIView
    private let tableView: UITableView
    private weak var delegate: NavigationDrawerViewControllerDelegate?
    
    init(drawerSize size: CGSize, interactiveTransition: NavigationDrawerInteractiveTransition, gestureDarkView: UIView, delegate: NavigationDrawerViewControllerDelegate) {
        self.drawerSize = size
        self.gestureDarkView = gestureDarkView
        self.interactiveTransition = interactiveTransition
        self.delegate = delegate
        self.tableView = UITableView(frame: .zero, style: .grouped)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        transitioningDelegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        addSubviewAndFit(tableView)
    }
    
    // MARK: - 回転
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        delegate?.willViewRotation(in: self)
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension NavigationDrawerViewController: UIViewControllerTransitioningDelegate {
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition.isStart ? interactiveTransition : nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition.isStart ? interactiveTransition : nil
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return NavigationDrawerAnimationPresenter(drawerWidth: drawerSize.width, gestureDarkView: gestureDarkView, isInteractive: interactiveTransition.isStart)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return NavigationDrawerAnimationDismisser(gestureDarkView: gestureDarkView, isInteractive: interactiveTransition.isStart)
    }
}

// MARK: - UITableViewDataSource

extension NavigationDrawerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "title" + String(indexPath.item)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "To close the drawer, swipe to the left or tap the dark screen on the right"
    }
}

// MARK: - UITableViewDelegate

extension NavigationDrawerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let next = UIViewController()
        
        switch indexPath.item {
        case 0:
            next.view.backgroundColor = UIColor.red
        case 1:
            next.view.backgroundColor = UIColor.blue
        case 2:
            next.view.backgroundColor = UIColor.green
        case 3:
            next.view.backgroundColor = UIColor.yellow
        case 4:
            next.view.backgroundColor = UIColor.lightGray
        default:
            return
        }
        
        delegate?.didTapMenuItem(in: self, next: next)
    }
}
