//
//  SearchBar.swift
//  Exfoler
//
//  Created by Григорий Кривякин on 19.10.2021.
//

import SwiftUI

struct SearchField: NSViewRepresentable {
    @Binding var text: String
    var onEditingChanged: ((Bool) -> Void)?
    var onCommit: (() -> Void)?
    
    
    init(text: Binding<String>) {
        _text = text
    }
    
    init(text: Binding<String>,
         onEditingChanged: @escaping (Bool) -> Void,
         onCommit: @escaping () -> Void) {
        self.init(text: text)
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onEditingChanged: onEditingChanged, onCommit: onCommit)
    }
    
    func makeNSView(context: Context) -> NSSearchField {
        let searchField = NSSearchField()
        searchField.delegate = context.coordinator
        return searchField
    }
    
    class Coordinator: NSObject, NSSearchFieldDelegate {
        @Binding var text: String
        let onEditingChanged: ((Bool) -> Void)?
        let onCommit: (() -> Void)?
        
        init(text:Binding<String>,
             onEditingChanged: ((Bool) -> Void)?,
             onCommit: (() -> Void)?) {
            _text = text
            self.onEditingChanged = onEditingChanged
            self.onCommit = onCommit
        }
        
        func controlTextDidChange(_ obj: Notification) {
            text = (obj.object as! NSSearchField).stringValue
        }
        
        func controlTextDidEndEditing(_ obj: Notification) {
            // Commit then ENTER is pressed
            if obj.userInfo?["NSTextMovement"] as! Int == NSReturnTextMovement {
                guard let onCommit = onCommit else {
                    return
                }
                onCommit()
            }
        }
    }
    
    func updateNSView(_ nsView: NSSearchField, context: Context) {
        nsView.stringValue = text
    }
    
    typealias NSViewType = NSSearchField
    
}

struct SearchFieldView_Previews: PreviewProvider {
    static var previews: some View {
        SearchField(text: Binding.constant("Aria"))
            .frame(width: CGFloat(200))
    }
}
