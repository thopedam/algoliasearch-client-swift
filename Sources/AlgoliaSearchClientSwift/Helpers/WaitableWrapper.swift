//
//  TaskWaitWrapper.swift
//  
//
//  Created by Vladislav Fitc on 16/04/2020.
//

import Foundation

public struct WaitableWrapper<T> {

  public let wrapped: T
  let waitService: WaitService

  init(wrapped: T, waitService: WaitService) {
    self.wrapped = wrapped
    self.waitService = waitService
  }

}

extension WaitableWrapper where T: Task {
  
  public var task: T {
    return wrapped
  }
  
  init(task: T, index: Index) {
    self.wrapped = task
    self.waitService = .init(index: index, task: task)
  }
  
  static func wrap(with index: Index) -> (T) -> WaitableWrapper<T> {
    return { task in
      return WaitableWrapper(task: task, index: index)
    }
  }
  
}

extension WaitableWrapper where T == BatchesResponse {
  
  public var batchesResponse: BatchesResponse {
    return wrapped
  }
  
  init(batchesResponse: T, client: Client) {
    self.wrapped = batchesResponse
    self.waitService = .init(client: client, taskIndex: batchesResponse.tasks)
  }
  
  init(batchesResponse: T, index: Index) {
    self.wrapped = batchesResponse
    let taskIndices = batchesResponse.tasks.map { (index, $0.taskID) }
    self.waitService = .init(taskIndices: taskIndices)
  }
  
}

extension WaitableWrapper: AnyWaitable {

  public func wait(timeout: TimeInterval? = nil) throws {
    try waitService.wait(timeout: timeout)
  }

  public func wait(timeout: TimeInterval? = nil, completion: @escaping (Result<Empty, Swift.Error>) -> Void) {
    waitService.wait(timeout: timeout, completion: completion)
  }

}