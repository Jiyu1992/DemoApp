//
//  Constants.swift
//  DemoApp
//
//  Created by Lefteris Mantas on 16/2/22.
//

import Foundation

enum URLs {
    static let baseURL = "https://jsonplaceholder.typicode.com"
    static let posts = baseURL + "/posts" +  "/parameter"
    static let comments = baseURL + "/comments" + "/parameter"
    static let albums = baseURL + "/albums"
    static let photos = baseURL + "/photos"
    static let todos = baseURL + "/todos" +  "/parameter"
    static let users = baseURL + "/users"
}

enum UsefullKeys {
    static let app_json = "application/json; charset=utf-8"
    static let content_type = "Content-Type"
    static let accept = "Accept"
}
