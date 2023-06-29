//
//  Prospect.swift
//  HotProspects
//
//  Created by Theós on 27/06/2023.
//

import SwiftUI

class Prospect: Identifiable, Codable {
    var id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    fileprivate(set) var isContacted = false
}

@MainActor class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]
    
    let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedProspects")

    init() {
        people = (try? FileManager.default.readContent(of: savePath)) ?? []
    }
    
    private func save() {
        try? FileManager.default.writeContents(of: people, to: savePath)
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
}
