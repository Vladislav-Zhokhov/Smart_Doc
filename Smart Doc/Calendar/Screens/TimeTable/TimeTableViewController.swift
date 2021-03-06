//
//  TimeTableViewController.swift
//  Smart Doc
//
//  Created by Vlad Zhokhov on 01/03/2020.
//  Copyright © 2020 Vlad Zhokhov. All rights reserved.
//

import UIKit

/// Тип отображенного алерта
enum AlertType {
	/// Успешно прошла запись
	case success
	/// Записаться невозможно
	case error
}

/// Интерфейс взаимодействия с вью-контроллером экрана TimeTableViewController.
protocol TimeTableControllable {

}

// TO DO : viewcontroller - все через протокол CalendarViewControllable
// убрать UIViewController

/// Интерфейс взаимодействия с презентером экрана TimeTableViewController.
protocol TimeTablePresentableListener {

	/// Данные загрузились
	///
	/// - Parameter viewController: текущий вью контроллер
	func didLoad(_ viewController: UIViewController)

	/// Информирует листенер о нажатии кнопки назад.
	///
	/// - Parameter viewController: Вью-контроллера экрана DoctorsSpecialities.
	func didPressBack(_ viewController: UIViewController)

	/// Пользователь выбрал удобное время и записался на прием
	/// - Parameters:
	///   - slotID: id выбранного талона
	///   - firstName: Имя пользователя
	///   - birthday: Дата рождения пользователя
	///   - phoneNumber: Номер телефона
	///   - email: Электронная почта
	///   - polis: Номер полиса
	func createAppointment(slotID: String,
						   firstName: String,
						   birthday: String,
						   phoneNumber: String,
						   email: String,
						   polis: String)


	/// Нажали на продложить при успешной записи на прием
	/// - Parameters:
	///   - time: Время приема
	///   - date: Дата приема
	func didTapContinue(time: String, date: String)

	/// Нажили повторить запись при успешной записи на прием
	func didTapRepeat()
}

/// Расписание
class TimeTableViewController: UIViewController, TimeTableControllable {

	/// Талоны
	var datasourse: SlotViewModel?

	var currentPolyclinic: String = ""

	private var selectTime: String = ""

	private var minutes: String = ""

	let descriptionLabel: UILabel = {
		let label = UILabel()
		label.sizeToFit()
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.boldSystemFont(ofSize: 25)
		label.textColor = .white
//		label.text = "Выберите свободное время: Время приема: \(datasourse?.dateShow.last), \(datasourse?.timeShow.last)"
		label.backgroundColor = .clear
		return label
	}()

	private let refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
		//refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
		refreshControl.backgroundColor = .clear
		return refreshControl
	}()

	private lazy var collectionView: UICollectionView = {
		let collectionViewLayout = UICollectionViewFlowLayout()
		collectionViewLayout.scrollDirection = .vertical
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.showsVerticalScrollIndicator = false
		collectionView.backgroundColor = .clear //Colors.mainColor
		collectionView.clipsToBounds = true // false
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.register(TimeTableCollectionViewCell.self,
								forCellWithReuseIdentifier: "CollectionViewCell")
		collectionView.refreshControl = refreshControl
		return collectionView
	}()

	private var listener: TimeTablePresentableListener?

	init(listener: TimeTablePresentableListener) {
		super.init(nibName: nil, bundle: nil)
		self.listener = listener
	}

	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubviews(descriptionLabel, collectionView)
//		view.addSubview(collectionView)
		setupView()
		setGradient()
	}

	private func setGradient() {
		let gradient: CAGradientLayer = CAGradientLayer()

		let leftColor = Colors.mainColor
		let rightColor = UIColor.purple

		gradient.colors = [leftColor.cgColor, rightColor.cgColor]
		gradient.locations = [0.0 , 1.0]
		gradient.startPoint = CGPoint(x: 0.4, y: 0.6)
		gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
		gradient.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height)

		view.layer.insertSublayer(gradient, at: 0)
	}

	@objc private func refresh(sender: UIRefreshControl) {
		// TO: DO - добавить выгрузку данных
		//listener.getData
		sender.endRefreshing()
	}

	private func setupView() {
		NSLayoutConstraint.activate([

			descriptionLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 35),
			descriptionLabel.rightAnchor.constraint(equalTo: view.rightAnchor),
			descriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),

			collectionView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 25),
			collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25)
		])
	}

	private func showAlertButtonTapped(type: AlertType) {

		var alert: UIAlertController = UIAlertController()

		if type == .success {
			// create the alert
			alert = UIAlertController(title: "Успех", message: "Вы записались на прием", preferredStyle: UIAlertController.Style.alert)
			// add an action (button)
			alert.addAction(UIAlertAction(title: "Продолжить", style: UIAlertAction.Style.default, handler: didTapСontinue))
			alert.addAction(UIAlertAction(title: "Повторить", style: UIAlertAction.Style.cancel, handler: didTapRepeat))
		} else if type == .error {
			alert = UIAlertController(title: "Произошла ошибка", message: "Выберите другое время для записи", preferredStyle: UIAlertController.Style.alert)
			alert.addAction(UIAlertAction(title: "ОК", style: UIAlertAction.Style.default, handler: nil))
		}

		// show the alert
		self.present(alert, animated: true, completion: nil)
	}

	private func didTapСontinue(alert: UIAlertAction!) {
		listener?.didTapContinue(time: minutes, date: selectTime)
	}

	private func didTapRepeat(alert: UIAlertAction!) {
		listener?.didTapRepeat()
	}
}

extension TimeTableViewController: UICollectionViewDataSource {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return datasourse?.timeShow.count ?? 0
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! TimeTableCollectionViewCell

		cell.titleLabel.text = datasourse?.timeShow[indexPath.row]
		if datasourse?.state![indexPath.row] == 1 { cell.cellView.backgroundColor = .red }

		return cell
	}
}

extension TimeTableViewController: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		let firstName = UserSettings.userModel.name
		let birthday = UserSettings.userModel.birthdate
		let phoneNumber = UserSettings.userModel.telephone
		let email = UserSettings.userModel.email
		let polis = UserSettings.userModel.polis

		let slotID = datasourse?.doctorSpecislitiesID[indexPath.row] ?? "0000"

		if datasourse?.state![indexPath.row] == 1 {
			print("Данное время занято, Выберите пожалуйста другое время для записи к врачу")
			showAlertButtonTapped(type: .error)
		} else {
			listener!.createAppointment(slotID: slotID,
			firstName: firstName,
			birthday: birthday,
			phoneNumber: phoneNumber,
			email: email,
			polis: polis)

			/// здесь сразу перекращиваю ячеку при выборе даты
			let cell = collectionView.cellForItem(at: indexPath) as! TimeTableCollectionViewCell
			cell.cellView.backgroundColor = .red
			datasourse?.state![indexPath.row] = 1

			selectTime = (datasourse?.dateShow[indexPath.row])!
			minutes = (datasourse?.timeShow[indexPath.row])!
			print("Время приема: \(selectTime), \(minutes)")

			//print("ДАТА :\(datasourse?.dateShow)")
			showAlertButtonTapped(type: .success)
		}
	}

}

extension TimeTableViewController: UICollectionViewDelegateFlowLayout {

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.frame.width / 3.5,
					  height: collectionView.frame.width / 4)
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 15
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 15
	}
}

