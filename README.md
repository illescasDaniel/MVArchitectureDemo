# MVArchitectureDemoApp

Model View architecture demo app.

1. Views use models.
2. Models can update themselves or can be used as a Repository too for requests about it.
3. Thin network layer with mock support for Previews.
4. WireMock jar for localhost deploy of fake server.
5. Simple unit test that can use stubs for 'fake' server requests.
6. TO DO: UI tests using the POM pattern. Page Object Model pattern: https://www.selenium.dev/documentation/test_practices/encouraged/page_object_models/ 

Instructions:
1. Duplicate “Config.xcconfig.example.xcconfig” and rename it “Config.xcconfig” with the correct information. (Don’t add it to any target)
2. Run the local mock servers by running the “start.sh script inside "mock-server”.
