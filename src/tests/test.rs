use newsletter::main;

#[tokio::test]
async fn health_check_works() {
    // Arrange
    spawn_app().await.expect("Failed to spawn our app.");
    let client = reqwest::Client::new(); // We need to bring in `reqwest`
                                         // to perform HTTP requests against our application. let client = reqwest::Client::new();
    let response = client
        .get("http:127.0.0.1:8000/health-check")
        .send()
        .await
        .expect("Failed to execute app");

    assert!(response.status().is_success());
    assert_eq!(Some(0), response.content_length());
}
async fn spawn_app() -> std::io::Result<()> {
    let server = newsletter::run().expect("Failed to bind an address!");
    let _ = tokio::spawn(server);
}
