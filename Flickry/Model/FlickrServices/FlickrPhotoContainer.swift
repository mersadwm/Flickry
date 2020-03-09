//
//  FlickrPhoto.swift
//  Flickry
//
//  Created by Mersad Ewaz Zadeh on 06.03.20.
//  Copyright © 2020 Mersad Ewaz Zadeh. All rights reserved.
//

import Foundation
import UIKit

struct FlickrPhotoContainer: Decodable {
    let status: String
    let photoAlbum: FlickrPhotoCollection

    enum CodingKeys: String, CodingKey {
        case status = "stat"
        case photoAlbum = "photos"
    }

}

struct FlickrPhotoCollection: Decodable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    var photos: [FlickrPhoto]

    enum CodingKeys: String, CodingKey {
        case page, pages, perpage, total, photos = "photo"
    }
}

struct FlickrPhoto: Decodable {
    let owner: String
    let title: String
    var imageSizeRatio: Double?
    private let photoID: String
    private let farm: Int
    private let secret: String
    private let server: String

    enum CodingKeys: String, CodingKey {
        case owner, title, imageSizeRatio, farm, secret, server, photoID = "id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.owner = try container.decode(String.self, forKey: .owner)
        self.title = try container.decode(String.self, forKey: .title)
        self.photoID = try container.decode(String.self, forKey: .photoID)
        self.farm = try container.decode(Int.self, forKey: .farm)
        self.secret = try container.decode(String.self, forKey: .secret)
        self.server = try container.decode(String.self, forKey: .server)
        self.imageSizeRatio = try container.decodeIfPresent(Double.self, forKey: .imageSizeRatio)
        imageSizeRatio = {
            if let url = self.imageURL(size: .medium) {
                let source = CGImageSourceCreateWithURL(url as CFURL, nil)
                guard source != nil else { return nil }
                let imageHeader: NSDictionary? = CGImageSourceCopyPropertiesAtIndex(source!, 0, nil)
                if let imageHeader = imageHeader,
                    let height = imageHeader["PixelHeight"] as? Double,
                    let width = imageHeader["PixelWidth"] as? Double {
                    let ratio = height / width
                    return ratio
                }
            }
            return nil
        }()

    }

    func imageURL(size: ImageSize) -> URL? {
        if let url =
            URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size.rawValue).jpg") {
            return url
        }
        return nil
    }
}

enum ImageSize: String {
    case large = "b"
    case medium = "m"
}
