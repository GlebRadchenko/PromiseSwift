//
//  Promise+UIView.swift
//  PromiseSwift
//
//  Created by Gleb Radchenko on 11/28/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

extension Promise where Element: UIView {
    public func animate(withDuration duration: TimeInterval,
                        options: UIViewAnimationOptions = [],
                        animations: @escaping (_ view: UIView) -> Void) -> Promise<Element> {
        return Promise() { (resolve) in
            self.execute { (result) in
                guard let view = result.unbox() else { resolve(result); return }
                UIView.animate(withDuration: duration,
                               delay: 0,
                               options: options,
                               animations: { animations(view) }) { (_) in resolve(result) }
            }
        }
    }
}

