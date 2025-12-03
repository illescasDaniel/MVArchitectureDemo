import DIC
import HTTIES
import Foundation

nonisolated enum DI {

	static func load<T>(_ type: T.Type = T.self) -> T {
		DI.container.load(type)
	}

#if DEBUG
	nonisolated(unsafe) private static var container: ImmutableDependencyInjectionContainer = {
		let builder = DICBuilder()
		if Config.isRunningUnitTests {
			// left blank on purpose, these dependencies will be registered by reassigning DI to another container in the unit tests target
		} else if Config.isSwiftUIPreviewRunning {
			let mockHTTPClient = MockHTTPClient(
				requestInterceptors: [
					NetworkDelayHTTPInterceptor()
				],
				responseInterceptors: [
					HTTPLoggerInterceptor()
				]
			)
			builder
				.registerSingleton(ServerEnvironment.localApp)
				.registerSingleton(mockHTTPClient)
				.registerSingleton(
					mockHTTPClient,
					as: HTTPClient.self
				)
				.register(JSONEncoder())
				.register(JSONDecoder())
		} else {
			builder
				.registerSingleton(ServerEnvironment.localApp)
				.registerSingleton(
					HTTPClientImpl(
						httpDataRequestHandler: URLSession(configuration: .ephemeral),
						requestInterceptors: [
							NetworkDelayHTTPInterceptor(),
						],
						responseInterceptors: [
							HTTPLoggerInterceptor(),
						]
					),
					as: HTTPClient.self
				)
				.register(JSONEncoder())
				.register(JSONDecoder())
		}
		return builder.build()
	}()
	
	static func updateContainer(_ container: ImmutableDependencyInjectionContainer) {
		DI.container = container
	}
#else
	private static let container = DICBuilder()
		.registerSingleton(ServerEnvironment.production)
		.registerSingleton(
			HTTPClientImpl(httpDataRequestHandler: URLSession(configuration: .default)),
			as: HTTPClient.self
		)
		.register(JSONEncoder())
		.register(JSONDecoder())
		.build()
#endif
}
