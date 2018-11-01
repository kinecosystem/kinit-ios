//
//  TaskLoader.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation
import KinUtil

typealias CategoryId = String
typealias CategoryObservable = Observable<FetchResult<TaskCategory>>
typealias TaskObservable = Observable<FetchResult<Task>>

class TaskLoader {
    private var currentCategoryObservable: (CategoryId, CategoryObservable)?
    private var currentTaskObservable: (CategoryId, TaskObservable)?
    private var _categories = [TaskCategory]()
    private var _tasksByCategory = [CategoryId: [Task]]()
    let headerMessage = Observable<CategoriesHeaderMessage>()
    let categories = Observable<FetchResult<[TaskCategory]>>()
        .stateful()
    let isLoadingCategories = Observable<Bool>(false)

    func loadAllData() {
        loadCategories()
        loadAllTasks()
    }

    func loadCategories() {
        self.isLoadingCategories.next(true)
        WebRequests.taskCategories().withCompletion { [weak self] response, error in
            guard let self = self else {
                return
            }

            self.isLoadingCategories.next(false)

            if let categories = response?.categories, categories.isNotEmpty {
                self._categories = categories
                self.categories.next(.some(categories))

                if let currentObservable = self.currentCategoryObservable {
                    if let observedCategory = categories.first(where: { currentObservable.0 == $0.identifier }) {
                        currentObservable.1.next(.some(observedCategory))
                    } else {
                        currentObservable.1.next(.none(nil))
                    }
                }
            } else {
                self._categories = []
                self.categories.next(.none(error))
                self.currentCategoryObservable?.1.next(.none(error))
            }

            if let headerMessage = response?.headerMessage {
                self.headerMessage.next(headerMessage)
            }
            }.load(with: KinWebService.shared)
    }

    func loadAllTasks() {
        WebRequests.nextTasks().withCompletion { [weak self] tasks, error in
            guard let self = self else {
                return
            }

            if let tasks = tasks, tasks.isNotEmpty {
                self._tasksByCategory = tasks
            } else {
                self._tasksByCategory = [:]
            }

            if let taskObservable = self.currentTaskObservable {
                if let task = self._tasksByCategory[taskObservable.0]?.first {
                    taskObservable.1.next(.some(task))
                } else {
                    taskObservable.1.next(.none(error))
                }
            }
        }.load(with: KinWebService.shared)
    }

    func loadTasks(for categoryId: CategoryId) {
        WebRequests.tasks(for: categoryId).withCompletion { [weak self] response, error in
            guard let self = self else {
                return
            }

            if let response = response {
                self._tasksByCategory[categoryId] = response.tasks

                if
                    let index = self._categories.firstIndex(where: { $0.identifier == categoryId }),
                    self._categories[index].availableTasksCount != response.availableTasksCount {
                    var category = self._categories[index]
                    category.availableTasksCount = response.availableTasksCount
                    self._categories[index] = category

                    if self.currentCategoryObservable?.0 == categoryId {
                        self.currentCategoryObservable?.1.next(.some(category))
                    }

                    self.categories.next(.some(self._categories))
                }
            }

            if self.currentTaskObservable?.0 == categoryId {
                if let task = response?.tasks.first {
                    self.currentTaskObservable?.1.next(.some(task))
                } else {
                    self.currentTaskObservable?.1.next(.none(error))
                }
            }
        }.load(with: KinWebService.shared)
    }

    func categoryObservable(for categoryId: CategoryId) -> CategoryObservable {
        if let current = currentCategoryObservable, current.0 == categoryId {
            return current.1
        }

        let fetchResult: FetchResult<TaskCategory>

        if let category = _categories.first(where: { $0.identifier == categoryId }) {
            fetchResult = .some(category)
        } else {
            fetchResult = .none(nil)
        }

        let observable = CategoryObservable(fetchResult)
        currentCategoryObservable = (categoryId, observable)

        return observable
    }

    func taskObservable(for categoryId: CategoryId) -> TaskObservable {
        if let current = currentTaskObservable, current.0 == categoryId {
            return current.1
        }

        let fetchResult: FetchResult<Task>
        if let task = _tasksByCategory[categoryId]?.first {
            fetchResult = .some(task)
        } else {
            fetchResult = .none(nil)
        }

        let observable = TaskObservable(fetchResult)
        currentTaskObservable = (categoryId, observable)

        return observable
    }

    func releaseObservables(categoryId: CategoryId) {
        if let categoryObservable = currentCategoryObservable, categoryObservable.0 == categoryId {
            currentCategoryObservable = nil
        }

        if let taskObservable = currentTaskObservable, taskObservable.0 == categoryId {
            currentTaskObservable = nil
        }
    }

    func markTaskFinished(taskId: String, categoryId: CategoryId) {
        guard let tasks = _tasksByCategory[categoryId] else {
            return
        }

        if let index = _categories.firstIndex(where: { $0.identifier == categoryId }) {
            var category = _categories[index]
            category.availableTasksCount -= 1
            _categories[index] = category

            if currentCategoryObservable?.0 == categoryId {
                currentCategoryObservable?.1.next(.some(category))
            }

            categories.next(.some(_categories))
        }

        let tasksRemovingThis = tasks.filter { $0.identifier != taskId }
        _tasksByCategory[categoryId] = tasksRemovingThis

        if currentTaskObservable?.0 == categoryId {
            if let task = tasksRemovingThis.first {
                currentTaskObservable?.1.next(.some(task))
            } else {
                currentTaskObservable?.1.next(.none(nil))
            }
        }
    }
}
