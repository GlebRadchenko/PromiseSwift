//
//  Promise+UITableView.swift
//  PromiseSwift
//
//  Created by Gleb Radchenko on 3/27/18.
//  Copyright © 2018 Gleb Radchenko. All rights reserved.
//

import Foundation
import UIKit

extension Promise where Element: UITableView {
    func insertRows(at paths: [IndexPath],
                    onBeforeInsert: @escaping ([IndexPath]) -> Void,
                    animation: UITableViewRowAnimation = .fade,
                    duration: TimeInterval = 0.3) -> Promise<Element> {
        
        return Promise() { (resolve) in
            self.execute { (result) in
                guard let tableView = result.unbox() else { resolve(result); return }
                onBeforeInsert(paths)
                tableView.insertRows(at: paths, with: animation)
                
                self.queue.asyncAfter(deadline: .now() + duration) {
                    resolve(result)
                }
            }
        }
    }
    
    func insertRow(at path: IndexPath,
                   onBeforeInsert: @escaping (IndexPath) -> Void,
                   animation: UITableViewRowAnimation = .fade,
                   duration: TimeInterval = 0.3) -> Promise<Element> {
        
        return insertRows(at: [path],
                          onBeforeInsert: { onBeforeInsert($0[0]) },
                          animation: animation,
                          duration: duration)
    }
    
    func reloadRows(at paths: [IndexPath],
                    onBeforeReload: @escaping ([IndexPath]) -> Void,
                    animation: UITableViewRowAnimation = .fade,
                    duration: TimeInterval = 0.3) -> Promise<Element> {
        
        return Promise() { (resolve) in
            self.execute { (result) in
                guard let tableView = result.unbox() else { resolve(result); return }
                onBeforeReload(paths)
                tableView.reloadRows(at: paths, with: animation)
                
                self.queue.asyncAfter(deadline: .now() + duration) {
                    resolve(result)
                }
            }
        }
    }
    
    func reloadRow(at path: IndexPath,
                   onBeforeReload: @escaping (IndexPath) -> Void,
                   animation: UITableViewRowAnimation = .fade,
                   duration: TimeInterval = 0.3) -> Promise<Element> {
        
        return reloadRows(at: [path],
                          onBeforeReload: { onBeforeReload($0[0]) },
                          animation: animation,
                          duration: duration)
    }
    
    func deleteRows(at paths: [IndexPath],
                    onBeforeDelete: @escaping ([IndexPath]) -> Void,
                    animation: UITableViewRowAnimation = .fade,
                    duration: TimeInterval = 0.3) -> Promise<Element> {
        
        return Promise() { (resolve) in
            self.execute { (result) in
                guard let tableView = result.unbox() else { resolve(result); return }
                onBeforeDelete(paths)
                tableView.deleteRows(at: paths, with: animation)
                
                self.queue.asyncAfter(deadline: .now() + duration) {
                    resolve(result)
                }
            }
        }
    }
    
    func deleteRow(at path: IndexPath,
                   onBeforeDelete: @escaping (IndexPath) -> Void,
                   animation: UITableViewRowAnimation = .fade,
                   duration: TimeInterval = 0.3) -> Promise<Element> {
        
        return deleteRows(at: [path],
                          onBeforeDelete: { onBeforeDelete($0[0]) },
                          animation: animation,
                          duration: duration)
    }
}

