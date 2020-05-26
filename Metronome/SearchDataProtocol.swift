//
//  SearchDataProtocol.swift
//  Metronome
//
//  Created by Ian Chang on 11/17/19.
//  Copyright © 2019 Ian Chang. All rights reserved.
//

import Foundation

enum DataError:Error {
    case noDataAvailable
    case canNotProcessData
}

struct SearchRequest {
    let resourceURL:URL
    let key = "de2fe2768119a57954032aa1218e050e"
    
    init(search:String) {
        let resourceString = "https://api.getsongbpm.com/search/?api_key=\(key)&type=both&lookup=\(search)"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        
        self.resourceURL = resourceURL
    }
    
    func getData (completion: @escaping(Result<[SearchData], DataError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: resourceURL) {data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.noDataAvailable))
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "error"), object: nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                let searchResponse = try decoder.decode(SearchResponse.self, from: jsonData)
                let searchData = searchResponse.search
                completion(.success(searchData))
            } catch{
                completion(.failure(.canNotProcessData))
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "error"), object: nil)
            }
        }
        dataTask.resume()
    }
}
