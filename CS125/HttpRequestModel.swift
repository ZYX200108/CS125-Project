//
//  HttpRequestModel.swift
//  CS125
//
//  Created by zhe yuan on 3/9/24.
//

import Foundation

class httpRequestModel: ObservableObject {
    // Use a published property to update the UI in response to changes
    private var responseString: String = ""
    private var userName: String = ""
    
    init(name: String) {
        self.userName = name;
    }

    func initializeUser(completion: @escaping (String) -> Void) {
        let urlString = "https://us-central1-cs125-healthapp.cloudfunctions.net/initializeUserModels?userName=\(self.userName)"
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    completion(responseString)
                }
            } else if let error = error {
                print("HTTP Request Failed \(error)")
                DispatchQueue.main.async {
                    completion("Error: \(error.localizedDescription)")
                }
            }
        }

        task.resume()
    }
}
