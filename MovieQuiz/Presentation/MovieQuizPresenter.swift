//  Created by Dmitfre on 16.08.2023.

import UIKit

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    var currentQuestionIndex: Int = 0
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    //var noButton: UIButton!
    //var yesButton: UIButton!
    
    var correctAnswers = 0   /// также объявлена в контроллере
    var questionFactory: QuestionFactoryProtocol?  /// также объявлена в контроллере
    var alertPresenter: AlertPresenterProtocol?   /// также объявлена в контроллере
    var statisticService: StatisticService = StatisticServiceImplementation()  /// также объявлена в контроллере
    
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
    
    /* func setButtonsEnabled(isEnabled: Bool) {
        noButton?.isEnabled = isEnabled
        yesButton?.isEnabled = isEnabled
    } */
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        
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
        
        if  self.isLastQuestion() { // presenter.currentQuestionIndex == presenter.questionsAmount - 1 { //currentQuestionIndex == questionsAmount - 1 {
            
            let totalQuestions = currentQuestionIndex + 1 //let totalQuestions = currentQuestionIndex + 1 - ???
            
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
            self.switchToNextQuestion() // presenter.currentQuestionIndex += 1 // currentQuestionIndex += 1
            
            questionFactory?.requestNextQuestion()
        }
    }
    
    func startNewQuiz() {
        
        currentQuestionIndex = 0  // currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
}
