//
//  NetworkService.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 11.02.2025.
//

import Foundation

final class NetworkService {
    private enum Constants {
        static let baseURL = "https://api.escuelajs.co/api/v1/"
    }
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func request<Model: Decodable>(with config: NetworkConfig) async throws -> Model {
        let (data, response) = try await makeRequest(config: config)
        try handleResponse(response)
        guard let model = try? decoder.decode(Model.self, from: data) else {
            throw NetworkError.decodingError
        }
        return model
    }
    
    private func makeRequest(config: NetworkConfig) async throws -> (Data, URLResponse) {
        let urlRequest = try buildRequest(with: config)
        return try await URLSession.shared.data(for: urlRequest)
    }
    
    private func buildRequest(with config: NetworkConfig) throws -> URLRequest {
        let urlString = Constants.baseURL + config.path + config.endPoint
        guard let url = URL(string: urlString) else { throw NetworkError.missingURL }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        
        switch config.task {
        case .requestBody(let data):
            request.httpBody = data
        case .requestUrlParameters(let parameters):
            try URLParameterEncoder().encode(urlRequest: &request, with: parameters)
        default:
            break
        }
        
        request.httpMethod = config.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    private func handleResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode)
        else {
            throw NetworkError.invalidResponse
        }
    }
}

//final class NetworkService {
//    private enum Constants {
//        static let baseURL = "https://api.escuelajs.co/api/v1/"
//    }
//    
//    private let encoder = JSONEncoder()
//    private let decoder = JSONDecoder()
//    
//    func request(with config: NetworkConfig,
//                 completion: @escaping (Result<Void, Error>) -> Void) {
//        makeRequest(config: config) { result in
//            switch result {
//            case .failure(let error):
//                completion(.failure(error))
//            case .success((_, let response)):
//                do {
//                    try self.handleResponse(response)
//                    completion(.success(()))
//                } catch {
//                    completion(.failure(error))
//                }
//            }
//        }
//    }
//    
//    /// Performs a request that decodes a model from the response.
//    func request<Model: Decodable>(with config: NetworkConfig,
//                                   completion: @escaping (Result<Model, Error>) -> Void) {
//        makeRequest(config: config) { result in
//            switch result {
//            case .failure(let error):
//                completion(.failure(error))
//            case .success((let data, let response)):
//                do {
//                    try self.handleResponse(response)
//                    let model = try self.decoder.decode(Model.self, from: data)
//                    completion(.success(model))
//                } catch {
//                    completion(.failure(error))
//                }
//            }
//        }
//    }
//    
//    /// Encodes an Encodable value into Data.
//    func encode<Value: Encodable>(_ value: Value) throws -> Data {
//        do {
//            return try encoder.encode(value)
//        } catch {
//            throw NetworkError.encodingError
//        }
//    }
//}
//
//private extension NetworkService {
//    func makeRequest(config: NetworkConfig,
//                     completion: @escaping (Result<(Data, URLResponse), Error>) -> Void) {
//        do {
//            let urlRequest = try buildRequest(with: config)
//            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
//                DispatchQueue.main.async {
//                    if let error = error {
//                        completion(.failure(error))
//                        return
//                    }
//                    guard let data = data, let response = response else {
//                        completion(.failure(NetworkError.invalidData))
//                        return
//                    }
//                    completion(.success((data, response)))
//                }
//            }
//            task.resume()
//        } catch {
//            completion(.failure(error))
//        }
//    }
//    
//    func buildRequest(with config: NetworkConfig) throws -> URLRequest {
//        let urlString = Constants.baseURL + config.path + config.endPoint
//        guard let url = URL(string: urlString) else { throw NetworkError.missingURL }
//
//        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
//        
//        switch config.task {
//        case .requestBody(let data):
//            request.httpBody = data
//        case .requestUrlParameters(let parameters):
//            try URLParameterEncoder().encode(urlRequest: &request, with: parameters)
//        default:
//            break
//        }
//        
//        request.httpMethod = config.method.rawValue
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        return request
//    }
//    
//    func handleResponse(_ response: URLResponse) throws {
//        guard let httpResponse = response as? HTTPURLResponse else { return }
//        guard (200...299).contains(httpResponse.statusCode) else {
//            throw NetworkError.invalidResponse
//        }
//    }
//}
