//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Sudhan Ram on 11/04/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
        
        loadCatgeory()
    }
    
    //MARK: - TableView DataSource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "Add a new category"
        cell.backgroundColor = UIColor(hexString: categories?[indexPath.row].background ?? "#FFFFFF")
        return cell
    }
    
    //MARK: - TableView Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - CRUD operations
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCatgeory() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    override func performDelete(at indexPath: IndexPath) {
        if let category = categories?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(category)
                }
            } catch {
                print("Error while deleting \(error)")
            }
        }
    }

    @IBAction func onAddCategoryPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()

                let alert = UIAlertController(title: "Add new Todoey", message: "", preferredStyle: .alert)
                let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
                    if let title = textField.text {
                        let newCategory = Category()
                        newCategory.name = title
                        newCategory.background = UIColor.randomFlat().hexValue()
                        self.save(category: newCategory)
                    }
                }

                alert.addTextField { (alertTextField) in
                    alertTextField.placeholder = "Create new category"
                    textField = alertTextField
                }

                alert.addAction(action)
                present(alert, animated: true, completion: nil)
    }
}
