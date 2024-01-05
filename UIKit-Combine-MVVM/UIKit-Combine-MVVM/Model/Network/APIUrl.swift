//
//  APIUrl.swift
//  UIKit-Combine-MVVM
//
//  Created by Hisashi Ishihara on 2024/01/05.
//

import Foundation

struct APIUrl {
    static func githubRepo(query: String) -> URL {
        return URL(string: "https://api.github.com/search/repositories?q=\(query)")!
    }
}
