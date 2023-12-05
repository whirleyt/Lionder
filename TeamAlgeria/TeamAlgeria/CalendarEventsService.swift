//
//  CalendarEventsService.swift
//  TeamAlgeria
//
//  Created by Nicole Neil on 12/5/23.
//

import Foundation

class CalendarEventsService {
    static let shared = CalendarEventsService()
    
    private let baseUrl = "calendarevents.p.rapidapi.com"
    private let apiKey = "0241bf0e78msh67fa3ad73638896p1a736djsnebfa9c090002"
    
    func fetchCalendarEvents(completion: @escaping (Result<CalData, Error>) -> Void) {
        let endpoint = "/api/events"
        let url = URL(string: baseUrl + endpoint)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let calendarData = try JSONDecoder().decode(CalData.self, from: data)
                completion(.success(calendarData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func createEvent(event: Event, completion: @escaping (Result<Event, Error>) -> Void) {
        // Implement logic to send a POST request to create a new event & Use URLSession
        guard let url = URL(string: "\(baseUrl)/api/events") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")

        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(event)

            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(.failure(error ?? NSError(domain: "Unknown error", code: 0, userInfo: nil)))
                    return
                }

                do {
                    let createdEvent = try JSONDecoder().decode(Event.self, from: data)
                    completion(.success(createdEvent))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }

//    func updateEvent(event: Event, completion: @escaping (Result<Event, Error>) -> Void) {
//        // Implement logic to send a PUT request to update an existing event
//        guard let url = URL(string: "\(baseUrl)/api/events/\(event.id)") else {
//            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "PUT"
//        request.addValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
//
//        do {
//            let encoder = JSONEncoder()
//            request.httpBody = try encoder.encode(event)
//
//            URLSession.shared.dataTask(with: request) { data, response, error in
//                guard let data = data, error == nil else {
//                    completion(.failure(error ?? NSError(domain: "Unknown error", code: 0, userInfo: nil)))
//                    return
//                }
//
//                do {
//                    let updatedEvent = try JSONDecoder().decode(Event.self, from: data)
//                    completion(.success(updatedEvent))
//                } catch {
//                    completion(.failure(error))
//                }
//            }.resume()
//        } catch {
//            completion(.failure(error))
//        }
//    }

    func deleteEvent(eventId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Implement logic to send a DELETE request to delete an event
        guard let url = URL(string: "\(baseUrl)/api/events/\(eventId)") else {
                    completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
                    return
                }

                var request = URLRequest(url: url)
                request.httpMethod = "DELETE"
                request.addValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")

                URLSession.shared.dataTask(with: request) { data, response, error in
                    guard error == nil else {
                        completion(.failure(error!))
                        return
                    }

                    // Assuming a successful deletion returns an empty response
                    completion(.success(()))
                }.resume()
    }
    
}
