import UIKit

class ImageViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bgImageView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnRemove: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // set image of screen shot
        imageView.contentMode = .scaleAspectFill

        // set remove button text
        btnRemove.setTitle("", for: .normal)
    }

}
