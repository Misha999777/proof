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
    private static var popoverDelegate: PopoverDelegate?
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
        
        popoverDelegate = PopoverDelegate()
        popover.delegate = popoverDelegate
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
    
    static var isOpened: Bool {
        return retainedPopover != nil && retainedPopover!.isShown
    }
    
    static func close() {
        retainedPopover?.close()
    }
}

private class PopoverDelegate: NSObject, NSPopoverDelegate {
    
    private weak var observedWindow: NSWindow?
    
    func popoverWillShow(_ notification: Notification) {
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func popoverDidShow(_ notification: Notification) {
        guard let popover = notification.object as? NSPopover,
              let window = popover.contentViewController?.view.window else {
            return
        }
        
        self.observedWindow = window
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidResignKey(_:)),
            name: NSWindow.didResignKeyNotification,
            object: window
        )
    }
    
    func popoverDidClose(_ notification: Notification) {
        if let window = observedWindow {
            NotificationCenter.default.removeObserver(
                self,
                name: NSWindow.didResignKeyNotification,
                object: window
            )
        }
        
        observedWindow = nil
    }
    
    @objc private func windowDidResignKey(_ notification: Notification) {
        SwiftUIPopover.close()
    }
}
