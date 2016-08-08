
import UIKit

class ArticleTableCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var bodyTextLabel: UILabel!
    
    @IBOutlet weak var mediaImageView: UIImageView! {
        didSet {
            mediaImageView.setIndicatorStyle(.Gray)
            mediaImageView.setShowActivityIndicatorView(true)
        }
    }
    @IBOutlet weak var authorImageView: UIImageView! {
        didSet {
            authorImageView.setIndicatorStyle(.Gray)
            authorImageView.setShowActivityIndicatorView(true)
        }
    }
    
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var bodySectionView: UIStackView!
    
    func startActivityIndicator() {
        activityIndicatorView.startAnimating()
    }
    
    func stopActivityIndicator() {
        activityIndicatorView.stopAnimating()
    }
    
    func showBodySection() {
        bodySectionView.hidden = false
    }
    
    func hideBodySection() {
        bodySectionView.hidden = true
    }
}
