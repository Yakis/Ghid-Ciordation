//
//  ContentView.swift
//  Ghid Ciordation
//
//  Created by Mugurel Moscaliuc on 13/06/2020.
//  Copyright © 2020 Mugurel Moscaliuc. All rights reserved.
//

import SwiftUI
import Combine
import XMLCoder

struct ContentView: View {
    
    @ObservedObject var viewModel = MainVM()
    @State private var text: String = ""
    
    
    @State private var cancellable: AnyCancellable?
    @State private var statusCancellable: AnyCancellable?
    
    var body: some View {
        VStack {
            Spacer().frame(height: 50)
            Button(action: {
                self.getTVProgram()
            }) {
                Text("Apasa")
            }
            
            Text(text)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .font(.custom("HelveticaNeue-Light", size: 20))
                .padding(.all, 50)
            Spacer()
        }
        .onAppear {
            self.statusCancellable = self.viewModel.status
                .sink { status in
                    self.text = status
            }
            self.cancellable = self.viewModel.contentIsReady
                .sink {
                    self.encodeToJSON()
            }
        }
    }
    
    
    func encodeToJSON() {
        let encoder = JSONEncoder()
        do {
            let jsonFilename = self.viewModel.getDocumentsDirectory().appendingPathComponent("GhidTV.json")
            let json = try encoder.encode(self.viewModel.ghidTv)
            try json.write(to: jsonFilename)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
               self.$text.wrappedValue = "Done! 😜"
            }
        } catch {
            print("File write error: \(error)")
        }
    }
    
    
    func encodeToXML() {
        let encoder = XMLEncoder()
        do {
            let xmlFilename = self.viewModel.getDocumentsDirectory().appendingPathComponent("GhidTV.xml")
            let xml = try encoder.encode(self.viewModel.ghidTv)
            try xml.write(to: xmlFilename)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
               self.$text.wrappedValue = "Done! 😜"
            }
        } catch {
            print("Error encoding XML: \(error)")
        }
    }
    
    
    
    func getTVProgram() {
        for day in self.viewModel.days {
            self.viewModel.getAll(day: day)
        }
    }
    
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
