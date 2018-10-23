//
//  Promise+NSLayoutConstraint.swift
//  PromiseSwift
//
//  Created by Gleb Radchenko on 11/28/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

extension Promise where Element: NSLayoutConstraint {
    public func animate(withDuration duration: TimeInterval,
                        options: UIView.AnimationOptions = [],
                        view: UIView,
                        transform: @escaping (_ constraint: NSLayoutConstraint) -> Void) -> Promise<Element> {
        return Promise() { (resolve) in
            self.execute { (result) in
                guard let constraint = result.unbox() else { resolve(result); return }
                transform(constraint)
                UIView.animate(withDuration: duration,
                               delay: 0,
                               options: options,
                               animations: { view.layoutIfNeeded() }) { (_) in resolve(result) }
            }
        }
    }
}

#endif
