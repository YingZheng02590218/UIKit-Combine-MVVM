//
//  UITableViewCell+extension.swift
//  UIKit-Combine-MVVM
//
//  Created by Hisashi Ishihara on 2024/01/05.
//

import UIKit

extension UITableViewCell {
    static var defaultHeight: CGFloat {
        return 48.0
    }

    class var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}
