//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ViewController: SwipeTableViewController {
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    let realm = try! Realm()
    var todoItems: Results<Item>?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let bgNavBar = selectedCategory?.background {
            title = selectedCategory!.name
            navigationController?.navigationBar.barTintColor = UIColor(hexString: bgNavBar)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.isChecked ? .checkmark : .none
            
            if let bgColor = UIColor(hexString: selectedCategory!.background)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = bgColor
                cell.textLabel?.textColor = ContrastColorOf(bgColor, returnFlat: true)
            }
        } else {
            cell.textLabel?.text = "No items added"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.isChecked = !item.isChecked
                }
            } catch {
                print("Error while updating \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func onAddItemPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()

        let alert = UIAlertController(title: "Add new Todoey", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let title = textField.text, let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = title
                        newItem.timeStamp = Date()
                        currentCategory.items.append(newItem)
                        self.realm.add(newItem)
                    }
                } catch {
                    print("Error saving item \(error)")
                }
                self.tableView.reloadData()
            }
        }

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }

        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Core Data methods
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func performDelete(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Error while deleting \(error)")
            }
        }
    }
}

//MARK: - Search bar methods

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!)
            .sorted(byKeyPath: "timeStamp", ascending: true)
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            tableView.reloadData()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

