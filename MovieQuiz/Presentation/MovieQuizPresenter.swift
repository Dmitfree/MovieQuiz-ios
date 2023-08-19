//  Created by Dmitfre on 16.08.2023.

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let statisticService: StatisticService!
    private weak var viewController: MovieQuizViewController?
    
    var questionFactory: QuestionFactoryProtocol?  /// should be - private
    
    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10 /// should be - private
    var currentQuestionIndex: Int = 0  /// should be - private
    var correctAnswers = 0  /// should be - private
    
    var alertPresenter: AlertPresenterProtocol?   /// также объявлена в контроллере
    
    init (viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.loadingIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }

        func didFailToLoadData(with error: Error) {
            viewController?.showNetworkError(message: error.localizedDescription)
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
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
  /*  func didAnswer(isCorrectAnswer: Bool) {
            if isCorrectAnswer {
                correctAnswers += 1
            }
        }
   
   func restartGame() {
           currentQuestionIndex = 0
           correctAnswers = 0
           questionFactory?.requestNextQuestion()
       }
   */
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
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
    
    private func didAnswer(isCorrectAnswer: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isCorrectAnswer
        
        //viewController?.highlightImageBorder(isCorrectAnswer: givenAnswer == currentQuestion.correctAnswer)
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1  //  presenter.didAnswer(isCorrectAnswer: isCorrect) - в уроке
        }
        
       // didAnswer(isCorrectAnswer: isCorrect) - не работает
                
                viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
   private func showNextQuestionOrResults() {
        
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
}
