import UIKit

// MARK: - AlertPresenter Class

final class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    init (delegate: AlertPresenterDelegate?){
        self.delegate = delegate
    }
    
    func alert(with model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default,
            handler: model.completion)
        
        alert.addAction(action)
        
        alert.view.accessibilityIdentifier = "Game results"
        
        delegate?.present(alert, animated: true, completion: nil)
    }
}
