//
//  Sidebar.swift
//  FSNotes
//
//  Created by Oleksandr Glushchenko on 4/7/18.
//  Copyright © 2018 Oleksandr Glushchenko. All rights reserved.
//

import Cocoa
typealias Image = NSImage

class Sidebar {
    var list = [Any]()
    let storage = Storage.sharedInstance()
    public var items = [[SidebarItem]]()
    
    init() {
        let night = ""
        let inboxName = "sidebarInbox"
        var system = [SidebarItem]()

        if let project = Storage.sharedInstance().getDefault() {
            let inbox = SidebarItem(name: NSLocalizedString("Inbox", comment: ""), project: project, type: .Inbox, icon: getImage(named: inboxName))
            system.append(inbox)
        }

        let notes = SidebarItem(name: NSLocalizedString("Notes", comment: ""), type: .All, icon: getImage(named: "home\(night).png"))
        system.append(notes)

        let trashProject = Storage.sharedInstance().getDefaultTrash()
        let trash = SidebarItem(name: NSLocalizedString("Trash", comment: ""), project: trashProject, type: .Trash, icon: getImage(named: "trash\(night)"))
        
        system.append(trash)
        list = system

        let rootProjects = storage.getRootProjects()

        for project in rootProjects {
            let icon = getImage(named: "repository\(night).png")
            let type: SidebarItemType = .Label
            
            list.append(SidebarItem(name: project.label, project: project, type: type, icon: icon))
            
            let childProjects = storage.getChildProjects(project: project)
            for childProject in childProjects {
                if childProject.url == UserDefaultsManagement.archiveDirectory {
                    continue
                }
                
                list.append(SidebarItem(name: childProject.label, project: childProject, type: .Category, icon: icon))
            }
        }
    }
    
    public func getList() -> [Any] {
        return list
    }

    
    public func getProjects() -> [SidebarItem] {
        return list.filter({ ($0 as? SidebarItem)?.type == .Category && ($0 as? SidebarItem)?.project != nil && ($0 as? SidebarItem)!.project!.showInSidebar }) as! [SidebarItem]
    }
        
    private func getImage(named: String) -> Image? {
        if let image = NSImage(named: named) {
            return image
        }
        
        return nil
    }

}
