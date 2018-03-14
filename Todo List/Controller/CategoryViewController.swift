//
//  CategoryViewController.swift
//  Todo List
//
//  Created by Aaron Geist on 3/10/18.
//  Copyright © 2018 Aaron Geist. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        print(dataFilePath)
        
        loadCategories()
        
    }

    //MARK: - tableView datasource methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categoryArray[indexPath.row]
        
        cell.textLabel?.text = category.name
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoryArray.count
        
    }
    
    //MARK: - Add new categories to the category list
    
    @IBAction func addButtonPreesed(_ sender: UIBarButtonItem) {
        
        var textFieldEntry = UITextField()
        
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            newCategory.name = textFieldEntry.text!
            
            self.categoryArray.append(newCategory)
            
            self.saveCategories()
            
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
    
    func saveCategories() {
        
        do {
            try context.save()
        } catch {
            print("Error saving catoegory to context: \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadCategories() {
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching category from context: \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    
    //MARK: - tableview delegate methods
    

    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row] 
        }
        
    }
    

    
}
