//
//  CategoryViewController.swift
//  Todo List
//
//  Created by Aaron Geist on 3/10/18.
//  Copyright © 2018 Aaron Geist. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categoryArray : Results<Category>?
    
    var items : Results<Item>?       // for testing items for deletion
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(dataFilePath)
        
        loadCategories()
        
        tableView.separatorStyle = .none

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(CategoryViewController.editCategoryName))
        self.view.addGestureRecognizer(longPressGesture)


    }


    //MARK: - tableView datasource methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categores Added"
        
        cell.backgroundColor = UIColor(hexString: categoryArray?[indexPath.row].color ?? "1D9BF6")
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        

        return cell
        
    }
    
    // Gesture Long press
    
    @objc func editCategoryName(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                
                guard let category = categoryArray?[indexPath.row] else { fatalError() }
                
                var textFieldEntry = UITextField()
                
                let alert = UIAlertController(title: "Edit Category: \(category.name)", message: "", preferredStyle: .alert)
                let action = UIAlertAction(title: "Change", style: .default) { (action) in
                    
                    do {
                        try self.realm.write {
                            category.name = textFieldEntry.text!
                        }
                    } catch {
                        print("Error updating category name in Realm: \(error)")
                    }
                    self.tableView.reloadData()
                    
                }
                
                let actionCancel = UIAlertAction(title: "Cancel", style: .default) { (actionCancel) in
                    
                }
                
                alert.addAction(actionCancel)
                alert.addAction(action)
                alert.addTextField { (alertTextField) in
                    
                    alertTextField.text = category.name
                    textFieldEntry = alertTextField
                    
                }
                
                present(alert, animated: true, completion: nil)    
                
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoryArray?.count ?? 1
        
    }
    
    //MARK: - Add new categories to the category list
    
    @IBAction func addButtonPreesed(_ sender: UIBarButtonItem) {
        
        var textFieldEntry = UITextField()
        
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textFieldEntry.text!
            
            newCategory.color = UIColor.randomFlat.hexValue()
            
            self.save(category: newCategory)
            
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .default) { (actionCancel) in
            
        }
        
        alert.addAction(actionCancel)
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Create new category"
            textFieldEntry = alertTextField
            
        }
        
        present(alert, animated: true, completion: nil)
        
    }

    
    //MARK: - data manipulation methods
    
    func save(category : Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category to realm: \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadCategories() {
        
        categoryArray = realm.objects(Category.self).sorted(byKeyPath: "name")
        
        tableView.reloadData()
        
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeleteion = self.categoryArray?[indexPath.row] {
            do {
                try self.realm.write {
                    
                    for item in categoryForDeleteion.items {
                        realm.delete(item)  //remove all child items
                    }
                    
                    self.realm.delete(categoryForDeleteion)
                }
            } catch {
                print("Error deleting from Realm: \(error)")
            }
            
        }
    }
    
    
    //MARK: - tableview delegate methods
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row] 
        }
        
    }
    
}

// MARK:- Extensions

extension CategoryViewController {
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        
        changeCategoryColors()
        
    }
    
    func changeCategoryColors() {
        
        if categoryArray != nil {
            for category in categoryArray! {
                do {
                    try realm.write {
                        category.color = UIColor.randomFlat.hexValue()
                    }
                } catch {
                    print("Couldn't save new color for category: \(error)")
                }
            }
            
            tableView.reloadData()
            
        } else {
            print("No categores to change color.")
        }
    }
    
    
}


