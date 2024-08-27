//
//  ApiService.swift
//  KeKaTest
//
//  Created by bhawanisingh rao on 27/08/24.
//

import Foundation

// MARK: - APIService Protocol

protocol APIServiceProtocol {
    func fetchArticles(completion: @escaping (Result<[ArticleResponse], Error>) -> Void)
}

// MARK: - APIService Implementation

class APIService: APIServiceProtocol {
    private let apiKey = "j5GCulxBywG3lX211ZAPkAB8O381S5SM"
    private let query = "election"
    private let baseURL = "https://api.nytimes.com/svc/search/v2/articlesearch.json?"
    
    func fetchArticles(completion: @escaping (Result<[ArticleResponse], Error>) -> Void) {
        guard let url = URL(string: baseURL + "q=\(query)&api-key=\(apiKey)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "Data error", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(APIResponse.self, from: data)
                completion(.success(response.response.docs))
            } catch let decodingError {
                completion(.failure(decodingError))
            }
        }.resume()
    }
}

// MARK: - APIResponse Models

struct APIResponse: Codable {
    let response: DocsResponse
}

struct DocsResponse: Codable {
    let docs: [ArticleResponse]
}

struct ArticleResponse: Codable {
    let headline: Headline
    let abstract: String
    let pub_date: String
    let multimedia: [Multimedia]
    
    struct Headline: Codable {
        let main: String
    }
    
    struct Multimedia: Codable {
        let url: String
    }
}

