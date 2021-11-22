//
//  LoadViewController.swift
//  Extension
//
//  Created by Igor Polousov on 19.11.2021.
//

import UIKit

class LoadViewController: UITableViewController {
    
    // Массив с сохраненными скриптами
    var savedScriptsName = [UserScript]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Saved Scripts"

        print("1 \(savedScriptsName)")
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedScriptsName.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = savedScriptsName[indexPath.row].title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Action") as? ActionViewController {
            vc.scriptToLoad = savedScriptsName[indexPath.row].exampleScript
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            savedScriptsName.remove(at: indexPath.row)
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Action") as? ActionViewController {
                vc.savedScriptsName = savedScriptsName
                vc.saveName()
            }
        }
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}

