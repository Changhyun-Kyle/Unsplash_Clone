//
//  NetworkService.swift
//  Unsplash_Clone
//
//  Created by 강창현 on 6/27/24.
//

import Foundation

enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case patch  = "PATCH"
    case delete = "DELETE"
}

enum APIType {
    case unsplash
    
    var urlScheme: URLScheme {
        switch self {
        case .unsplash:
            return .https
        }
    }
    
    var header: [String:String] {
        switch self {
        case .unsplash:
            return [
                "Authorization":"",
                "Accept-Version":"v1",
            ]
        }
    }
    
    var host: String {
        switch self {
        case .unsplash:
            "api.unsplash.com"
        }
    }
    
    var body: Encodable? {
        switch self {
        case .unsplash:
            <#code#>
        }
    }
    
    var queries: [String:String] {
        switch self {
        case .unsplash:
            [
                "":"",
            ]
        }
    }
}

enum PathType {
    case randomPhotos
    
    var path: String {
        switch self {
        case .randomPhotos:
            return "/photos"
        }
    }
}

enum URLScheme: String {
    case http = "http"
    case https = "https"
    case ws = "ws"
    
    var type: String {
        return self.rawValue
    }
}

protocol Requestable {
    func makeRequest(
        _ apiType: APIType,
        _ pathType: PathType,
        _ httpMethod: HTTPMethod
    ) throws -> URLRequest
    
    func makeURL(
        _ apiType: APIType,
        _ pathType: PathType,
        _ httpMethod: HTTPMethod
    ) -> URL?
}

struct URLRequestBuilder: Requestable {
    func makeURL(
        _ apiType: APIType,
        _ pathType: PathType,
        _ httpMethod: HTTPMethod
    ) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = apiType.urlScheme.type
        urlComponents.host = apiType.host
        urlComponents.path = pathType.path
        urlComponents.queryItems = apiType.queries.map { URLQueryItem(name: $0, value: $1) }
        return urlComponents.url
    }
    
    func makeRequest(
        _ apiType: APIType,
        _ pathType: PathType,
        _ httpMethod: HTTPMethod
    ) throws -> URLRequest {
        guard
            let url = makeURL(apiType, pathType, httpMethod)
        else {
            throw NetworkError.invaildURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = apiType.header
        
        guard 
            let body = apiType.body
        else {
            return urlRequest
        }
        
        urlRequest.httpBody = try JSONHandler.encoder.encode(body)
        
        return urlRequest
    }
}

enum JSONHandler {
    static let decoder = JSONDecoder()
    static let encoder = JSONEncoder()
}

enum NetworkError: Error {
    case invaildURL
}
