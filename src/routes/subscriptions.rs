use actix_web::{web, HttpResponse};

pub async fn subscribe(form: web::Form<FormData>) -> HttpResponse {
    HttpResponse::Ok().finish()
}
#[derive(serde::Deserialize)]
pub struct FormData {
    name: String,
    email: String,
}
