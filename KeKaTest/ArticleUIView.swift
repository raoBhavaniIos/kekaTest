//
//  ArticleUIView.swift
//  KeKaTest
//
//  Created by bhawanisingh rao on 28/08/24.
//

import SwiftUI

struct ArticleUIView: View {
    @ObservedObject var viewModel = ArticlesViewModel(apiService: APIService())
    
    var body: some View {
        if let errorMessage = viewModel.errorMessage {
            Text("Something Went Wrong: \(errorMessage)")
        } else {
            if viewModel.articles.isEmpty {
                Text("No data available \nPlease check your data connection and restart the app").multilineTextAlignment(.center)
            }else{
                NavigationView {
                    List {
                        ForEach(viewModel.articles,id: \.title)
                        { article in
                            HStack (alignment: .center, spacing: 10){
                                if let image = article.image{
                                    Image(uiImage: UIImage(data: image) ?? .actions)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipped()
                                        .cornerRadius(8)
                                }
                                VStack(alignment: .leading) {
                                    Text(article.title)
                                        .font(.headline)
                                    Text(article.abstract)
                                        .font(.subheadline)
                                    Text(article.publicationDate)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            
                        }.onDelete(perform: viewModel.DeleteTask)
                    }
                    .navigationTitle("NYT Articles")
                    .onAppear {
                        viewModel.fetchArticles()
        
                    }
                }
            }
        }
    }
}


#Preview {
    ArticleUIView()
}
