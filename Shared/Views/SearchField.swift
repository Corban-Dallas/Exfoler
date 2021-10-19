//
//  SearchBar.swift
//  Exfoler
//
//  Created by Григорий Кривякин on 19.10.2021.
//

import SwiftUI

struct SearchField: NSViewRepresentable {
    @Binding var text: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    func makeNSView(context: Context) -> NSSearchField {
        let searchField = NSSearchField()
        searchField.delegate = context.coordinator
        return searchField
    }
    
    class Coordinator: NSObject, NSSearchFieldDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func controlTextDidChange(_ obj: Notification) {
            text = (obj.object as! NSSearchField).stringValue
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
