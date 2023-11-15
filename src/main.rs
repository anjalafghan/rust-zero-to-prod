use newsletter::run;
use std::net::TcpListener;
#[tokio::main]
async fn main() -> std::io::Result<()> {
    let listener = TcpListener::bind("127.0.0.1:0").expect("error setting up listener");
    run(listener)?.await
}
