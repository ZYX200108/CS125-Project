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
    
    init() {}

    func initializeUser(userName: String, viewModel: MainViewModel, completion: @escaping (String) -> Void) {
        let urlString = "https://us-central1-cs125-healthapp.cloudfunctions.net/initializeUserModels?userName=\(userName)"
        guard let url = URL(string: urlString) else { return }
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 3600
        configuration.timeoutIntervalForResource = 3600
        
        let session = URLSession(configuration: configuration)

        let task = session.dataTask(with: url) { data, response, error in
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                completion(responseString)
                print("donnnnnnnnnne")
                DispatchQueue.main.async {
                    viewModel.recommendationReady = true
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
    
    func getRecipes(userName: String,  viewModel: MainViewModel, completion: @escaping (String) -> Void) {
        var urlString = "https://us-central1-cs125-healthapp.cloudfunctions.net/getReceipts?userName=\(userName)&ingredients="
        let ingredients = ["chicken", "onion", "garlic", "tomato", "rice"]
        
        for i in 0...ingredients.count - 1 {
            urlString += ingredients[i] + ","
        }
        urlString += ingredients[-1]
        
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    completion(responseString)
                    viewModel.recommendationReady = true
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
    
    func updateDailyNutritions(userName: String, completion: @escaping (String) -> Void) {
        let urlString = "https://us-central1-cs125-healthapp.cloudfunctions.net/updateDailyNutritions?userName=\(userName)"
        
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
    
    func updatePreferenceVector(userName: String, which: Int, completion: @escaping (String) -> Void) {
        let urlString = "https://us-central1-cs125-healthapp.cloudfunctions.net/updatePreferenceVector?userName=\(userName)&which=\(which)"
        
        guard let url = URL(string: urlString) else { return }
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 3600
        configuration.timeoutIntervalForResource = 3600
        
        let session = URLSession(configuration: configuration)

        let task = session.dataTask(with: url) { data, response, error in
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
    
    func afterConfirmRecipe(userName: String, which: Int, completion: @escaping (String) -> Void) {
        self.updatePreferenceVector(userName: userName, which: which) {response in}
    }
}
