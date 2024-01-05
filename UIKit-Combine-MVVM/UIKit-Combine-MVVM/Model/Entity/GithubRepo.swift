//
//  GithubRepo.swift
//  UIKit-Combine-MVVM
//
//  Created by Hisashi Ishihara on 2024/01/05.
//

struct GithubRepo: Codable {
    let fullName: String
    let stargazersCount: Int
    let htmlUrl: String
    let owner: GithubRepoOwner

    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case stargazersCount = "stargazers_count"
        case htmlUrl = "html_url"
        case owner
    }

    init(fullName: String, stargazersCount: Int, htmlUrl: String, owner: GithubRepoOwner) {
        self.fullName = fullName
        self.stargazersCount = stargazersCount
        self.htmlUrl = htmlUrl
        self.owner = owner
    }

    var stargazerText: String {
        "☆ " + String(stargazersCount)
    }
}

struct GithubRepoOwner: Codable {
    let avatarUrl: String

    enum CodingKeys: String, CodingKey {
        case avatarUrl = "avatar_url"
    }

    init(avatarUrl: String) {
        self.avatarUrl = avatarUrl
    }
}

struct GithubRepoList: Codable {
    let items: [GithubRepo]
}
