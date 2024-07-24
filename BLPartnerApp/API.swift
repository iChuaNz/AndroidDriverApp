
import Foundation

enum APIError: Error {
    case badRequest
    case unauthorized
    case tooManyRequests
    case serverError
}

extension APIError {
    var errorDescription: String {
        switch self {
        case .badRequest:
            return "The request was unacceptable, often due to a missing or misconfigured parameter"
        case .unauthorized:
            return "Your API key was missing from the request, or wasn't correct"
        case .tooManyRequests:
            return "You made too many requests within a window of time and have been rate limited. Back off for a while"
        case .serverError:
            return "Something went wrong on our side."
        }
    }
}

protocol DataFetcher {
    func postLogin(endpoint: Endpoint,completion: @escaping (Result<[Data], APIError>) -> Void)
//    func getArticle(endpoint: Endpoint,completion: @escaping (Result<[Article], APIError>) -> Void)
}

class NetworkDataFetcher: DataFetcher {
    private let service: Service
    
    init(service: Service) {
        self.service = service
    }
    
    func postLogin(endpoint: Endpoint,completion: @escaping (Result<[Data], APIError>) -> Void) {
        service.request(endpoint: endpoint) { data, response, error in
            if let _ = error {
                completion(.failure(.badRequest))
                return
            }

            guard let response = response as? HTTPURLResponse else { return }
            
            switch response.statusCode {
            case 200:
//                if let decode = self.decode(jsonData: SourceResponse.self, from: data) {
                completion(.success([]))
//                }
            case 400:
                completion(.failure(.badRequest))
            case 401:
                completion(.failure(.unauthorized))
            case 429:
                completion(.failure(.tooManyRequests))
            case 500:
                completion(.failure(.serverError))
            default:
                break
            }
        }
    }
    
    private func decode<T: Decodable>(jsonData type: T.Type, from data: Data?) -> T? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let data = data else { return nil }
        
        do {
            let response = try decoder.decode(type, from: data)
            return response
        } catch {
            print(error)
            return nil
        }
    }
}
