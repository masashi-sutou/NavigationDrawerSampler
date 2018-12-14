//
//  UIDevice+UserInterfaceIdiom.swift
//  NavigationDrawerTransition
//
//  Created by 須藤将史 on 2018/12/05.
//  Copyright © 2018 須藤将史. All rights reserved.
//

import UIKit

extension UIDevice {
    
    static var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}
