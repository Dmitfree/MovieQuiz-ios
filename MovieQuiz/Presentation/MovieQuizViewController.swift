import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    
    private var currentQuestionIndex = 0
    
    private var correctAnswers = 0
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenterProtocol?
    
    private var statisticService: StatisticService?
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(NSHomeDirectory())
        
          imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(delegate: self)
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory?.requestNextQuestion()
        
        //imageView.image = UIImage(named: "The Godfather")
        
        textLabel.text = "Рейтинг этого фильма больше чем 6"
        
        alertPresenter = AlertPresenter(delegate: self)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
                self?.show(quiz: viewModel)
            }
        }
    
    // MARK: - AlertPresenterDelegate
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let text = "Ваш результат: \(correctAnswers)/10"
            //let viewModel = QuizResultsViewModel(
            let model = AlertModel(
                title: "Этот раунд окончен!",
                //text: text,
                message: text,
                //buttonText: "Сыграть ещё раз")
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    self?.questionFactory?.requestNextQuestion()
                }
            )
            //show(quiz: viewModel)
            alertPresenter?.showQuizResult(model: model)
        } else {
            currentQuestionIndex += 1
            
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - Private functions
    
    private func setButtonsEnabled(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
        
        setButtonsEnabled(isEnabled: true)
    }
    
    
    private func showAnswerResult(isCorrect: Bool) {
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
    
    // метод показа аалерта заменен на AlertPresenter
    
    /*  private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            questionFactory?.requestNextQuestion()
        }
            
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
        }
    */
   
    // MARK: - Actions
    
        @IBAction private func yesButtonClicked(_ sender: Any) {
            guard let currentQuestion = currentQuestion else {
                return
            }
            let givenAnswer = true
            
            showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
            
            setButtonsEnabled(isEnabled: false)
        }
        
        @IBAction private func noButtonClicked(_ sender: Any) {
            guard let currentQuestion = currentQuestion else {
                return
            }
            let givenAnswer = false
            
            showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
            
            setButtonsEnabled(isEnabled: false)
        }
    }
