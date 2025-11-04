//
//  SolidNativeView.swift
//  SolidNative
//
//  Created by LZY on 2024/5/3.
//

import Foundation
import JavaScriptCore
import SwiftUI

class SolidNativeView {
    weak var next: SolidNativeView?
    weak var prev: SolidNativeView?
    let id = UUID()
    
    class var name: String {
        "sn_view"
    }
    
    required init() {
    }
    
    func getName() -> String {
        return Self.name
    }
    
    deinit {
//        if ["sn_tabview", "sn_navigationstack"].contains(Self.name) {
            print("\(id) \(Self.name) deinit")
//        }
    }
    
    
    let props: SolidNativeProps = SolidNativeProps()
    
    @objc public func setProp(_ name: String, _ value: JSValue?) {
        // print("JS value type: " + String(value!.isString))
        assert(name != "children", "Err: User `removeChild` or `insertBefore` to update children!")
//        props.values[name] = value
        if self.props.values.updateValue(value, forKey: name) == nil {
            self.props.keys.append(name)
        }
    }
    
    
    var children: [SolidNativeView] = []
    var indirectChildren: [SolidNativeView] = []
    
    // Can be getter
    weak var firstChild: SolidNativeView?
    
    weak var parentElement: SolidNativeView?
    
    // Iterate over first child prop
    // O(n)
    private func updateChildrenInProps() {
        var newChildren: [SolidNativeView] = []
        
        var nextChild = firstChild
        while let child = nextChild {
            newChildren.append(child)
            nextChild = child.next
        }
        
        children = newChildren
        DispatchQueue.main.async {
            self.props.children = newChildren
        }
    }
    
    // O(1)
    func removeChild(_ element: SolidNativeView) {
        // Link the nodes prev and next of it
        if let childNextSibling = element.next,
           let childPrevSibling = element.prev {
            childPrevSibling.next = childNextSibling
            childNextSibling.prev = childPrevSibling
            // Is first element
        } else if let childNextSibling = element.next {
            childNextSibling.prev = nil
            firstChild = childNextSibling
        } else if let childPrevSibling = element.prev {
            childPrevSibling.next = nil
        } else {
            firstChild = nil
        }
        element.parentElement = nil
        element.next = nil
        element.prev = nil
        // Update the nodes first child
        // Remove as parent
        updateChildrenInProps()
    }
    
    // O(1)
    func insertBefore(_ element: SolidNativeView, _ anchor: SolidNativeView?) {
        // If no anchor set first child to view (make head)
        //
        if let anchor = anchor {
            
            if anchor === firstChild {
                anchor.prev = element
                element.next = anchor
                firstChild = element
            } else if let anchorPrevSibling = anchor.prev {
                anchorPrevSibling.next = element
                element.prev = anchorPrevSibling
                anchor.prev = element
                element.next = anchor
            }
            
        } else if let firstChild = firstChild {
            // Make it at the end of the list
            var nextChild: SolidNativeView? = firstChild
            while let child = nextChild {
                nextChild = child.next
                
                if nextChild == nil {
                    let lastChild = child
                    lastChild.next = element;
                    element.prev = lastChild
                }
            }
            
        } else {
            firstChild = element
        }
        
        element.parentElement = self
        
        updateChildrenInProps()
    }
    
    // TODO: You need to override this!
    // This is how SolidJS will deliver a text prop.
    dynamic var isTextElement: Bool {
        false
    }
    
    
    func render() -> AnyView {
        AnyView(EmptyView())
    }
}
