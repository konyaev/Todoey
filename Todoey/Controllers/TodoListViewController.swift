//
//  ViewController.swift
//  Todoey
//
//  Created by Mac on 16.10.2018.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray : [Item] = []
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }

    //MARK - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        return cell
    }
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new item?", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parent = self.selectedCategory
            self.itemArray.append(newItem)
            self.saveItems()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK Model manipulation methods
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("error saving context: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parent.name MATCHES %@", selectedCategory!.name!)
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        tableView.reloadData()
    }
    
}

//MARK: Search bar methods
extension TodoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

