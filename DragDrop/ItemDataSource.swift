//
//  ItemDataSource.swift
//  DragDrop
//
//  Created by Mac on 1/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

class ItemDataSource: NSObject, UITableViewDataSource {
    
    var items: [Item]
    
    init(items: [Item]) {
        self.items = items
        super.init()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        let item = items[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.details
        
        return cell
    }
    
    func moveItem(at srcIndex: Int, to destIndex: Int) {
        guard srcIndex != destIndex else { return }
        
        let item = items[srcIndex]
        items.remove(at: srcIndex)
        items.insert(item, at: destIndex)
    }
    
    func addItem(_ newItem: Item, at index: Int) {
        items.insert(newItem, at: index)
    }
    
    func removeItem(at index: Int) {
        items.remove(at: index)
    }
    
    func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        let item = items[indexPath.row]
        
        let itemProvider = NSItemProvider()
        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in
            
            let data = item.title.data(using: .utf8)
            completion(data, nil)
            return nil
        }
        
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
        
    }
    
}
