import UIKit

// MARK: - AlertPresenter Class

final class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    init (delegate: AlertPresenterDelegate?){
        self.delegate = delegate
    }
    
    func alert(with model: AlertModel) {  /// метод показа алерта
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default,
            handler: model.completion)   /// Completion handler – это функция, которая в качестве параметра принимает другую функцию.
        
        alert.addAction(action)
        
        delegate?.present(alert, animated: true, completion: nil)
    }
}
