//
//  ArticleListViewController.swift
//  
//
//  Created by 坂本 浩 on 2016/05/04.
//
//

import UIKit
import WebImage
import RxSwift


class ArticleListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var table: UITableView!

    var articles: [Article] = []
    var postUrl: URL?
    var refreshControll: UIRefreshControl!
    
    private let bag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.rowHeight = 40.0
        table.separatorInset = UIEdgeInsets.zero
        title = "新着記事"
        
        setupSearchBar()
        
        refreshControll = UIRefreshControl()
        refreshControll.attributedTitle = NSAttributedString(string: "下に引っ張って更新")
        pullToRefresh()
        
        table.addSubview(refreshControll)
    }
    
    /// tableViewの行数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    /// tableViewのcellを生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = table.dequeueReusableCell(withIdentifier: "ArticleTableViewCell", for: indexPath) as! ArticleTableViewCell
        let article = articles[indexPath.row]
        
        print("cell生成")
//        cell.setCell(article: article)
//        label.lineBreakMode = .byTruncatingTail
        
        return cell
    }
    
    /// tableViewタップ時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let article = articles[indexPath.row]

        postUrl = URL(string: article.url)
        performSegue(withIdentifier: "toWebView", sender: nil)
    }
    
    /// 各segueの設定
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
            case "toWebView":
                let webView: WebViewController = segue.destination as! WebViewController
                webView.url = postUrl
            default:
                break
        }
    }
    
    func pullToRefresh() {
        
        self.refreshControll.rx.controlEvent(.valueChanged)
            .asObservable()
            .startWith(())
            .flatMap {
                return Article.fetch()
            }
            .subscribe(onNext: { [unowned self] result in
                
                print("fetch done")
                
                self.articles = result
                self.table.delegate = self
                self.table.dataSource = self
                self.table.reloadData()
                
                self.refreshControll.endRefreshing()
            })
            .addDisposableTo(bag)
    }


    private func setupSearchBar() {
        
        let navigationBarFrame: CGRect = self.navigationController!.navigationBar.bounds
        let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
        
        searchBar.delegate = self
        searchBar.placeholder = "タグを検索"
        searchBar.showsCancelButton = true
        searchBar.autocapitalizationType = .none
        searchBar.keyboardType = .default
        navigationItem.titleView = searchBar
    }
}
