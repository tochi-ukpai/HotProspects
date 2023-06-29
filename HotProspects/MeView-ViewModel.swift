//
//  MeView-ViewModel.swift
//  HotProspects
//
//  Created by Theós on 29/06/2023.
//

import SwiftUI

class UserDetails: Codable, Equatable {
    static func == (lhs: UserDetails, rhs: UserDetails) -> Bool {
        lhs.name == rhs.name && lhs.emailAddress == rhs.emailAddress
    }
    
    var name: String
    var emailAddress: String
    
    init(name: String, emailAddress: String) {
        self.name = name
        self.emailAddress = emailAddress
    }
}

extension MeView {
    @MainActor class ViewModel: ObservableObject {
        @Published var user: UserDetails {
            didSet {
                save()
            }
        }
        
        let userdetails = "MyInfo"
        
        init() {
            if let data = UserDefaults.standard.data(forKey: userdetails) {
                if let user = try? JSONDecoder().decode(UserDetails.self, from: data) {
                    self.user = user
                    return
                }
            }
            
            user = UserDetails(name: "Anonymous", emailAddress: "you@yoursite.com")
        }
        
        private func save() {
            if let data = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(data, forKey: userdetails)
            }
        }
    }
}
