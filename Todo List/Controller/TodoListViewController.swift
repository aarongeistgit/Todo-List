//
//  ViewController.swift
//  Todo List
//
//  Created by Aaron Geist on 3/5/18.
//  Copyright © 2018 Aaron Geist. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    let defaults = UserDefaults.standard
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(dataFilePath)
        
    }

    
    //MARK: - Create tableview data source methods
    //********************************************
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title

        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemArray.count
        
    }
    
    
    
    //MARK: - Create tableview delegaete method
    //*********************************************
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        print(indexPath.row, itemArray[indexPath.row].title, itemArray[indexPath.row].done)
        
//        context.delete(itemArray[indexPath.row])   //delete from database context first
//        itemArray.remove(at: indexPath.row)        //delete from tableveiw next
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

    //MARK: - Add New Items to the To Do List
    //********************************************
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textFieldEntry = UITextField()
        
        let alert = UIAlertController(title: "Add new to do list item.", message: "", preferredStyle: .alert
        )
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            
            let newItem = Item(context: self.context)
            newItem.title = textFieldEntry.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            
            self.saveItems()
            
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .default) { (actionCancel) in
            
        }
        
        alert.addAction(actionCancel)
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Create new item"
            textFieldEntry = alertTextField
        }
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Model manipulation methods
    
    func saveItems() {
        
        do {
            try context.save()
        } catch {
            print("error saving context: \(error)")
        }
        
        self.tableView.reloadData()
        
    }
    
    
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil){
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching from context: \(error)")
        }
        
        tableView.reloadData()

    }
    
}

// MARK: - Search Bar Methods

extension TodoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        } else {
            let request : NSFetchRequest<Item> = Item.fetchRequest()
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            loadItems(with: request)
        }
        
    }
    
}

