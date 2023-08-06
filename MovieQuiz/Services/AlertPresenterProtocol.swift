import Foundation

protocol AlertPresenterProtocol {
    var delegate: AlertPresenterDelegate? { get }
    func alert(with model: AlertModel)
}
