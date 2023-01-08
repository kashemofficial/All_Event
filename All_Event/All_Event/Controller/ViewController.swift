//
//  ViewController.swift
//  All_Event
//
//  Created by Abul Kashem on 25/11/22.
//

import UIKit
import EventKit
import EventKitUI

struct eventModel {
    var title: String
    var date: String
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var eventData: [String : [eventModel]] = [:]
    var eventSection: [String] = []
    var titleForHeader: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        checkForCalendarAccess()
        
    }
    
    //MARK: Access Calendar
    
    func checkForCalendarAccess() {
        let eventStores = EKEventStore()
        switch EKEventStore.authorizationStatus(for: EKEntityType.event) {
        case .authorized:
            getAllEvents()
            
        case .denied:
            print("Access to the event store")
        case .notDetermined:
            eventStores.requestAccess(to: .event, completion: {[weak self] (granted: Bool, error: Error?) -> Void in
                if granted {
                    print("Access granted")
                    self?.getAllEvents()
                } else {
                    print("Access denied")
                }
            })
            
        default:
            print("Default Case")
        }
        self.tableView.reloadData()
    }
    
    //MARK: setUpTableView
    
    func setUpTableView(){
        let nib = UINib(nibName: "EventTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
    }
    
    //MARK: Events
    
    
    func getAllEvents(){
        let eventStore = EKEventStore()
        let calendars = eventStore.calendars(for: .event)
        for calendar in calendars {
            let lastMonthAgo = NSDate(timeIntervalSinceNow: -1460*24*3600)
            let oneMonthAfter = NSDate(timeIntervalSinceNow: +30*24*3600)
            let predicate = eventStore.predicateForEvents(withStart: lastMonthAgo as Date, end: oneMonthAfter as Date , calendars: [calendar])
            let events = eventStore.events(matching: predicate) as [EKEvent]
            
            for event in events{
                let date = event.startDate!
                let fmt = DateFormatter()
                fmt.dateFormat = "MM-dd-yyyy"
                let year = fmt.string(from: date)
                
                let start = year.index(year.startIndex, offsetBy: 6)
                let end = year.index(year.endIndex, offsetBy: -0)
                let range = start..<end
                
                let year2 = String(year[range])
                eventData[year2]?.append(eventModel(title: event.title, date: year))
                if eventData[year2] == nil {
                    eventData[year2] = [eventModel(title: event.title, date: year)]
                    titleForHeader.append(year2)
                }
                eventSection.append(year2)
                
            }
        }
    }
    
//    func getAllEvents2(){
//        let eventStore = EKEventStore()
//        let calendars = eventStore.calendars(for: .event)
//        for calendar in calendars {
//            let lastMonthAgo1 = NSDate(timeIntervalSinceNow: -2920*24*3600)
//            let oneMonthAfter1 = NSDate(timeIntervalSinceNow: +30*24*3600)
//            let predicate = eventStore.predicateForEvents(withStart: lastMonthAgo1 as Date, end: oneMonthAfter1 as Date , calendars: [calendar])
//            let events = eventStore.events(matching: predicate) as [EKEvent]
//
//            for event in events{
//                let date = event.startDate!
//                let fmt = DateFormatter()
//                fmt.dateFormat = "MM-dd-yyyy"
//                let year1 = fmt.string(from: date)
//
//                let start = year1.index(year1.startIndex, offsetBy: 6)
//                let end = year1.index(year1.endIndex, offsetBy: -0)
//                let range = start..<end
//                let year2 = String(year1[range])
//
//                eventData[year2]?.append(eventModel(title: event.title, date: year1))
//                if eventData[year2] == nil {
//                    eventData[year2] = [eventModel(title: event.title, date: year1)]
//                    titleForHeader.append(year2)
//
//                }
//                eventSection.append(year2)
//            }
//        }
//    }
//
    
    //    func getAllEvents3(){
    //        let eventStore = EKEventStore()
    //        let calendars = eventStore.calendars(for: .event)
    //        for calendar in calendars {
    //            let lastMonthAgo = NSDate(timeIntervalSinceNow: -4380*24*3600)
    //            let oneMonthAfter = NSDate(timeIntervalSinceNow: 30*24*3600)
    //            let predicate = eventStore.predicateForEvents(withStart: lastMonthAgo as Date, end: oneMonthAfter as Date , calendars: [calendar])
    //           // let events = eventStore.events(matching: predicate)
    //            let events = eventStore.events(matching: predicate) as [EKEvent]
    //
    //            for event in events{
    //                titles.append(event.title)
    //                let date = event.startDate!
    //                let fmt = DateFormatter()
    //                fmt.dateFormat = "yyyy-MM-dd"
    //                let stringDate = fmt.string(from: date)
    //                arrayDateString.append(stringDate)
    //            }
    //        }
    //    }
    
    
}

extension ViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return eventData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventData[self.eventSection[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EventTableViewCell
        cell.eventNameLabel.text = eventData[self.eventSection[indexPath.section]]![indexPath.row].title
        cell.startDateLabel.text = eventData[self.eventSection[indexPath.section]]![indexPath.row].date
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForHeader[section]
    }
    
}


