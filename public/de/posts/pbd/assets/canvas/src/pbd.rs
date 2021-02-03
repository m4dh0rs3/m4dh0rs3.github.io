use macroquad::math::Vec2;

pub(crate) struct Sim {
    pub(crate) balls: Vec<Ball>,
    pub(crate) sticks: Vec<Stick>,

    pub(crate) speed: u8,
    pub(crate) resolve: u8,

    pub(crate) env: Env,
}

pub(crate) struct Env {
    pub(crate) dt: f32,

    pub(crate) g: f32,
    pub(crate) air: f32,

    pub(crate) width: i32,
    pub(crate) height: i32,
}

#[derive(Clone)]
pub(crate) struct Ball {
    pub(crate) pos: Vec2,
    vel: Vec2,
    prv: Vec2,

    pub(crate) mass: f32,
    inv: f32,

    ely: f32,
}

#[derive(Clone)]
pub(crate) struct Stick {
    pub(crate) i: usize,
    pub(crate) j: usize,

    len: f32,
    sfn: f32,
}

impl Ball {
    pub(crate) fn new(pos: Vec2, vel: Vec2, mass: f32, dt: f32) -> Ball {
        Ball {
            pos,
            vel,
            prv: pos + vel * dt,
            mass,
            inv: if mass == 0.0 { 0.0 } else { 1.0 / mass },
            ely: 1.0,
        }
    }

    fn step(&mut self, env: &Env) {
        self.vel = (self.prv - self.pos) / env.dt;
        self.in_box(env);

        self.pos = self.prv;

        let force_g = Vec2::new(
            env.dt * self.inv * env.air,
            env.dt * self.inv * env.air * env.g,
        );

        self.vel += force_g;

        self.prv = self.pos + (self.vel * env.dt);
    }

    fn in_box(&mut self, env: &Env) {
        if self.prv.x > env.width as f32 {
            self.prv.x = env.width as f32;
            self.vel.x = -self.vel.x.abs() * self.ely
        } else if self.prv.x < 0.0 {
            self.prv.x = 0.0;
            self.vel.x = self.vel.x.abs() * self.ely
        }

        if self.prv.y > env.height as f32 {
            self.prv.y = env.height as f32;
            self.vel.y = -self.vel.y.abs() * self.ely
        } else if self.prv.y < 0.0 {
            self.prv.y = 0.0;
            self.vel.y = self.vel.y.abs() * self.ely
        }
    }
}

impl Stick {
    pub(crate) fn new(i: usize, j: usize, len: f32) -> Stick {
        Stick {
            i,
            j,
            len,
            sfn: 1.0,
        }
    }

    fn project(&self, balls: &mut Vec<Ball>) {
        let ball = (balls[self.i].clone(), balls[self.j].clone());

        if !(ball.0.inv == 0.0 && ball.1.inv == 0.0) {
            let diff: Vec2 = ball.0.prv - ball.1.prv;
            let len = diff.length();
            let off: Vec2 = (diff / len) * (len - self.len);

            balls[self.i].prv -= (off * ball.0.inv / (ball.0.inv + ball.1.inv)) * self.sfn;
            balls[self.j].prv += (off * ball.1.inv / (ball.0.inv + ball.1.inv)) * self.sfn;
        }
    }
}

impl Sim {
    fn new(speed: u8, resolve: u8, dt: f32, g: f32, air: f32, width: i32, height: i32) -> Sim {
        Sim {
            speed,
            resolve,
            env: Env::new(dt, g, air, width, height),

            ..Default::default()
        }
    }

    pub(crate) fn insert(&mut self, ball: Ball) {
        self.balls.push(ball);
    }

    pub(crate) fn connect(&mut self, i: usize, j: usize, len: Option<f32>) {
        self.sticks.push(Stick::new(
            i,
            j,
            match len {
                Some(len) => len,
                None => self
                    .balls
                    .get(i)
                    .unwrap()
                    .pos
                    .distance(self.balls.get(j).unwrap().pos),
            },
        ));
    }

    pub(crate) fn step(&mut self) {
        for w in 0..self.speed {
            for ball in self.balls.iter_mut() {
                ball.step(&self.env);
            }
        }

        for r in 0..self.resolve {
            for stick in self.sticks.iter_mut() {
                stick.project(&mut self.balls);
            }
        }
    }
}

impl Env {
    fn new(dt: f32, g: f32, air: f32, width: i32, height: i32) -> Env {
        Env {
            dt,

            g,
            air,

            width,
            height,
        }
    }
}

impl Default for Sim {
    fn default() -> Self {
        Sim {
            balls: Vec::new(),
            sticks: Vec::new(),

            speed: 1u8,
            resolve: 1u8,

            env: Env::default(),
        }
    }
}

impl Default for Env {
    fn default() -> Self {
        Env {
            dt: 0.6,

            g: 9.81,
            air: 1.0,

            width: 960,
            height: 480,
        }
    }
}
