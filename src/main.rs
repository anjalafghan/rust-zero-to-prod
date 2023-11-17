use newsletter::configuration::get_configuration;
use newsletter::startup::run;
use sqlx::{Connection, PgConnection};
use std::net::TcpListener;

#[tokio::main]
async fn main() -> std::io::Result<()> {
    let configuration = get_configuration().expect("Error getting config");
    let address = format!("127.0.0.1:{}", configuration.application_port);
    let listener = TcpListener::bind(address)?;
    let connection = PgConnection::connect(&configuration.database.connection_string())
        .await
        .expect("Error connecting to postgres");
    run(listener, connection)?.await
}
