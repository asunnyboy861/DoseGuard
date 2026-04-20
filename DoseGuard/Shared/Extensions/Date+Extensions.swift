import Foundation

extension Date {
    var formattedTime: String {
        formatted(date: .omitted, time: .shortened)
    }
    
    var formattedDate: String {
        formatted(date: .abbreviated, time: .omitted)
    }
    
    var formattedDateTime: String {
        formatted(date: .abbreviated, time: .shortened)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    func minutesAgo(_ minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: -minutes, to: self) ?? self
    }
    
    func hoursAgo(_ hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: -hours, to: self) ?? self
    }
    
    var relativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
