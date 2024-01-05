//
//  MainViewModel.swift
//  UIKit-Combine-MVVM
//
//  Created by Hisashi Ishihara on 2024/01/05.
//

import Foundation
import Combine

protocol MainViewModelable {
    // Combine 
    // CurrentValueSubject と PassthroughSubject を使い分けています。これらは、値を保持しているか・していないかの違いがあります。
    // CurrentValueSubject:  値を保持      サンプルコードの場合だと、Cellタップ時の処理にitemの値を用いています。このように値を再利用したい場合、CurrentValueSubjectは有効です。ただ値を保持する場合は、初期値を設定する必要があります。監視する側が、初期値のときにも処理がはしってしまうので注意が必要です。
    // PassthroughSubject :  値を保持しない そのため、初期値を持つことはありません。監視する側で、最初に処理がはしってしまうことはありません。ボタンアクション時などに有効です。

    // TableViewのitems自動更新
    var listSubject: CurrentValueSubject<[GithubRepo], Never> { get }
    var isLoadingSubject: PassthroughSubject<Bool, Never> { get }
    var showWebViewSubject: PassthroughSubject<URL, Never> { get }
    var errorAlertSubject: PassthroughSubject<String, Never> { get }
    func fetch(query: String?) async
    func handleDidSelectRowAt(_ indexPath: IndexPath)
}


final class MainViewModel {
    // TableViewのitems自動更新
    var listSubject = CurrentValueSubject<[GithubRepo], Never>([])
    var isLoadingSubject = PassthroughSubject<Bool, Never>()
    // ViewController側で監視している値
    var showWebViewSubject = PassthroughSubject<URL, Never>()
    var errorAlertSubject = PassthroughSubject<String, Never>()

    // Model
    private let apiClient: APIClientable

    convenience init() {
        self.init(apiClient: APIClient())
    }

    init(apiClient: APIClientable) {
        self.apiClient = apiClient
    }

    @MainActor private func setupLoading(_ isLoading: Bool) {
        isLoadingSubject.send(isLoading)
    }

    // TableViewのitems自動更新
    @MainActor private func setupList(_ list: [GithubRepo]) {
        self.listSubject.send(list)
        // items 値は listSubject に相当。
        // ViewController 側で listSubject を監視していて、
        // 値が更新されたら TableViewCell たちを更新するという流れ。
    }

    @MainActor private func showErrorAlert(_ message: String) {
        self.errorAlertSubject.send(message)
    }
}

// MARK: MainViewModelable
extension MainViewModel: MainViewModelable {
    func fetch(query: String?) async {
        do {
            guard let query = query else { return }
            await self.setupLoading(true)
            let list = try await apiClient.fetchGithubRepo(query: query).items
            await self.setupList(list)
            await self.setupLoading(false)
        } catch let error {
            await self.setupLoading(false)
            guard let error = error as? APIError else { return }
            await self.showErrorAlert(error.message)
        }
    }
    // ViewModel セルをタップ
    func handleDidSelectRowAt(_ indexPath: IndexPath) {
        let item = listSubject.value[indexPath.row]
        guard let url = URL(string: item.htmlUrl) else { return }
        // View ViewController が監視している値を変更
        showWebViewSubject.send(url)
    }
}
