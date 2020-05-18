//
//  NotesTableViewController.swift
//  Simple Notes
//
//  Created by Alexander Sherstnev on 5/17/20.
//  Copyright © 2020 Alexander Sherstnev. All rights reserved.
//

import UIKit
import Highlighter

class NotesTableViewController: UITableViewController, UISearchResultsUpdating {

    var _notes: [Note] = []
    var _filteredNotes: [Note] = []
    var _searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.obscuresBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.definesPresentationContext = true

            tableView.tableHeaderView = controller.searchBar

            return controller
        })()
        
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        _notes = Repository.retriveNotes()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _searchController.isActive ? _filteredNotes.count : _notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = _searchController.isActive ? _filteredNotes[indexPath.row] : _notes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Table Cell", for: indexPath) as! NoteTableViewCell
        
        cell.titleLabel.text = note.title
        cell.contentTextView.text = note.content
        
        var tags: [String] = []
        for tag in note.tags?.allObjects as! [Tag] { tags.append(tag.value ?? "") }
        cell.tagListView.removeAllTags()
        cell.tagListView.addTags(tags)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        cell.dateLabel.text = dateFormatter.string(from: note.date!)
        
        cell.colorView.backgroundColor = UIColor.systemGray6
        if note.color > 0 {
            cell.colorView.backgroundColor = Constants.colors[Int(note.color)]
        }
        
        let searchText = _searchController.searchBar.text ?? ""
        cell.highlight(text: searchText,
                       normal: [NSAttributedString.Key.backgroundColor: UIColor.systemBackground],
                       highlight: [NSAttributedString.Key.backgroundColor: searchText.isEmpty ? UIColor.systemBackground : UIColor.yellow])

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let note = _notes.remove(at: indexPath.row)
            Repository.context.delete(note)
            Repository.save()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Edit Note" {
            let indexPath = self.tableView.indexPathForSelectedRow!
            let note = _searchController.isActive ? _filteredNotes[indexPath.row] : _notes[indexPath.row]
            
            let editNoteViewController = segue.destination as! EditNoteViewController
            editNoteViewController.note = note
            _searchController.isActive = false
        }
    }
    
    // MARK: - Serach
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let search = searchController.searchBar.text else {
            tableView.reloadData()
            return
        }
        
        if search.isEmpty {
            _filteredNotes = _notes
            tableView.reloadData()
            return
        }
        
        _filteredNotes = _notes.filter { (note) -> Bool in
            return note.title?.range(of: search, options: .caseInsensitive) != nil ||
                   note.content?.range(of: search, options: .caseInsensitive) != nil ||
                (note.tags?.allObjects as! [Tag]).filter({ (tag: Tag) -> Bool in
                    return tag.value?.range(of: search, options: .caseInsensitive) != nil
                    }).count > 0
        }
        
        tableView.reloadData()
    }
}
