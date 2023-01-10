import Combine

class ProcessViewProvider: ProcessViewProviderType {
    @Published var processViewStatus: Bool = false
    
    private init() {}

    init(_ provider: ProgressViewProvider) {
        provider.$progressStatus
            .map { $0 == .start }
            .assertNoFailure()
            .assign(to: &$processViewStatus)
    }
    
    init(
        _ provider1: ProgressViewProvider,
        _ provider2: ProgressViewProvider
    ) {
        Publishers.CombineLatest(
            provider1.$progressStatus,
            provider2.$progressStatus
        )
        .map { $0.0 == .start || $0.1 == .start }
        .assertNoFailure()
        .assign(to: &$processViewStatus)
    }
    
    init(
        _ provider1: ProgressViewProvider,
        _ provider2: ProgressViewProvider,
        _ provider3: ProgressViewProvider
    ) {
        Publishers.CombineLatest3(
            provider1.$progressStatus,
            provider2.$progressStatus,
            provider3.$progressStatus
        )
        .map { $0.0 == .start || $0.1 == .start || $0.2 == .start }
        .assertNoFailure()
        .assign(to: &$processViewStatus)
    }

    init(
        _ provider1: ProgressViewProvider,
        _ provider2: ProgressViewProvider,
        _ provider3: ProgressViewProvider,
        _ provider4: ProgressViewProvider
    ) {
        Publishers.CombineLatest4(
            provider1.$progressStatus,
            provider2.$progressStatus,
            provider3.$progressStatus,
            provider4.$progressStatus
        )
        .map { $0.0 == .start || $0.1 == .start || $0.2 == .start || $0.3 == .start }
        .assertNoFailure()
        .assign(to: &$processViewStatus)
    }
}
extension ProcessViewProvider {
    static let shared = ProcessViewProvider()
}
