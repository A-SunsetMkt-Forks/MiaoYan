//
//  PreferencesUserInterfaceViewController.swift
//  FSNotes
//
//  Created by Oleksandr Glushchenko on 3/17/19.
//  Copyright © 2019 Oleksandr Glushchenko. All rights reserved.
//

import Cocoa

class PreferencesUserInterfaceViewController: NSViewController {
    @IBOutlet weak var fontPreview: NSTextField!
    @IBOutlet weak var noteFontColor: NSColorWell!
    @IBOutlet weak var backgroundColor: NSColorWell!
    @IBOutlet weak var backgroundLabel: NSTextField!
    @IBOutlet weak var hideDate: NSButton!
    @IBOutlet weak var firstLineAsTitle: NSButton!

    override func viewWillAppear() {
        super.viewWillAppear()
        preferredContentSize = NSSize(width: 467, height: 460)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setFontPreview()

        let hideBackgroundOption = UserDefaultsManagement.appearanceType != .Custom

        backgroundColor.isHidden = hideBackgroundOption
        backgroundLabel.isHidden = hideBackgroundOption
    }

    override func viewDidAppear() {
        self.view.window!.title = NSLocalizedString("Preferences", comment: "")

        noteFontColor.color = UserDefaultsManagement.fontColor
        backgroundColor.color = UserDefaultsManagement.bgColor

        hideDate.state = UserDefaultsManagement.hideDate ? .on : .off

        firstLineAsTitle.state = UserDefaultsManagement.firstLineAsTitle ? .on : .off

        let hideBackgroundOption = UserDefaultsManagement.appearanceType != .Custom

        backgroundColor.isHidden = hideBackgroundOption
        backgroundLabel.isHidden = hideBackgroundOption
    }

    @IBAction func changeHideOnDeactivate(_ sender: NSButton) {
        // We don't need to set the user defaults value here as the checkbox is
        // bound to it. We do need to update each window's hideOnDeactivate.
        for window in NSApplication.shared.windows {
            if window.className == "NSStatusBarWindow" {
                continue
            }

            window.hidesOnDeactivate = UserDefaultsManagement.hideOnDeactivate
        }
    }

    @IBAction func verticalOrientation(_ sender: Any) {
        guard let vc = ViewController.shared() else { return }

        UserDefaultsManagement.horizontalOrientation = false

        vc.splitView.isVertical = true
        vc.splitView.setPosition(215, ofDividerAt: 0)

        UserDefaultsManagement.cellSpacing = 38
   
        vc.setTableRowHeight()
    }

    @IBAction func horizontalOrientation(_ sender: Any) {
        guard let vc = ViewController.shared() else { return }

        UserDefaultsManagement.horizontalOrientation = true

        vc.splitView.isVertical = false
        vc.splitView.setPosition(145, ofDividerAt: 0)

        UserDefaultsManagement.cellSpacing = 12

        vc.setTableRowHeight()
        vc.notesTableView.reloadData()
    }

    @IBAction func setFont(_ sender: NSButton) {
        let fontManager = NSFontManager.shared
        if UserDefaultsManagement.noteFont != nil {
            fontManager.setSelectedFont(UserDefaultsManagement.noteFont!, isMultiple: false)
        }

        fontManager.orderFrontFontPanel(self)
        fontManager.target = self
    }

    @IBAction func setFontColor(_ sender: NSColorWell) {
        guard let vc = ViewController.shared() else { return }

        UserDefaultsManagement.fontColor = sender.color
        vc.editArea.setEditorTextColor(sender.color)
        vc.refillEditArea()
    }

    @IBAction func setBgColor(_ sender: NSColorWell) {
        guard let vc = ViewController.shared() else { return }

        UserDefaultsManagement.bgColor = sender.color

        vc.editArea.backgroundColor = sender.color
    }

    @IBAction func changeCellSpacing(_ sender: NSSlider) {
        guard let vc = ViewController.shared() else { return }


        vc.setTableRowHeight()
    }

    @IBAction func changePreview(_ sender: Any) {
        guard let vc = ViewController.shared() else { return }

        UserDefaultsManagement.hidePreview = ((sender as AnyObject).state == NSControl.StateValue.on)
        vc.notesTableView.reloadData()
    }

    @IBAction func textMatchAutoSelection(_ sender: NSButton) {
        UserDefaultsManagement.textMatchAutoSelection = (sender.state == .on)
    }

    @IBAction func hideImagesPreview(_ sender: NSButton) {
        UserDefaultsManagement.hidePreviewImages = sender.state == .on

        guard let vc = ViewController.shared() else { return }
        vc.notesTableView.reloadData()
    }

    @IBAction func changePreviewFontSize(_ sender: NSPopUpButton) {
        guard let tag = sender.selectedItem?.tag else { return }

        UserDefaultsManagement.previewFontSize = tag

        guard let vc = ViewController.shared() else { return }
        vc.notesTableView.reloadData()
    }

    @IBAction func hideDate(_ sender: NSButton) {
        UserDefaultsManagement.hideDate = (sender.state == .on)

        guard let vc = ViewController.shared() else { return }
        vc.notesTableView.reloadData()
    }

    @IBAction func firstLineAsTitle(_ sender: NSButton) {
        UserDefaultsManagement.firstLineAsTitle = (sender.state == .on)

        let storage = Storage.sharedInstance()
        let projects = storage.getProjects()
        for project in projects {
            project.loadSettings()
        }

        for note in storage.noteList {
            note.invalidateCache()
        }

        guard let vc = ViewController.shared() else { return }
        vc.notesTableView.reloadData()
    }

    @IBAction func changeFont(_ sender: Any?) {
        guard let vc = ViewController.shared() else { return }

        let fontManager = NSFontManager.shared
        let newFont = fontManager.convert(UserDefaultsManagement.noteFont!)
        UserDefaultsManagement.noteFont = newFont

        vc.refillEditArea()
        vc.reloadView()

        setFontPreview()
    }

    private func setFontPreview() {
        fontPreview.font = NSFont(name: UserDefaultsManagement.noteFont.fontName, size: 13)
        fontPreview.stringValue = "\(UserDefaultsManagement.noteFont.fontName) \(UserDefaultsManagement.noteFont.pointSize)pt"
    }

}
