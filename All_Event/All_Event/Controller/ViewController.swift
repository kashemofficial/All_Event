//
//  ViewController.swift
//  All_Event
//
//  Created by Abul Kashem on 25/11/22.
//

import UIKit
import EventKit
import EventKitUI

class ViewController: UIViewController {
    
    var titles : [String] = []
    var startDates : [NSDate] = []
    var endDates : [NSDate] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Events()
        
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
       // self.tableView.reloadData()
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
        //print("cal \(calendars.count)")
        
        for calendar in calendars {
            let oneMonthAgo = NSDate(timeIntervalSinceNow: -365*24*3600)
            let oneMonthAfter = NSDate(timeIntervalSinceNow: +30*24*3600)
            let predicate = eventStore.predicateForEvents(withStart: oneMonthAgo as Date, end: oneMonthAfter as Date, calendars: [calendar])
            let events = eventStore.events(matching: predicate)
            for event in events {
                titles.append(event.title)
                startDates.append(event.startDate! as NSDate)
                //print("res = ",res)
                endDates.append(event.endDate! as NSDate)
            }
        }
    }
}

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EventTableViewCell
        cell.eventNameLabel.text = titles[indexPath.row]
        cell.startDateLabel.text = String(startDates[indexPath.row].description)
        //cell.endDateLabel.text = Int(String(endDates[indexPath.row]))
    
        return cell
    }
}



