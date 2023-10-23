import Combine

extension Publisher {

    public func logErrorIfNoOutput<S: Scheduler>(
        id: String = #function,
        in timeInterval: S.SchedulerTimeType.Stride = .seconds(10),
        scheduler: S = DispatchQueue.main,
        app: AppProtocol = runningApp,
        file: String = #fileID,
        line: Int = #line
    ) -> AnyPublisher<Output, Failure> {
        let seen: CurrentValueSubject<Bool, Never> = .init(false)
        let noOutputPublisher = Just(())
            .delay(for: timeInterval, scheduler: scheduler)
            .filter { !seen.value }
            .handleEvents(
                receiveOutput: { _ in app.post(error: "☠️ \(id): Error! No output received", file: file, line: line) }
            )
            .flatMap { _ in
                Empty(completeImmediately: false, outputType: Output.self, failureType: Failure.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        return handleEvents(receiveOutput: { _ in seen.send(true) })
            .merge(with: noOutputPublisher)
            .eraseToAnyPublisher()
    }
}
