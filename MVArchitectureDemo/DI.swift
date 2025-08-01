import DIC
import HTTIES
import Foundation

#if DEBUG
nonisolated(unsafe) var DI: ImmutableDependencyInjectionContainer = {
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
	}
	return builder.build()
}()
#else
let DI = DICBuilder()
	.registerSingleton(ServerEnvironment.production)
	.registerSingleton(
		HTTPClientImpl(httpDataRequestHandler: URLSession(configuration: .default)),
		as: HTTPClient.self
	)
	.build()
#endif

extension ImmutableDependencyInjectionContainer: @unchecked @retroactive Sendable {}
