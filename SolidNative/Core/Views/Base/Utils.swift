//
//  Utils.swift
//  SolidNative
//
//  Created by LZY on 2024/5/4.
//

import Foundation
import SwiftUI

func anyToCGFloat(_ value: Any?) -> CGFloat? {
    if let v = value as? CGFloat {
        return v
    } else if let v = value as? String {
        if v == "infinity" {
            return .infinity
        }
    }
    return nil
}

func anyToAlignment(_ value: Any?) -> Alignment? {
    guard let s = value as? String else { return nil }
    if s == "center" { return .center }
    else if s == "leading" { return .leading }
    else if s == "trailing" { return .trailing }
    else if s == "top" { return .top }
    else if s == "bottom" { return .bottom }
    else if s == "topLeading" { return .topLeading }
    else if s == "topTrailing" { return .topTrailing }
    else if s == "bottomLeading" { return .bottomLeading }
    else if s == "bottomTrailing" { return .bottomTrailing }
    else if s == "centerFirstTextBaseline" { return .centerFirstTextBaseline }
    else if s == "centerLastTextBaseline" { return .centerLastTextBaseline }
    else if s == "leadingFirstTextBaseline" { return .leadingFirstTextBaseline }
    else if s == "leadingLastTextBaseline" { return .leadingLastTextBaseline }
    else if s == "trailingFirstTextBaseline" { return .trailingFirstTextBaseline }
    else if s == "trailingLastTextBaseline" { return .trailingLastTextBaseline }
    return nil
}

func anyToVerticalAlignment(_ value: Any?) -> VerticalAlignment? {
    guard let s = value as? String else { return nil }
    if s == "top" { return .top }
    else if s == "bottom" { return .bottom }
    else if s == "center" { return .center }
    else if s == "firstTextBaseline" { return .firstTextBaseline }
    else if s == "lastTextBaseline" { return .lastTextBaseline }
    return nil
}

func anyToHorizontalAlignment(_ value: Any?) -> HorizontalAlignment? {
    guard let s = value as? String else { return nil }
    if s == "leading" { return .leading }
    else if s == "center" { return .center }
    else if s == "trailing" { return .trailing }
    else if s == "listRowSeparatorLeading" { return .listRowSeparatorLeading }
    else if s == "listRowSeparatorTrailing" { return .listRowSeparatorTrailing }
    return nil
}
