//
//  SwiftUIPopover.swift
//  Proof
//
//  Created by Михайло Грошевий on 28/11/2025.
//

import AppKit
import SwiftUI

class SwiftUIPopover {
    
    private static var retainedPopover: NSPopover?
    private static weak var buttonForRepositioning: NSStatusBarButton?
    
    static func open(view: some View, button: NSStatusBarButton, recreate: Bool) {
        buttonForRepositioning = button
        
        if let popover = retainedPopover {
            if (popover.isShown) {
                return
            }
            
            if (!recreate) {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
                return
            }
        }
        
        let popover = NSPopover()
        
        popover.behavior = .transient
        
        let wrappedView = view.frame(width: 400)
        let controller = NSHostingController(rootView: wrappedView)
        controller.sizingOptions = .preferredContentSize
        popover.contentViewController = controller
        
        retainedPopover = popover
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
    }
    
    static func reposition() {
        guard let popover = retainedPopover, popover.isShown, let button = buttonForRepositioning else {
            return
        }
        
        popover.close()
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
    }
}
