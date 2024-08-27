//
//  ArticleViewModel.swift
//  KeKaTest
//
//  Created by bhawanisingh rao on 27/08/24.
//

import Foundation
import UIKit

class ArticlesViewModel: ObservableObject {
    @Published var articles: [ArticleDisplay] = []
    @Published var errorMessage: String? = nil
    
    private let apiService: APIServiceProtocol
    private let coreDataManager = CoreDataManager.shared
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
        self.fetchArticles()
    }
    
    func fetchArticles() {
        if !Reachability.isConnectedToNetwork() {
            // Load from Core Data if no network
            let savedArticles = coreDataManager.fetchSavedArticles()
            self.articles = savedArticles.map { ArticleDisplay($0) }
            return
        }
        apiService.fetchArticles { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let articles):
                    self?.articles = articles.map { ArticleDisplay($0) }
                    articles.forEach { self?.coreDataManager.saveArticle($0) }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct ArticleDisplay {
    let title: String
    let abstract: String
    let publicationDate: String
    let image: Data?
    init <T>(_ article: T){
        if let identifier = article as? ArticleResponse {
            self.title = identifier.headline.main
            self.abstract = identifier.abstract
            self.publicationDate = DateFormatter.displayFormat.string(from: DateFormatter.yyyyMMdd.date(from: identifier.pub_date) ?? Date())
            if let imageUrlString = identifier.multimedia.first?.url,
               let imageUrl = URL(string: "https://www.nytimes.com/\(imageUrlString)"),
               let imageData = try? Data(contentsOf: imageUrl),
               let image = UIImage(data: imageData) {
                self.image = image.pngData() as Data?
            }else{
                self.image = nil
            }
        }else{
            self.title = (article as! Article).title ?? ""
            self.abstract = (article as! Article).abstractText ?? ""
            self.publicationDate = DateFormatter.displayFormat.string(from: (article as! Article).publicationDate ?? Date())
            self.image = (article as! Article).image
        }
    }
}
