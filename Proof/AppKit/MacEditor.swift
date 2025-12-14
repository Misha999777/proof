//
//  MacEditor.swift
//  Proof
//
//  Created by Михайло Грошевий on 29/01/2026.
//

import SwiftUI

struct MacEditor: NSViewRepresentable {
    
    @Binding var content: String
    var isEditable: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.autohidesScrollers = true
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        
        let textView = NSTextView()
        textView.autoresizingMask = [.width]
        textView.delegate = context.coordinator
        
        textView.isEditable = isEditable
        textView.isSelectable = true
        textView.isRichText = false
        textView.allowsUndo = true
        
        textView.font = .systemFont(ofSize: 14)
        textView.textContainerInset = NSSize(width: 4, height: 4)
        
        scrollView.documentView = textView
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        context.coordinator.parent = self
        
        guard let textView = nsView.documentView as? NSTextView else { return }
        if textView.string != content {
            textView.string = content
        }
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MacEditor

        init(_ parent: MacEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            self.parent.content = textView.string
        }
    }
}
