//
//  CalendarEventsViewController.swift
//  TeamAlgeria
//
//  Created by Nicole Neil on 12/5/23.
//

import UIKit

class CalendarEventsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addEventButton: UIButton!
    @IBOutlet weak var deleteEventButton: UIButton!
    
    
    @IBAction func addEventButtonTapped(_ sender: UIButton) {
        createEvent()
    }
    
    @IBAction func deleteEventButtonTapped(_ sender: UIButton) {
        deleteEvent()
    }
    
    
    var calendars: [UserCalendar] = []
    var events: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Fetch calendar events using the service
        CalendarEventsService.shared.fetchCalendarEvents { result in
            switch result {
            case .success(let calData):
                // Handle the calendar data
                self.handleCalendarData(calData)
                
            case .failure(let error):
                // Handle the error
                print("Error fetching calendar events: \(error.localizedDescription)")
            }
        }
    }
    
    func handleCalendarData(_ calData: CalData) {
        // Do something with the calendar data
        print("Success! Calendar data: \(calData)")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // One section for calendars, one for events
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? calendars.count : events.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

            if indexPath.section == 0 {
                let userCalendar = calendars[indexPath.row]
                cell.textLabel?.text = userCalendar.summary.rawValue
                cell.detailTextLabel?.text = "Calendar"
            } else {
                let event = events[indexPath.row]
                cell.textLabel?.text = event.summary.rawValue
                cell.detailTextLabel?.text = "Event"
            }

            return cell
        }
    
    func createEvent() {
        let newEvent = Event(
            id: "unique_id",
            summary: .testEventWithTime,  // You may need to set this appropriately based on your logic
            location: "Somewhere",
            start: End(date: nil, dateTime: Date(), timeZone: nil),
            end: End(date: nil, dateTime: Date(), timeZone: nil)
        )

        CalendarEventsService.shared.createEvent(event: newEvent) { result in
            switch result {
            case .success(let createdEvent):
                // Update the local events array
                self.events.append(createdEvent)

                // Reload the table view to reflect the changes
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }

            case .failure(let error):
                print("Error creating event: \(error.localizedDescription)")
            }
        }
    }

//    func updateEvent() {
//        guard let selectedEventIndex = tableView.indexPathForSelectedRow?.row else {
//            print("No event selected.")
//            return
//        }
//
//        var updatedEvent = events[selectedEventIndex]
//
//        // Assuming you have an appropriate case in ItemSummary for the updated summary
//        updatedEvent.summary = .updatedSummary
//
//        CalendarEventsService.shared.updateEvent(event: updatedEvent) { result in
//            switch result {
//            case .success(let updatedEvent):
//                // Update the local events array
//                self.events[selectedEventIndex] = updatedEvent
//
//                // Reload the table view to reflect the changes
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//
//            case .failure(let error):
//                print("Error updating event: \(error.localizedDescription)")
//            }
//        }
//    }

    func deleteEvent() {
        guard let selectedEventIndex = tableView.indexPathForSelectedRow?.row else {
            print("No event selected.")
            return
        }

        let eventIdToDelete = events[selectedEventIndex].id

        CalendarEventsService.shared.deleteEvent(eventId: eventIdToDelete) { result in
            switch result {
            case .success:
                // Remove the deleted event from the local events array
                self.events.remove(at: selectedEventIndex)

                // Reload the table view to reflect the changes
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }

            case .failure(let error):
                print("Error deleting event: \(error.localizedDescription)")
            }
        }
    }

}
