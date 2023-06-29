//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Theós on 27/06/2023.
//

import CodeScanner
import SwiftUI
import UserNotifications

struct ProspectsView: View {
    let filter: FilterType
    
    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    @State private var isShowingSort = false
    @State private var sort = SortType.name
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sortedProspects) { prospect in
                    HStack {
                        if filter == .none {
                            Image(systemName: prospect.isContacted ? "person.fill.checkmark" : "person.fill")
                                .font(.title)
                        }
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                    }
                    .swipeActions {
                        swipeActions(for: prospect)
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                Button {
                    isShowingSort = true
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
                
                Button {
                    isShowingScanner = true
                } label: {
                    Label("Scan", systemImage: "qrcode.viewfinder")
                }
            }
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Mohammed Li\nmohammed@mli.com", completion: handleScan)
            }
            .confirmationDialog("Sort prospects by", isPresented: $isShowingSort, titleVisibility: .visible) {
                Button("Name") {
                    sort = .name
                }
                
                Button("Most recent") {
                    sort = .date
                }
            }
        }
    }
    
    @ViewBuilder
    func swipeActions(for prospect: Prospect)->  some View {
        if prospect.isContacted {
            Button {
                prospects.toggle(prospect)
            } label: {
                Label("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark")
            }
            .tint(.blue)
        } else {
            Button {
                prospects.toggle(prospect)
            } label: {
                Label("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark")
            }
            .tint(.green)
            
            Button {
                addNotification(for: prospect)
            } label: {
                Label("Remind Me", systemImage: "bell")
            }
            .tint(.orange)
        }
    }
    
    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
        }
    }
    
    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter { $0.isContacted }
        case .uncontacted:
            return prospects.people.filter { !$0.isContacted }
        }
    }
    
    var sortedProspects: [Prospect] {
        switch sort {
        case .name:
            return filteredProspects.sorted { $0.name < $1.name }
        case .date:
            return filteredProspects.reversed()
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
       isShowingScanner = false
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }

            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            prospects.add(person)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()

        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default

            var dateComponents = DateComponents()
            dateComponents.hour = 9
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }

        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("D'oh")
                    }
                }
            }
        }
    }
}


extension ProspectsView {
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    enum SortType {
        case name, date
    }
}




struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
            .environmentObject(Prospects())
    }
}
