# MVArchitectureDemoApp

Model View architecture demo app.

1. Views use models.
2. Models can update themselves or can be used as a Repository too for requests about it.
3. Thin network layer with mock support for Previews.
4. WireMock jar for localhost deploy of fake server.
5. Simple unit test that can reuse the fake server requests or use custom data using Config.httpClient.setMock(...).

Instructions:
1. Duplicate Config.xcconfig.sample and rename it Config.xcconfig with the correct information.
2. Run the local mock server by running the start.sh script inside "server-mock".
