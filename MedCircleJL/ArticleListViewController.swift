
import UIKit
import SDWebImage

class ArticleListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 140
            tableView.tableFooterView = UIView()
        }
    }
    
    var articles: [Article] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
}

extension ArticleListViewController: UITableViewDelegate {
    
}

extension ArticleListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCellWithIdentifier(String(ArticleTableCell), forIndexPath: indexPath) as? ArticleTableCell
            else { return UITableViewCell() }
        
        let article = articles[indexPath.row]
        cell.titleLabel.text = article.title
        cell.summaryLabel.text = article.summary
        cell.likesCountLabel.text = String(article.likesCount)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        cell.dateLabel.text = formatter.stringFromDate(article.publishedDate)
        
        return cell
    }
}