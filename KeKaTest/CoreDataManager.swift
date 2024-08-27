//
//  CoreDataManager.swift
//  KeKaTest
//
//  Created by bhawanisingh rao on 27/08/24.
//

import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    private let container: NSPersistentContainer
    
    private init() {
        container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }
    
    func saveArticle(_ article: ArticleResponse) {
        let context = container.viewContext
        let articleEntity = Article(context: context)
        articleEntity.title = article.headline.main
        articleEntity.abstractText = article.abstract
        articleEntity.publicationDate = DateFormatter.yyyyMMdd.date(from: article.pub_date)
        
        if let imageUrlString = article.multimedia.first?.url,
           let imageUrl = URL(string: "https://www.nytimes.com/\(imageUrlString)"),
           let imageData = try? Data(contentsOf: imageUrl),
           let image = UIImage(data: imageData) {
            articleEntity.image = image.pngData() as Data?
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save article: \(error)")
        }
    }
    
    func fetchSavedArticles() -> [Article] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
        
        do {
            var articles = try context.fetch(fetchRequest)
            articles.sort { $0.publicationDate! > $1.publicationDate!
            }
            return articles
        } catch {
            print("Failed to fetch articles: \(error)")
            return []
        }
    }
}

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    static let displayFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
}

