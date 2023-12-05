// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let calData = try? JSONDecoder().decode(CalData.self, from: jsonData)

import Foundation

// MARK: - CalData
struct CalData: Codable {
    let success: Bool
    let data: UserCalendar
}

// MARK: - DataClass --> Calendar
struct UserCalendar: Codable {
    let kind, etag: String
    let summary: DisplayNameEnum
    let description, updated, timeZone, accessRole: String
    let defaultReminders: [JSONAny]
    let items: [Event]
    let maxDate, minDate: Date
}

// MARK: - Item --> Event
struct Event: Codable {
    let kind: Kind
    let etag: Etag
    let id: String
    let status: Status
    let htmlLink: String
    let created: Created
    let updated: Updated
    let summary: ItemSummary
    let location: String?
    let creator: Creator
    let organizer: Organizer
    let start, end: End
    let recurringEventID: RecurringEventID
    let originalStartTime: End
    let transparency: String?
    let iCalUID: ICalUID
    let sequence: Int
    let eventType: EventType
    let description: String?
    let guestsCanInviteOthers: Bool?
    
    // Add this initializer
    init(id: String, summary: ItemSummary, location: String?, start: End, end: End) {
        self.kind = .calendarEvent  // You may need to set this appropriately based on your logic
        self.etag = Etag(rawValue: "")!  // You may need to set this appropriately based on your logic
        self.id = id
        self.status = .confirmed  // You may need to set this appropriately based on your logic
        self.htmlLink = ""  // You may need to set this appropriately based on your logic
        self.created = Created(rawValue: "")! // You may need to set this appropriately based on your logic
        self.updated = Updated(rawValue: "")! // You may need to set this appropriately based on your logic
        self.summary = summary
        self.location = location
        self.creator = Creator(email: .franciscoigorGmailCOM)  // You may need to set this appropriately based on your logic
        self.organizer = Organizer(email: "", displayName: .testCalendar, organizerSelf: false)  // You may need to set this appropriately based on your logic
        self.start = start
        self.end = end
        self.recurringEventID = .the5B553Slhq9Oa2E2Osr9Gtli2P8  // You may need to set this appropriately based on your logic
        self.originalStartTime = end
        self.transparency = ""  // You may need to set this appropriately based on your logic
        self.iCalUID = .the5B553Slhq9Oa2E2Osr9Gtli2P8GoogleCOM  // You may need to set this appropriately based on your logic
        self.sequence = 0  // You may need to set this appropriately based on your logic
        self.eventType = .eventTypeDefault  // You may need to set this appropriately based on your logic
        self.description = ""  // You may need to set this appropriately based on your logic
        self.guestsCanInviteOthers = false  // You may need to set this appropriately based on your logic
    }

    enum CodingKeys: String, CodingKey {
        case kind, etag, id, status, htmlLink, created, updated, summary, location, creator, organizer, start, end
        case recurringEventID = "recurringEventId"
        case originalStartTime, transparency, iCalUID, sequence, eventType, description, guestsCanInviteOthers
    }
}

enum Created: String, Codable {
    case the20221117T222806000Z = "2022-11-17T22:28:06.000Z"
    case the20221119T163429000Z = "2022-11-19T16:34:29.000Z"
}

// MARK: - Creator
struct Creator: Codable {
    let email: Email
}

enum Email: String, Codable {
    case franciscoigorGmailCOM = "franciscoigor@gmail.com"
}

// MARK: - End
struct End: Codable {
    let date: String?
    let dateTime: Date?
    let timeZone: String?
}

enum Etag: String, Codable {
    case the3337448471540000 = "\"3337448471540000\""
    case the3337751339210000 = "\"3337751339210000\""
}

enum EventType: String, Codable {
    case eventTypeDefault = "default"
}

enum ICalUID: String, Codable {
    case the5B553Slhq9Oa2E2Osr9Gtli2P8GoogleCOM = "5b553slhq9oa2e2osr9gtli2p8@google.com"
    case the7H14I1Bil94M0B63Qkvve0U4JmGoogleCOM = "7h14i1bil94m0b63qkvve0u4jm@google.com"
}

enum Kind: String, Codable {
    case calendarEvent = "calendar#event"
}

// MARK: - Organizer
struct Organizer: Codable {
    let email: String
    let displayName: DisplayNameEnum
    let organizerSelf: Bool

    enum CodingKeys: String, CodingKey {
        case email, displayName
        case organizerSelf = "self"
    }
}

enum DisplayNameEnum: String, Codable {
    case testCalendar = "TestCalendar"
}

enum RecurringEventID: String, Codable {
    case the5B553Slhq9Oa2E2Osr9Gtli2P8 = "5b553slhq9oa2e2osr9gtli2p8"
    case the7H14I1Bil94M0B63Qkvve0U4Jm = "7h14i1bil94m0b63qkvve0u4jm"
}

enum Status: String, Codable {
    case confirmed = "confirmed"
}

enum ItemSummary: String, Codable {
    case testEventWithTime = "Test Event with time"
    case weeklyEvent = "Weekly Event"
}

enum Updated: String, Codable {
    case the20221117T223035770Z = "2022-11-17T22:30:35.770Z"
    case the20221119T163429605Z = "2022-11-19T16:34:29.605Z"
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

class JSONCodingKey: CodingKey {
    let key: String

    required init?(intValue: Int) {
        return nil
    }

    required init?(stringValue: String) {
        key = stringValue
    }

    var intValue: Int? {
        return nil
    }

    var stringValue: String {
        return key
    }
}

class JSONAny: Codable {

    let value: Any

    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }

    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }

    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }

    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }

    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }

    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}
