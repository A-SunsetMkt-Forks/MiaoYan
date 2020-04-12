//
//  ProjectSettingsViewController.swift
//  FSNotes
//
//  Created by Oleksandr Glushchenko on 11/23/18.
//  Copyright © 2018 Oleksandr Glushchenko. All rights reserved.
//

import Cocoa
import Carbon.HIToolbox

class ProjectSettingsViewController: NSViewController {

    private var project: Project?

    @IBOutlet weak var modificationDate: NSButton!
    @IBOutlet weak var creationDate: NSButton!
    @IBOutlet weak var titleButton: NSButton!
    @IBOutlet weak var sortByGlobal: NSButton!

    @IBOutlet weak var directionASC: NSButton!
    @IBOutlet weak var directionDESC: NSButton!

    @IBOutlet weak var showInAll: NSButton!
    @IBOutlet weak var firstLineAsTitle: NSButton!

    @IBAction func sortBy(_ sender: NSButton) {
        guard let project = project else { return }

        let sortBy = SortBy(rawValue: sender.identifier!.rawValue)!
        if sortBy != .none {
            project.sortBy = sortBy
        }

        project.sortBySettings = sortBy
        project.saveSettings()

        guard let vc = ViewController.shared() else { return }
        vc.updateTable()
    }

    @IBAction func sortDirection(_ sender: NSButton) {
        guard let project = project else { return }

        let direction = SortDirection(rawValue: sender.identifier!.rawValue)!
        if project.sortBySettings != .none {
            project.sortDirection = direction
        }

        project.sortDirectionSettings = direction
        project.saveSettings()

        guard let vc = ViewController.shared() else { return }
        vc.updateTable()
    }


    @IBAction func showNotesInMainList(_ sender: NSButton) {
        project?.showInCommon = sender.state == .on
        project?.saveSettings()
    }

    @IBAction func firstLineAsTitle(_ sender: NSButton) {
        guard let project = self.project else { return }

        project.firstLineAsTitle = sender.state == .on
        project.saveSettings()

        let notes = Storage.sharedInstance().getNotesBy(project: project)
        for note in notes {
            note.invalidateCache()
        }

        guard let vc = ViewController.shared() else { return }
        vc.notesTableView.reloadData()
    }

    @IBAction func close(_ sender: Any) {
        self.dismiss(nil)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == kVK_Return || event.keyCode == kVK_Escape {
            self.dismiss(nil)
        }
    }

    public func load(project: Project) {
        showInAll.state = project.showInCommon ? .on : .off
        firstLineAsTitle.state = project.firstLineAsTitle ? .on : .off

        modificationDate.state = project.sortBySettings == .modificationDate ? .on : .off
        creationDate.state = project.sortBySettings == .creationDate ? .on : .off
        titleButton.state = project.sortBySettings == .title ? .on : .off
        sortByGlobal.state = project.sortBySettings == .none ? .on : .off

        directionASC.state = project.sortDirectionSettings == .asc ? .on : .off
        directionDESC.state = project.sortDirectionSettings == .desc ? .on : .off

        self.project = project
    }
}
