//
//  ViewController.swift
//  Todo List
//
//  Created by Aaron Geist on 3/5/18.
//  Copyright © 2018 Aaron Geist. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var todoItems : Results<Item>?
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    let realm = try! Realm()
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(dataFilePath)
        
        tableView.separatorStyle = .none
        

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.title = selectedCategory?.name
        
        guard let colorHex = selectedCategory?.color else { fatalError() }
        updateNavBar(withHexCode: colorHex)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: "30598B")
        
    }
    
    func updateNavBar(withHexCode colorHexCode : String) {
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
        guard let navBarColor = UIColor(hexString: colorHexCode) else { fatalError() }
        navBar.barTintColor = navBarColor
        searchBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        
    }

    
    //MARK: - Create tableview data source methods
    //********************************************
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            
            let percentage : CGFloat = CGFloat(indexPath.row) / CGFloat((todoItems?.count)!)
            print("Percentage darkened: \(percentage)%")

            if let categoryColor : UIColor = HexColor((selectedCategory?.color)!) {
                cell.backgroundColor = categoryColor.darken(byPercentage: percentage)
                cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
            }
            
        } else {
            cell.textLabel?.text = "No items added"
        }
        
        return cell
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return todoItems?.count ?? 1
        
    }
    
    
    //MARK: - Create tableview delegaete method
    //*********************************************
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("error updating Realm: ", error)
            }
            
            tableView.reloadData()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    

    //MARK: - Add New Items to the To Do List
    //********************************************
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textFieldEntry = UITextField()
        
        let alert = UIAlertController(title: "Add new to do list item.", message: "", preferredStyle: .alert
        )
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in

            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textFieldEntry.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("error saving item to realm: \(error)")
                }
            }
  
            self.tableView.reloadData()
            
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
    
    
    func loadItems(){

        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()

    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting from Realm: \(error)")
            }
            
        }

    }
        
    
}

// MARK: - Search Bar Methods

extension TodoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        } else {
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        }
        
    }
    
}

