//
//  ViewController.swift
//  DragDrop
//
//  Created by Mac on 1/10/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var tableView1: UITableView!
    @IBOutlet weak var tableView2: UITableView!
    
    let table1DataSource = ItemDataSource(items: [
        Item("Item 1", details: "Hello how"),
        Item("Item 2", details: "Google me"),
        Item("Item 3", details: "Writing log"),
        Item("Item 4", details: "iPhone X"),
        Item("Item 5", details: "Subscribe to you")
        Item("Item 6", details: "MacOS High Sierra")
        ])
    let table2DataSource = ItemDataSource(items: [])
    
    var srcTableView: UITableView?
    var srcIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableViews =  [tableView1, tableView2]
        for tableView in tableViews {
            if let tableView = tableView {
                tableView.layer.borderWidth = 1
                
                tableView.dataSource = dataSourceForTableView(tableView)
                tableView.dragInteractionEnabled = true
                tableView.dragDelegate = self
                tableView.dropDelegate = self
                tableView.reloadData()
            }
        }
    }
    
    func dataSourceForTableView(_ tableView: UITableView) -> ItemDataSource {
        if tableView == tableView1 {
            return table1DataSource
        } else {
            return table2DataSource
        }
    }
}

extension MainViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        self.srcTableView = tableView
        self.srcIndexPath = indexPath
        
        let dataSource = dataSourceForTableView(tableView)
        return dataSource.dragItems(for: indexPath)
    }
}

extension MainViewController: UITableViewDropDelegate {

    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if tableView.hasActiveDrag {
            if session.items.count > 1 {
                return UITableViewDropProposal(operation: .cancel)
            } else {
                return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        } else {
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        
        let dataSource = dataSourceForTableView(tableView)
        
        let destIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destIndexPath = indexPath
        } else {
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destIndexPath = IndexPath(row: row, section: section)
        }
        
        for item in coordinator.items {
            //same tableview
            if let srcIndexPath = item.sourceIndexPath {
                print("Same table view")
                dataSource.moveItem(at: srcIndexPath.row, to: destIndexPath.row)
                DispatchQueue.main.async {
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [srcIndexPath], with: .automatic)
                    tableView.insertRows(at: [destIndexPath], with: .automatic)
                    tableView.endUpdates()
                }
            }
            //different table view
            else if let newItem = item.dragItem.localObject as? Item {
                print("Different table view")
                guard let srcTableView = self.srcTableView, let srcIndexPath = self.srcIndexPath else { return }
                
                dataSourceForTableView(srcTableView).removeItem(at: srcIndexPath.row)
                
                dataSource.addItem(newItem, at: destIndexPath.row)
                DispatchQueue.main.async {
                    srcTableView.deleteRows(at: [srcIndexPath], with: .automatic)
                    tableView.insertRows(at: [destIndexPath], with: .automatic)
                }
            }
        }
    }
}



