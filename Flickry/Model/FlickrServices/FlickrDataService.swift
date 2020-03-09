//
//  DataService.swift
//  Flickry
//
//  Created by Mersad Ewaz Zadeh on 06.03.20.
//  Copyright © 2020 Mersad Ewaz Zadeh. All rights reserved.
//

import Foundation

class FlickrDataService {
    static let shared = FlickrDataService()
    fileprivate let baseURLString = "api.flickr.com"
    fileprivate let apiKey = "a951464844327e27ddad9028b73dd1dd"

    /// Returns  a matching URLComponents for a specific Flickr API method
    /// - Parameters:
    ///   - method: Flickr API method
    ///   - optionString: additional parameter to add to the url in String tuple form
    private func createURLComponents(for method: FlickerMethod, optionString: (paramName: String, paramValue: String)?) -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = baseURLString
        components.path = "/services/rest"
        components.queryItems = [
            URLQueryItem(name: "method", value: method.rawValue),
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1")
        ]

        if let option = optionString {
            components.queryItems?.append(URLQueryItem(name: option.paramName, value: option.paramValue))
        }

        return components
    }

    /// Gets data from Flickr server
    /// - Parameters:
    ///   - method: Flckr API method used to get data
    ///   - additionalQueryParam: optional additional query parameter in String tuple form
    ///   - completion:  callback method to use a PhotoContainer or handle error
    func fetchPhotoContainer(using method: FlickerMethod, additionalQueryParam: (String, String)?, completion: @escaping (Result<FlickrPhotoContainer, Error>) -> Void) {

        let componentURL = createURLComponents(for: method, optionString: additionalQueryParam)

        guard let validURL = componentURL.url else {
            print("URL creation failed...")
            return
        }

        URLSession.shared.dataTask(with: validURL) { (data, response, error) in

            if let httpResponse = response as? HTTPURLResponse {
                print("API status: \(httpResponse.statusCode)")
            }

            guard let validData = data, error == nil else {
                completion(.failure(error!))
                return
            }

            do {
                let photoContainer = try JSONDecoder().decode(FlickrPhotoContainer.self, from: validData)
                completion(.success(photoContainer))
            } catch {
                completion(.failure(error))
            }
        }.resume()

    }
}

enum FlickerMethod: String {
    case searchPhotos = "flickr.photos.search"
    case interestingness = "flickr.interestingness.getList"
}
