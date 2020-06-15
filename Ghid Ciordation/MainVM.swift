//
//  MainVM.swift
//  Ghid Ciordation
//
//  Created by Mugurel Moscaliuc on 13/06/2020.
//  Copyright © 2020 Mugurel Moscaliuc. All rights reserved.
//

import SwiftUI
import Combine
import SwiftSoup



class MainVM: ObservableObject {
    
    
    var contentIsReady = CurrentValueSubject<String, Never>("")
    
    var cancellables = Set<AnyCancellable>()
    
    var hours = [String]()
    var contentList = [String]()
    var combined = [String]()
    var days = ["luni", "marti", "miercuri", "joi", "vineri"]
    var programe = ["antena-1-hd", "pro-tv-hd", "hbo-hd"]
    
    
    func getAll() {
        for day in days {
            for program in programe {
                getTv(day: day, program: program)
            }
        }
    }
    
    
    func getTv(day: String, program: String) {
        print("Se descarca \(day)...")
        combined.removeAll()
        contentIsReady.send("")
        guard let url = URL(string: "https://m.cinemagia.ro/program-tv/\(program)/" + day) else { return }
        URLSession.shared.dataTaskPublisher(for: url)
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Autocomplete request error: \(error.localizedDescription)")
                }
            }, receiveValue: { result in
                let html = String(decoding: result.data, as: UTF8.self)
                do {
                    let doc: Document = try SwiftSoup.parse(html)
                    let hours: Elements = try doc.select("span.time")
                    self.hours.removeAll()
                    for hour in hours {
                        let hour = try hour.text()
                        self.hours.append(hour)
                    }
                    let contentList: Elements = try doc.select("span.content")
                    self.contentList.removeAll()
                    for content in contentList {
                        let content = try content.text()
                        self.contentList.append(content)
                    }
                    let zipped = zip(self.hours, self.contentList)
                    self.combined.append("_____\(program)_____")
                    self.combined.append("_____\(day)_____")
                    for (hour, content) in zipped {
                        let line = hour + " " + content
                        self.combined.append(line)
                    }
                    self.contentIsReady.send(self.combined.joined(separator: "\n"))
                    do {
                        let filename = self.getDocumentsDirectory().appendingPathComponent("\(day).txt")
                        try self.combined.joined(separator: "\n").write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                        print("\(day) done!")
                    } catch {
                        print("File write error: \(error)")
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
                
            }).store(in: &cancellables)
        
    }
    
    
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    
    
}
