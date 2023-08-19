//  Created by Dmitfre on 16.08.2023.

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    let questionsAmount: Int = 10
    
    var currentQuestionIndex: Int = 0
    
    var currentQuestion: QuizQuestion?
    
    var correctAnswers = 0
    
    var alertPresenter: AlertPresenterProtocol?   /// также объявлена в контроллере
    ///
    var statisticService: StatisticService = StatisticServiceImplementation()  /// также объявлена в контроллере
    
    // MARK: - QuestionFactoryDelegate
    
    var questionFactory: QuestionFactoryProtocol? 
    private weak var viewController: MovieQuizViewController?
    
    init (viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return questionStep
    }
    
    func yesButtonClicked() {
        didAnswer(isCorrectAnswer: true)
    }
    
    func noButtonClicked() {
        didAnswer(isCorrectAnswer: false)
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isCorrectAnswer
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionOrResults() {
        
        if  self.isLastQuestion() {
            
            let totalQuestions = currentQuestionIndex + 1
            
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
            self.switchToNextQuestion()
            
            questionFactory?.requestNextQuestion()
        }
    }
    
    func startNewQuiz() {
        
        currentQuestionIndex = 0  
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func didLoadDataFromServer() {
        viewController?.loadingIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }

        func didFailToLoadData(with error: Error) {
            viewController?.showNetworkError(message: error.localizedDescription)
    }
}
