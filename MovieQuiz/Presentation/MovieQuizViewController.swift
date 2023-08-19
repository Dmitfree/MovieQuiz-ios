import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate {
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenterProtocol?  /// также объявлена в презентере
    
   // private var statisticService: StatisticService = StatisticServiceImplementation()  /// также объявлена в презентере
    
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        
        imageView.layer.cornerRadius = 20
        
        showLoadingIndicator()
        
       // statisticService = StatisticServiceImplementation()  /// инициализируем сервис по статистике
        
        presenter.alertPresenter = AlertPresenter(delegate: self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - AlertPresenterDelegate

    func startNewQuiz() {
        
        presenter.currentQuestionIndex = 0  
        presenter.correctAnswers = 0
        presenter.questionFactory?.requestNextQuestion()
    }
    
    // MARK: - Private functions
    
    private func setButtonsEnabled(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
        
        setButtonsEnabled(isEnabled: true)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            presenter.correctAnswers += 1  //  presenter.didAnswer(isCorrectAnswer: isCorrect) - в уроке
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    //MARK: - URLSession
    
    func showLoadingIndicator() {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
    }
   
    func showNetworkError(message: String) {
        
        showLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз")
        { [weak self] _ in
            self?.presenter.startNewQuiz()
            
            self?.presenter.resetQuestionIndex()
            self?.presenter.correctAnswers = 0
                    
            self?.presenter.questionFactory?.requestNextQuestion()
        }
        presenter.alertPresenter?.alert(with: model)
    }
    
    // MARK: - Actions
    
        @IBAction private func yesButtonClicked(_ sender: Any) {
            presenter.yesButtonClicked()
            setButtonsEnabled(isEnabled: false)
        }
        
        @IBAction private func noButtonClicked(_ sender: Any) {
            presenter.noButtonClicked()
            setButtonsEnabled(isEnabled: false)
        }
  }
