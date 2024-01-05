//
//  MainTableViewCell.swift
//  UIKit-Combine-MVVM
//
//  Created by Hisashi Ishihara on 2024/01/05.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!

    private let apiClient: APIClientable = APIClient()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    public func render(repo: GithubRepo) {
        titleLabel.text = repo.fullName
        subTitleLabel.text = repo.stargazerText
        guard let url = URL(string: repo.owner.avatarUrl) else { return }
        Task {
            let data = try await apiClient.fetchImageData(url: url)
            self.setupImage(UIImage(data: data))
        }
    }

    @MainActor private func setupImage(_ image: UIImage?) {
        self.iconImageView.image = image
    }
}

// MARK: NibLoadable
extension MainTableViewCell: NibLoadable {}
