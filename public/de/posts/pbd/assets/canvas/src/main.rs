use macroquad::prelude::*;

mod draw;
mod pbd;

use draw::SCHEME;

#[macroquad::main("PBD")]
async fn main() {
    //let font = load_ttf_font("assets/JetBrainsMono-Regular.ttf").await;

    let mut sim = pbd::Sim::default();

    sim.env.width = screen_width() as i32;
    sim.env.height = screen_height() as i32;

    sim.insert(pbd::Ball::new(
        Vec2::new(sim.env.width as f32 * 0.5, sim.env.height as f32 * 0.2),
        Vec2::new(0.0, 0.0),
        0.0,
        0.0,
    ));

    sim.insert(pbd::Ball::new(
        Vec2::new(sim.env.width as f32 * 0.4, sim.env.height as f32 * 0.5),
        Vec2::new(0.0, 0.0),
        10.0,
        0.0,
    ));

    sim.connect(0, 1, None);

    sim.insert(pbd::Ball::new(
        Vec2::new(
            sim.env.width as f32 * 0.4 + 50.0,
            sim.env.height as f32 * 0.5,
        ),
        Vec2::new(0.0, 0.0),
        10.0,
        0.0,
    ));

    sim.insert(pbd::Ball::new(
        Vec2::new(
            sim.env.width as f32 * 0.4,
            sim.env.height as f32 * 0.5 + 50.0,
        ),
        Vec2::new(0.0, 0.0),
        10.0,
        0.0,
    ));

    sim.insert(pbd::Ball::new(
        Vec2::new(
            sim.env.width as f32 * 0.4 + 50.0,
            sim.env.height as f32 * 0.5 + 50.0,
        ),
        Vec2::new(0.0, 0.0),
        10.0,
        0.0,
    ));

    sim.connect(1, 2, None);
    sim.connect(2, 3, None);
    sim.connect(3, 4, None);
    sim.connect(2, 4, None);
    sim.connect(1, 3, None);
    sim.connect(1, 4, None);

    loop {
        /* sim.env.width = screen_width() as i32;
        sim.env.height = screen_height() as i32;

        if is_mouse_button_pressed(MouseButton::Left) {
            let mouse = mouse_position();
            sim.insert(pbd::Ball::new(
                Vec2::new(mouse.0, mouse.1),
                Vec2::new(0.0, 0.0),
                10.0,
                0.0,
            ));
        } */

        sim.step();

        clear_background(*SCHEME.get("back").unwrap());

        sim.draw();

        draw_text(
            &get_fps().to_string(),
            20.0,
            10.0,
            24.0,
            *SCHEME.get("text").unwrap(),
        );

        /* draw_text_ex(
            &get_fps().to_string(),
            20.0,
            10.0,
            TextParams {
                font: font,
                font_size: 48,
                font_scale: 0.4,
                color: *SCHEME.get("text").unwrap(),
            },
        ); */

        next_frame().await
    }
}
