//
//  ContentView.swift
//  Ghid Ciordation
//
//  Created by Mugurel Moscaliuc on 13/06/2020.
//  Copyright © 2020 Mugurel Moscaliuc. All rights reserved.
//

import SwiftUI
import Combine
import xml_encoder

struct ContentView: View {
    
    @ObservedObject var viewModel = MainVM()
    @State private var text: String = ""
    
    
    @State private var cancellable: AnyCancellable?
    
    
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
                .font(.custom("HelveticaNeue-Light", size: 10))
                .padding(.all, 50)
            Spacer()
        }
        .onAppear {
            self.cancellable = self.viewModel.contentIsReady
                .sink {
                    self.text = "\(self.viewModel.ghidTv.count)"
                    self.encode()
            }
        }
    }
    
    
    func encode() {
        let encoder = JSONEncoder()
        do {
            let xmlFilename = self.viewModel.getDocumentsDirectory().appendingPathComponent("GhidTV.json")
            let xml = try encoder.encode(self.viewModel.ghidTv)
            print(xml)
            try xml.write(to: xmlFilename)
            //try xml.write(to: xmlFilename, atomically: true, encoding: String.Encoding.utf16)
        } catch {
            print("File write error: \(error)")
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
