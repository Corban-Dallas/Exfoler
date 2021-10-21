//
//  TableView.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 20.10.2021.
//

import SwiftUI

struct TableView: NSViewRepresentable {

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let sv = NSScrollView()
        
        let table = NSTableView()
        table.delegate = context.coordinator
        table.dataSource = context.coordinator
        
        let column = NSTableColumn()
        column.title = "Name"
        column.identifier = .init(rawValue: "Name ind")
        let column2 = NSTableColumn()
        column2.title = "ticker"
        column2.identifier = .init(rawValue: "ticker ind")
        
        table.addTableColumn(column)
        table.addTableColumn(column2)
    
        sv.documentView = table
        return sv
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        //
    }
    
    class Coordinator: NSObject, NSTableViewDelegate, NSTableViewDataSource {
        var nameArray: [String] = ["one", "two", "three", "four", "five"]
        
        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            let text = NSTextView()
            text.backgroundColor = .clear
            text.string = "Label"
            return text
        }
        func numberOfRows(in tableView: NSTableView) -> Int {
            nameArray.count
        }
        
        

    }
    
    typealias NSViewType = NSScrollView
    
    
}

struct TableView_Previews: PreviewProvider {
    static var previews: some View {
        TableView()
            .frame(width: CGFloat(400))
    }
}
