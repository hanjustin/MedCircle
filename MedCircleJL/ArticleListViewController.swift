
import UIKit
import SDWebImage

class ArticleListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 1000
            tableView.tableFooterView = UIView()
        }
    }
    
    private var articles: [Article] = []
    private var selectedArticles: Set<Int> = []
    private var articlesDownloadingBodyData: Set<Int> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchArticles()
    }
}

private extension ArticleListViewController {
    func articleFor(indexPath: NSIndexPath) -> Article {
        return articles[indexPath.section]
    }
    
    func fetchArticles() {
        DataService().fetchAllResources { (articles: [Article]?, error) in
            guard let articles = articles where error == nil else { return self.presentOKAlert("Error", message: error?.description) }
            
            NSOperationQueue.mainQueue().addOperationWithBlock{
                self.articles = articles
                self.tableView.reloadData()
            }
        }
    }
    
    func presentOKAlert(title: String?, message: String?, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Default, handler: handler)
        
        alert.addAction(ok)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func toggleSelectionOf(article: Article){
        if selectedArticles.contains(article.id) {
            selectedArticles.remove(article.id)
        } else {
            selectedArticles.insert(article.id)
        }
    }
    
    func hasSelected(article: Article) -> Bool {
        return selectedArticles.contains(article.id)
    }
    
    func setViewsVisibilityOf(cell: ArticleTableCell, with indexPath: NSIndexPath) {
        let article = articleFor(indexPath)
        
        switch stateForArticle(article) {
        case .selectedAndDownloaded:
            cell.showBodySection()
            cell.stopActivityIndicator()
        case .selectedAndDownloading:
            cell.hideBodySection()
            cell.startActivityIndicator()
        case .notSelected:
            cell.hideBodySection()
            cell.stopActivityIndicator()
        }
    }
    
    enum ArticleState {
        case selectedAndDownloaded, selectedAndDownloading, notSelected
    }
    func stateForArticle(article: Article) -> ArticleState {
        if hasSelected(article) {
            if articlesDownloadingBodyData.contains(article.id) {
                return .selectedAndDownloading
            } else {
                return .selectedAndDownloaded
            }
        } else {
            return .notSelected
        }
    }
}

extension ArticleListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let article = articleFor(indexPath)
        let id = article.id
        toggleSelectionOf(article)

        let shouldDownloadBodyData = article.body == nil && hasSelected(article) && !articlesDownloadingBodyData.contains(id)
        if shouldDownloadBodyData {
            articlesDownloadingBodyData.insert(id)
            
            DataService().fetchResource(withID: String(id)) { [weak self] (downloadedArticle: Article?, error) in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    
                    guard let strongSelf = self else { return }
                    strongSelf.articlesDownloadingBodyData.remove(id)
                    if let downloadedArticle = downloadedArticle { strongSelf.articles[indexPath.section].updateDataWith(downloadedArticle) }
                    if error != nil { strongSelf.presentOKAlert("Error", message: error?.description) }
                    tableView.reloadData()
                    tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
                }
            }
        }

        tableView.reloadData()
        let isExpanding = hasSelected(article)
        let scrollPosition: UITableViewScrollPosition = isExpanding ? .Top : .Bottom
        let animated = isExpanding
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: scrollPosition, animated: animated)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let spaceHeader = UIView()
        spaceHeader.backgroundColor = .clearColor()
        return spaceHeader
    }
}

extension ArticleListViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return articles.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCellWithIdentifier(String(ArticleTableCell), forIndexPath: indexPath) as? ArticleTableCell
            else { return UITableViewCell() }
        
        let article = articleFor(indexPath)
        cell.configure(with: article, in: tableView, at: indexPath)
        setViewsVisibilityOf(cell, with: indexPath)
        
        return cell
    }
    
}

private extension ArticleTableCell {
    func configure(with article: Article, in tableView: UITableView, at indexPath: NSIndexPath) {
        titleLabel.text = article.title
        summaryLabel.text = article.summary
        likesCountLabel.text = String(article.likesCount)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateLabel.text = formatter.stringFromDate(article.publishedDate)
        authorNameLabel.text = article.author.name
        bodyTextLabel.text = article.body
        
        mediaImageView.sd_setImageWithURL(NSURL(string: article.media_url), placeholderImage: UIImage(named: "placeHolder")) { _, _, cacheType, _ in
            //Eliminate white spaces around the image when image is set by making cell to recalculate height
            guard cacheType == .None || cacheType == .Disk else { return }
            NSOperationQueue.mainQueue().addOperationWithBlock {
                guard tableView.cellForRowAtIndexPath(indexPath) != nil else { return }
                tableView.reloadData()
            }
        }
        authorImageView.sd_setImageWithURL(NSURL(string: article.author.iconURL), placeholderImage: UIImage(named: "authorPlaceHolder"))
    }
}
