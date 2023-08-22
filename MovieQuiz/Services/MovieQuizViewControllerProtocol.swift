//  Created by Dmitfre on 19.08.2023.

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    
    var alertPresenter: AlertPresenterProtocol? { get set }
    
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func setLoadingIndicatorHidden(_ isLoading: Bool)
}
