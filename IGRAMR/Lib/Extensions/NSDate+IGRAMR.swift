//
//  NSDate+IGRAMR.swift
//  IGRAMR
//
//  Created by GrepRuby3 on 08/09/15.
//  Copyright (c) 2015 GrepRuby3. All rights reserved.
//

import Foundation

extension NSDate {
    
    public func getComponent (component : NSCalendarUnit) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(component, fromDate: self)
        return components.valueForComponent(component)
    }
    
    public func currentYear() -> Int {
        return getComponent(.Year)
    }
    
    public func currentMonth() -> Int {
        return getComponent(.Month)
    }
    
    public func currentWeekday() -> Int {
        return getComponent(.Weekday)
    }
    
    public func currentWeekMonth() -> Int {
        return getComponent(.WeekOfMonth)
    }
    
}
