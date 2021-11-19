//
//  LoadViewController.swift
//  Extension
//
//  Created by Igor Polousov on 19.11.2021.
//

import UIKit

class LoadViewController: UITableViewController {
    
    var savedScriptsName = [UserScript]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    title = "Saved Scripts"
        
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedScriptsName.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let script = savedScriptsName[indexPath.row]
        
        cell.textLabel?.text = script.title
        return cell
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if savedScriptsName.isEmpty {
                if let vc = storyboard?.instantiateViewController(withIdentifier: "LoadScript") as? ActionViewController {
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}

