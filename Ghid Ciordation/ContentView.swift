//
//  ContentView.swift
//  Ghid Ciordation
//
//  Created by Mugurel Moscaliuc on 13/06/2020.
//  Copyright © 2020 Mugurel Moscaliuc. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @ObservedObject var viewModel = MainVM()
    @State private var text: String = ""
    
    
    @State private var cancellable: AnyCancellable?
    
    
    var body: some View {
        VStack {
            Spacer().frame(height: 50)
            Button(action: {
                    self.viewModel.getAll()
                
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
                .sink { text in
                    self.text = text
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
