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
import XMLCoder



struct Day: Codable {
    var name: String
    var channels: [Channel]
    
}

struct Channel: Codable {
    var name: String
    var content: Content
    var day: String
}

struct Content: Codable {
    var day: String
    var channel: String
    var body: String
}



class MainVM: ObservableObject {
    
    
    var contentIsReady = PassthroughSubject<Void, Never>()
    var status = CurrentValueSubject<String, Never>("")
    
    var cancellables = Set<AnyCancellable>()
    
    var hours = [String]()
    var contentList = [String]()
    var combined = [String]()
    var days = ["vineri", "sambata", "duminica", "luni", "marti", "miercuri", "joi"]
    var programe = ["tvr-1", "pro-tv-hd", "antena-1-hd", "pro-2", "b1-tv", "tvr-2", "prima-tv", "hbo", "happy-channel", "pro-cinema", "axn", "diva", "kanal-d", "digi-sport-1", "national-tv"]
    
    var ghidTv = [Day]() {
        didSet {
            if ghidTv.count == 7 {
                contentIsReady.send()
                status.send("Done! 😜")
            }
        }
    }
    
    var channels = [Channel]() {
        didSet {
            if channels.count == 15 {
                createDays(channels: channels)
            }
        }
    }
    
    var rawContent = [Content]() {
        didSet {
            if rawContent.count == 105 {
                for day in days {
                    for program in programe {
                        createChannels(day: day, channel: program)
                    }
                }
            }
        }
    }
    
    
    func createDays(channels: [Channel]) {
        self.channels.removeAll()
        let day = Day(name: channels.first!.day, channels: channels)
            self.ghidTv.append(day)
    }
    
    
    func createChannels(day: String, channel: String) {
        let firstSorted = rawContent.filter { $0.day == day }
        let secondSorted = firstSorted.filter { $0.channel == channel }
        let channel = Channel(name: channel, content: secondSorted.first!, day: day)
        self.channels.append(channel)
    }
    
    
    func getAll(day: String) {
        for program in programe {
            getChannel(day: day, program: program)
        }
    }
    
    
    func getChannel(day: String, program: String) {
        //print("Se descarca \(day)...")
        combined.removeAll()
        //contentIsReady.send("")
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
                    self.combined.removeAll()
                    let zipped = zip(self.hours, self.contentList)
                    for (hour, content) in zipped {
                        let line = hour + " " + content
                        self.combined.append(line)
                    }
                    let content = Content(day: day, channel: program, body: self.combined.joined(separator: "\n"))
                    self.rawContent.append(content)
                    self.status.send(content.day + " - " + content.channel)
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
