//
//  DoctorsSpecialitiesPresenter.swift
//  Smart Doc
//
//  Created by Vlad Zhokhov on 30/04/2020.
//  Copyright © 2020 Vlad Zhokhov. All rights reserved.
//

import UIKit
/// Интерфейс взаимодействия с презентером экрана TransfersToAnotherPerson.
protocol DoctorsSpecialitiesPresentable {}

/// Презентер флоу переводы: другому человеку
final class DoctorsSpecialitiesPresenter: DoctorsSpecialitiesPresentable {

	/// Вью контроллер разводного экрана переводы: другому человеку
	weak var viewController: DoctorSpecialitiesControllable?

	private let interactor: DoctorSpecialitiesInteractable
	private let coordinator: FlowCoordinating & FlowRouting

	var viewModel: SpecialitiesViewModel?

	init(interactor: DoctorSpecialitiesInteractable,
		 coordinator: FlowCoordinating & FlowRouting) {
		self.interactor = interactor
		self.coordinator = coordinator
	}
}

// MARK: - CalendarPresentableListener

extension DoctorsSpecialitiesPresenter: DoctorSpecialitiesListener {

	func getSpecialitiesList(polyclinicID: String?, completion: @escaping (Result<SpecialitiesViewModel, Error>) -> Void) {

		interactor.getRequest(polyclicID: polyclinicID, completion: { productsModelResult in
			switch productsModelResult {
			case .success(let doctorsModel):

				DispatchQueue.main.async {
					print("\nПолучили специализацию врачей: \n\(doctorsModel)")
					let vm = SpecialitiesViewModel(model: doctorsModel)
					self.viewController?.bind(specialitiesNames: vm.specialitiesNames,
											  specialitiesID: vm.specialitiesID)
					print("Cпециализации: \(vm.specialitiesNames)\n")
					print("ID специализации: \(vm.specialitiesID)\n")

					//viewController.bind(polyclinics: vm.organizations, polyclinicsId: vm.organizatiosId)
				}
				//print("\nЧИ НЕ: \n\(doctorsModel)")
				//let vm = SpecialitiesViewModel(model: doctorsModel)
				//completion(.success(vm))
			case .failure(let error):
				print("error: \n \(error)")
				completion(.failure(error))
			}
		})
	}

//	func getDoctorsModel() {
//		interactor.getRequest(polyclicID: nil) { (result) in
//			switch result {
//			case .success(let doctorsModel):
//				print("\nУспешно выполнен запрос на получение специальностей докторов :\n\(doctorsModel)")
//				self.viewModel = SpecialitiesViewModel(model: doctorsModel)
//				print(self.viewModel as Any)
//			case .failure(let error):
//				print("error: \n \(error)")
//			}
//		}
//		//return self.viewModel!
//	}

	func didOpenCalendar(Resource_ID: String, specialization: String) {
		print("ID специализации: \(Resource_ID)\n")
		coordinator.routeToCalendar(resourceID: Resource_ID, specialization: specialization)
	}

//	func didOpenCalendar(Resource_ID: String) {
//		print("ID специализации: \(Resource_ID)\n")
//		coordinator.routeToCalendar(resourceID: Resource_ID)
//	}

	func didLoad(_ viewController: UIViewController, polyclinicID: String?) {

		interactor.getRequest(polyclicID: polyclinicID, completion: { productsModelResult in
			switch productsModelResult {
			case .success(let doctorsModel):
				DispatchQueue.main.async {
					print("\nПолучили специализацию врачей: \n\(doctorsModel)")
					let vm = SpecialitiesViewModel(model: doctorsModel)
					self.viewController?.bind(specialitiesNames: vm.specialitiesNames,
											  specialitiesID: vm.specialitiesID)
					print("Cпециализации: \(vm.specialitiesNames)\n")
					print("ID специализации: \(vm.specialitiesID)\n")
				}
				//print("\nЧИ НЕ: \n\(doctorsModel)")
				//let vm = SpecialitiesViewModel(model: doctorsModel)
				//completion(.success(vm))
			case .failure(let error):
				print("error: \n \(error)")
				//completion(.failure(error))
			}
		})
	}

	func didPressBack(_ viewController: UIViewController) {
		coordinator.routeBack(from: viewController)
	}
}
