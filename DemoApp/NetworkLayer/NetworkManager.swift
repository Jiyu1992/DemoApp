//
//  NetworkManager.swift
//  DemoApp
//
//  Created by Lefteris Mantas on 16/2/22.
//

import Foundation
import UIKit
import CoreData

protocol NetworkManagerProtocol {
    
    func fetchData(parameter: String, httpMethod: TypeOfREST,typeOfCall: TypeOfCall,completion: @escaping ([GenericResponseWrapper]?, Error?)->Void)
    
    func fetchUsers(parameter: String, httpMethod: TypeOfREST,completion: @escaping ([User]?, Error?)->Void)
    
    func fetchTodos(parameter: String, httpMethod: TypeOfREST,completion: @escaping ([Todo]?, Error?)->Void)
    
    func fetchComments(parameter: String, httpMethod: TypeOfREST,completion: @escaping ([Comment]?, Error?)->Void)
    
    func fetchPosts(parameter: String, httpMethod: TypeOfREST,completion: @escaping ([Post]?, Error?)->Void)
}


enum TypeOfCall{
    case posts
    case comments
    case users
    case todos
}

enum Result<String>{
       case success
       case failure(String)
}

// optional
enum NetworkResponse: String{
    case success = "We did it"
    case authenticationError = "You need to be authorized"
    case badRequest = "Bad Request"
    case outdated = "The url is outdated"
    case failed = "Network request failed"
    case noData = "Data empty"
    case unableToDecode = "Unable to decode the response"
}

enum TypeOfREST: String{
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case update = "UPDATE"
}

fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
    switch response.statusCode {
    case 200...299: return .success
    case 400...500: return .failure(NetworkResponse.authenticationError.rawValue + " \(response.statusCode)")
    case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
    case 600: return .failure(NetworkResponse.outdated.rawValue)
    default: return .failure(NetworkResponse.failed.rawValue)
        
    }
    
}

class NetworkManager: NetworkManagerProtocol {
//    let shared = NetworkManager()
    
    func makeApiCall<T: Codable>(with url: URL ,httpMethod: TypeOfREST,completionHandler: @escaping (_ jsonResponse: T?, _ error: Error?) -> ()) {
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.addValue(UsefullKeys.app_json, forHTTPHeaderField: UsefullKeys.content_type)
        request.addValue(UsefullKeys.app_json, forHTTPHeaderField: UsefullKeys.accept)

        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) {(data, response, error) -> Void in
            if let response = response as? HTTPURLResponse {
                let result = handleNetworkResponse(response)
                switch result {
                case .success:
                    do {
                        let decoder = JSONDecoder()
                        decoder.userInfo[CodingUserInfoKey.managedObjectContext] = CoreDataManager.sharedInstance.managedContext
                        if let json = try decoder.decode(T?.self, from: data!) {
                            completionHandler(json, nil)
                        } else {
                            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
                            print("\nJSON Response: \(dataString)\n")
                            completionHandler(nil, error)
                        }
                        
                    } catch(let decodingError) {
                        print(decodingError)
                        print("\nERROR - INVALID JSON RESPONSE")
                        let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
                        print("\nJSON Response: \(dataString)\n")
                        completionHandler(nil, decodingError)
                    }
                case .failure(let apiCallError):
                    print("\nERROR - RESPONSE \(apiCallError)")
                    completionHandler(nil, error)
                    
                }
            }
            else {
                print(error.debugDescription)
                completionHandler(nil, error)
            }
            session.finishTasksAndInvalidate()
        }
        task.resume()
    }
    
    func fetchUsers(parameter: String, httpMethod: TypeOfREST ,completion: @escaping ([User]?, Error?) ->Void) -> () {
        var url: URL!
        url = URL(string: URLs.users.replacingOccurrences(of: "parameter", with: parameter).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
//      guarantee the validity of the url
        guard let validUrl = url else
        { return }
//      call the generic makeApiCall
        return self.makeApiCall(with: validUrl, httpMethod: httpMethod, completionHandler: completion)
    }
    
    func fetchTodos(parameter: String, httpMethod: TypeOfREST ,completion: @escaping ([Todo]?, Error?) ->Void) -> () {
        var url: URL!
        url = URL(string: URLs.todos.replacingOccurrences(of: "parameter", with: parameter).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
//      guarantee the validity of the url
        guard let validUrl = url else
        { return }
//      call the generic makeApiCall
        return self.makeApiCall(with: validUrl, httpMethod: httpMethod, completionHandler: completion)
    }
    
    func fetchComments(parameter: String, httpMethod: TypeOfREST ,completion: @escaping ([Comment]?, Error?) ->Void) -> () {
        var url: URL!
        url = URL(string: URLs.comments.replacingOccurrences(of: "parameter", with: parameter).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
//      guarantee the validity of the url
        guard let validUrl = url else
        { return }
//      call the generic makeApiCall
        return self.makeApiCall(with: validUrl, httpMethod: httpMethod, completionHandler: completion)
    }
    
    func fetchPosts(parameter: String, httpMethod: TypeOfREST ,completion: @escaping ([Post]?, Error?) ->Void) -> () {
        var url: URL!
        url = URL(string: URLs.posts.replacingOccurrences(of: "parameter", with: parameter).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
//      guarantee the validity of the url
        guard let validUrl = url else
        { return }
//      call the generic makeApiCall
        return self.makeApiCall(with: validUrl, httpMethod: httpMethod, completionHandler: completion)
    }
    
//  MARK: attempt to generalize the "helper" func of makeApiCall, needs more R
    func fetchData(parameter: String, httpMethod: TypeOfREST ,typeOfCall: TypeOfCall,completion: @escaping ([GenericResponseWrapper]?, Error?) ->Void) -> () {
        var url: URL!
//      differentiate between the various api calls we need to make
        switch typeOfCall {
        case .comments:
            url = URL(string: URLs.comments.replacingOccurrences(of: "parameter", with: parameter).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        case .posts:
            url = URL(string: URLs.posts.replacingOccurrences(of: "parameter", with: parameter).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        case .todos:
            url = URL(string: URLs.todos.replacingOccurrences(of: "parameter", with: parameter).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        case .users:
            url = URL(string: URLs.users.replacingOccurrences(of: "parameter", with: parameter).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            
        }
//      guarantee the validity of the url
        guard let validUrl = url else
        { return }
//      call the generic makeApiCall
        return self.makeApiCall(with: validUrl, httpMethod: httpMethod, completionHandler: completion)
    }
}
// MARK: attempt to generalize, needs more research
struct GenericResponseWrapper: Codable {
    
    
    var users: [User]?
    var todos: [Todo]?
    var posts: [Post]?
    var comments: [Comment]?
    
}
