//
//  MainViewController.swift
//  UIKit-Combine-MVVM
//
//  Created by Hisashi Ishihara on 2024/01/05.
//

import UIKit
import Combine
import SafariServices

// Swift(UIKit): Combineを用いたMVVMのサンプルコード
// https://www.fuwamaki.com/article/255

class MainViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.registerForCell(MainTableViewCell.self)
            tableView.delegate = self
            // TableViewのitems自動更新 items値の更新で、自動的に表示するitemsが更新される形式
            viewModel.listSubject
                .sink(receiveValue: tableView.items { tableView, indexPath, item in
                    let cell = tableView.dequeueCellForIndexPath(indexPath) as MainTableViewCell
                    cell.render(repo: item)
                    return cell
                })
                .store(in: &subscriptions)
        }
    }

    private lazy var searchController: UISearchController = {
        let controller = UISearchController()
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.delegate = self
        controller.searchBar.tintColor = .systemMint
        controller.searchBar.placeholder = "GithubのQueryを入力"
        return controller
    }()

    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        indicator.center = self.view.center
        indicator.hidesWhenStopped = true
        indicator.color = UIColor.systemMint
        indicator.isHidden = true
        return indicator
    }()

    // subscriptions: 監視状態を管理。
    private var subscriptions = Set<AnyCancellable>()
    // ViewModelの値を監視
    private let viewModel: MainViewModelable = MainViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        view.addSubview(indicator)

        // ViewModelの値を監視、変更を検知してアクション

        // isLoadingSubject 変数を監視しているコードです
        viewModel.isLoadingSubject
            .sink { [weak self] in // isLoadingSubject の値が変更されたら、sink 内の処理がはしります。
                $0
                ? self?.indicator.startAnimating()
                : self?.indicator.stopAnimating()
                self?.indicator.isHidden = !$0
            }
            .store(in: &subscriptions) // また、.store(in: &subscriptions) とすることで、subscriptions 変数が破棄されたタイミングで監視が終了します。
            // ViewControllerのclass が subscriptions を保持しているので、ViewController が破棄されたタイミング、つまり画面を閉じたタイミング。

        // 値showWebViewSubject の変更を検知したら、SafariWebView表示
        viewModel.showWebViewSubject
            // View 値の変更を検知
            .sink { [weak self] in // sink: 対象の値を監視。変更を検知して何かしら処理。
                // View 変更された値に即した処理
                let viewController = SFSafariViewController(url: $0)
                self?.present(viewController, animated: true)
            }
            .store(in: &subscriptions) // subscriptions: 監視状態を管理。変数破棄と同時に、全監視を終了。

        viewModel.errorAlertSubject
            .filter { !$0.isEmpty }
            .sink { [weak self] message in
                let alert = UIAlertController(
                    title: "エラー",
                    message: message,
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
            .store(in: &subscriptions)
    }
}

// MARK: UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MainTableViewCell.defaultHeight
    }
    // View セルをタップ
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // ViewModel アクションを ViewModel に伝える
        viewModel.handleDidSelectRowAt(indexPath)
    }
}

// MARK: UISearchBarDelegate
extension MainViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {}

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        Task { await viewModel.fetch(query: searchBar.text) }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.text = ""
    }
}
