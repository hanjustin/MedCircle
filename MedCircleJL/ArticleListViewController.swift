
import UIKit
import SDWebImage

class ArticleListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 500
            tableView.tableFooterView = UIView()
        }
    }
    
    var articles: [Article] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Use this function to redownload image for download simulation
        clearAllCache()
        fetchArticles()
    }
}

private extension ArticleListViewController {
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
    
    func clearAllCache() {
        SDImageCache.sharedImageCache().clearMemory()
        SDImageCache.sharedImageCache().clearDisk()
    }
}

extension ArticleListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
}

extension ArticleListViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return articles.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let spaceHeader = UIView()
        spaceHeader.backgroundColor = .clearColor()
        return spaceHeader
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCellWithIdentifier(String(ArticleTableCell), forIndexPath: indexPath) as? ArticleTableCell
            else { return UITableViewCell() }

        let article = articles[indexPath.section]
        
        cell.configure(with: article, in: tableView, at: indexPath)
        
        
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
        
        mediaImageView.sd_setImageWithURL(NSURL(string: article.media_url), placeholderImage: UIImage(named: "placeHolder")) { image, _, cacheType, _ in
            // Completion block to eliminate white spaces around the image when download is complete.
            guard cacheType == .None else { return }
            NSOperationQueue.mainQueue().addOperationWithBlock {
                guard tableView.cellForRowAtIndexPath(indexPath) != nil else { return }
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
        authorImageView.sd_setImageWithURL(NSURL(string: article.author.iconURL), placeholderImage: UIImage(named: "authorPlaceHolder"))
    }
}
