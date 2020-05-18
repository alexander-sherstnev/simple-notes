//
//  EditNoteViewController.swift
//  Simple Notes
//
//  Created by Alexander Sherstnev on 5/17/20.
//  Copyright © 2020 Alexander Sherstnev. All rights reserved.
//

import UIKit
import IGColorPicker
import SearchTextField
import TagListView

class EditNoteViewController: UIViewController, UITextFieldDelegate, TagListViewDelegate, ColorPickerViewDelegateFlowLayout, UITextViewDelegate {

    @IBOutlet weak var _titleTextField: UITextField!
    @IBOutlet weak var _tagTextField: SearchTextField!
    @IBOutlet weak var _tagListView: TagListView!
    @IBOutlet weak var _colorPickerView: ColorPickerView!
    @IBOutlet weak var _contentTextView: UITextView!
    
    var note: Note? = nil
    var _tags: [Tag] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _tags = Repository.retrieveTags()
        setupTagTextField()
        setupTagListView()
        setupColorPickerView()
        
        _contentTextView.delegate = self
        
        if note == nil {
            navigationItem.title = "New"
            _contentTextView.text = "Enter note..."
            _contentTextView.textColor = UIColor.lightGray
        } else {
            _titleTextField.text = note?.title
            
            var tags: [String] = []
            for tag in note?.tags?.allObjects as! [Tag] { tags.append(tag.value ?? "") }
            _tagListView.addTags(tags)
    
            _colorPickerView.preselectedIndex = Int(note?.color ?? 0)
            
            _contentTextView.text = note?.content
        }
    }
    
    // MARK: - Methods
    
    func setupTagTextField() {
        var filterItems: [String] = []
        for tag in _tags { filterItems.append(tag.value!) }
        
        _tagTextField.filterStrings(filterItems)
        _tagTextField.delegate = self
        _tagTextField.theme.bgColor = UIColor(white: 1.0, alpha: 1.0)
        _tagTextField.comparisonOptions = [.caseInsensitive]
        _tagTextField.maxNumberOfResults = 10
        _tagTextField.minCharactersNumberToStartFiltering = 2
        _tagTextField.startVisible = true
        _tagTextField.itemSelectionHandler = {
            filteredResults, itemPosition in
            
            let tag = filteredResults[itemPosition]
            self.addTag(tag.title)
            self._tagTextField.text = ""
        }
    }
    
    func setupTagListView() {
        _tagListView.delegate = self
    }
    
    func setupColorPickerView() {
        _colorPickerView.layoutDelegate = self
        _colorPickerView.colors = Constants.colors
        _colorPickerView.preselectedIndex = _colorPickerView.colors.indices.first
    }
    
    func addTag(_ tag: String) {
        if !_tagListView.tagViews.contains(where: { (tagView) -> Bool in return tagView.currentTitle == tag.lowercased() }) {
            _tagListView.addTag(tag.lowercased())
        }
    }

    // MARK: - Actions
    
    @IBAction func save(_ sender: Any) {
        if note == nil { note = Note(context: Repository.context) }
        
        note?.tags = NSSet()
        Repository.save()
        
        for tagView in _tagListView.tagViews {
            var tag = _tags.first { (tag) -> Bool in return tag.value == tagView.currentTitle }
            if tag == nil {
                tag = Tag(context: Repository.context)
                tag?.value = tagView.currentTitle
            }
            
            note?.addToTags(tag!)
        }
        
        note?.title = _titleTextField.text
        note?.content = _contentTextView.text
        note?.color = Int16(_colorPickerView.indexOfSelectedColor ?? 0)
        note?.date = Date()
        
        Repository.save()

        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Color Picker Flow Layout
    
    func colorPickerView(_ colorPickerView: ColorPickerView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 24, height: 24)
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func colorPickerView(_ colorPickerView: ColorPickerView, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - Text Field
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let value = _tagTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                          !value.isEmpty else {
            _tagTextField.text = ""
            return true
        }
        
        addTag(value)
        _tagTextField.text = ""

        return true
    }
    
    // MARK: - Tag List View
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        _tagListView.removeTagView(tagView)
    }
    
    // MARK: - Text View
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if _contentTextView.textColor == UIColor.lightGray {
            _contentTextView.text = nil
            _contentTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if _contentTextView.text.isEmpty {
            _contentTextView.text = "Enter note..."
            _contentTextView.textColor = UIColor.lightGray
        }
    }
}
