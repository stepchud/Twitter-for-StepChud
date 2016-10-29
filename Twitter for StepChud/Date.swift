//
//  Date.swift
//  Twitter for StepChud
//
//  Created by Stephen Chudleigh on 10/28/16.
//  Copyright © 2016 Stephen Chudleigh. All rights reserved.
//

import Foundation

extension Date {
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    var relativeTime: String {
        let now = Date()
        let daysAgo = now.days(from: self)
        if daysAgo == 1 {
            return "Yesterday"
        } else if daysAgo > 1 && daysAgo <= 7 {
            return now.days(from: self).description + " days ago"
        } else if daysAgo > 7 {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: self)
        }
        if now.hours(from: self)   > 0 {
            return "\(now.hours(from: self))h"
        }
        if now.minutes(from: self) > 0 {
            return "\(now.minutes(from: self))m"
        }
        if now.seconds(from: self) > 0 {
            if now.seconds(from: self) < 15 { return "Just now"  }
            return "\(now.seconds(from: self)) second" + { return now.seconds(from: self) > 1 ? "s" : "" }() + " ago"
        }
        return ""
    }
}
