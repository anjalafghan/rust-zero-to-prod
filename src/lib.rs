use actix_web::dev::Server;
use actix_web::{web, App, HttpResponse, HttpServer};
use std::net::TcpListener;
pub mod configuration;
pub mod routes;
pub mod startup;
async fn health_check() -> HttpResponse {
    HttpResponse::Ok().finish()
}

async fn subscribe(form: web::Form<FormData>) -> HttpResponse {
    HttpResponse::Ok().finish()
}
#[derive(serde::Deserialize)]
struct FormData {
    name: String,
    email: String,
}
