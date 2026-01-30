//
//  MacEditor.swift
//  Proof
//
//  Created by Михайло Грошевий on 29/01/2026.
//

import SwiftUI

// This exists because there is no way to implemnt good read-only TextEditor in SwiftUI
// (TextEditor with .constant binding and Text are not exactly what is needed)
struct MacEditor: NSViewRepresentable {
    
    @Binding var text: String
    var isEditable: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.autohidesScrollers = true
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        
        let textView = CustomTextView()
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
        if textView.string != text {
            textView.string = text
        }
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MacEditor

        init(_ parent: MacEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            self.parent.text = textView.string
        }
    }
}

// Sometimes text is not deselected on click
// macOS bug?
class CustomTextView: NSTextView {

    override func mouseDown(with event: NSEvent) {
        let point = self.convert(event.locationInWindow, from: nil)
        let index = self.characterIndexForInsertion(at: point)
        
        let isClickingOnSelection = self.selectedRange().contains(index)
        let selectionLength = self.selectedRange().length
        
        super.mouseDown(with: event)
        
        if isClickingOnSelection && selectionLength > 0 {
            self.setSelectedRange(NSRange(location: index, length: 0))
        }
    }
}
