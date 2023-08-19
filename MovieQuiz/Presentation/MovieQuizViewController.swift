import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
   // private var currentQuestionIndex = 0
   // private let questionsAmount: Int = 10
    
    private var correctAnswers = 0
    
    private var questionFactory: QuestionFactoryProtocol?
   // private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticService = StatisticServiceImplementation() /// экземпляр класса StatisticServiceImplementation
    
    private let presenter = MovieQuizPresenter()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        
        imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        questionFactory?.requestNextQuestion()
        
        showLoadingIndicator()
        questionFactory?.loadData()
        
        statisticService = StatisticServiceImplementation()  /// инициализируем сервис по статистике
        
        alertPresenter = AlertPresenter(delegate: self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
        /* guard let question = question else {
            return
        }
        
        presenter.currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    */
        
    // MARK: - AlertPresenterDelegate
    
    private func showNextQuestionOrResults() {
        
        if  presenter.isLastQuestion() { // presenter.currentQuestionIndex == presenter.questionsAmount - 1 { //currentQuestionIndex == questionsAmount - 1 {
            
            let totalQuestions = presenter.currentQuestionIndex + 1 //let totalQuestions = currentQuestionIndex + 1 - ???
            
            statisticService.store(correct: correctAnswers, total: totalQuestions)
            
            let bestGame = statisticService.bestGame
            
            let text = """
                            Ваш результат: \(correctAnswers)/\(totalQuestions)
                            Количество сыгранных квизов: \(statisticService.gamesCount)
                            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                            Средняя точность: \(String(format: "%.2f", statisticService.accuracy))%  
                        """
            let model = AlertModel(
                            title: "Этот раунд окончен!",
                            message: text,
                            buttonText: "Сыграть ещё раз"
                        ) { [weak self] _ in
                            self?.startNewQuiz()
                        }
            
            alertPresenter?.alert(with: model)   /// передаем алерту текст из модели
        } else {
            presenter.switchToNextQuestion() // presenter.currentQuestionIndex += 1 // currentQuestionIndex += 1
            
            questionFactory?.requestNextQuestion()
        }
    }

    func startNewQuiz() {
        
        presenter.currentQuestionIndex = 0  // currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - Private functions
    
    private func setButtonsEnabled(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    /*private func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return questionStep
    }
   */
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
        
        setButtonsEnabled(isEnabled: true)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    func didLoadDataFromServer() {
        loadingIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    //MARK: - URLSession
    
    private func showLoadingIndicator() {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
    }
   
    private func showNetworkError(message: String) {
        
        showLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз")
        { [weak self] _ in
            self?.startNewQuiz()
            
            self?.presenter.resetQuestionIndex()   //self?.currentQuestionIndex = 0
            self?.correctAnswers = 0
                    
            self?.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.alert(with: model)
    }
    
    // MARK: - Actions
    
        @IBAction private func yesButtonClicked(_ sender: Any) {
           /*  guard let currentQuestion = currentQuestion else {
                
                return
            }
            let givenAnswer = true
            
            showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
            
            setButtonsEnabled(isEnabled: false) */
            
            //presenter.currentQuestion = presenter.currentQuestion
            presenter.yesButtonClicked()
            setButtonsEnabled(isEnabled: false)
        }
        
        @IBAction private func noButtonClicked(_ sender: Any) {
           /* guard let currentQuestion = currentQuestion else {
                return
            }
            let givenAnswer = false
            
            showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
            
            setButtonsEnabled(isEnabled: false) */
            
           // presenter.currentQuestion = presenter.currentQuestion
            presenter.noButtonClicked()
            setButtonsEnabled(isEnabled: false)
        }
  }
