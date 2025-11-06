
-- ========== ref schema ==========
CREATE TABLE ref.person(
    person_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(60) NOT NULL,
    surname VARCHAR(60) NOT NULL,
    last_name VARCHAR(60),
    birthday DATE NOT NULL,
    gender CHAR(1) NOT NULL CHECK (gender IN ('M','F')),
    national_id VARCHAR(20) UNIQUE,
    phone VARCHAR(20) UNIQUE
);


CREATE TABLE ref.locations(
    location_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE ref.auth_method(
    method_id SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    description TEXT
);

CREATE TABLE ref.role(
    role_id SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    description TEXT
);

CREATE TABLE ref.status(
    status_id SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    description TEXT
);


-- ========== app schema ==========
CREATE TABLE app.account(
    account_id BIGSERIAL PRIMARY KEY,
    username VARCHAR(30) NOT NULL UNIQUE,
    password TEXT NOT NULL,
    role INT REFERENCES ref.role(role_id),
    person_id BIGINT REFERENCES ref.person(person_id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE app.access_point(
    ap_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    location BIGINT REFERENCES ref.locations(location_id) ON DELETE CASCADE,
    is_active BOOLEAN CHECK(is_active IN ('true','false')) DEFAULT true,
    description TEXT
);

CREATE TABLE app.card (
    card_id    BIGSERIAL PRIMARY KEY,
    card_number TEXT NOT NULL UNIQUE,
    account_id BIGINT REFERENCES app.account(account_id) ON DELETE CASCADE,
    issued_at  TIMESTAMPTZ DEFAULT now(),
    disabled   BOOLEAN DEFAULT false
);

CREATE TABLE app.access_right (
  access_right_id BIGSERIAL PRIMARY KEY,
  person_id       BIGINT REFERENCES ref.person(person_id) ON DELETE CASCADE,
  ap_id           BIGINT REFERENCES app.access_point(ap_id) ON DELETE CASCADE,
  valid_from      TIMESTAMPTZ NOT NULL DEFAULT now(),
  valid_to        TIMESTAMPTZ,
  CHECK (valid_to IS NULL OR valid_to > valid_from)
);

CREATE TABLE app.access_event (
  event_id    BIGSERIAL PRIMARY KEY,
  person_id   BIGINT REFERENCES ref.person(person_id) ON DELETE SET NULL,
  account_id  BIGINT REFERENCES app.account(account_id) ON DELETE SET NULL,
  ap_id       BIGINT REFERENCES app.access_point(ap_id) ON DELETE SET NULL,
  event_time  TIMESTAMPTZ NOT NULL DEFAULT now(),
  method      INT REFERENCES ref.auth_method(method_id) NOT NULL,
  result      INT REFERENCES ref.status(status_id) NOT NULL,
  detail      TEXT
);






-- ========== audit schema ==========
CREATE TABLE IF NOT EXISTS audit.login_log( 
    id	BIGSERIAL PRIMARY KEY,
    login_time TIMESTAMPTZ NOT NULL DEFAULT now(), 
    username	TEXT NOT NULL,
    client_ip	INET
);

CREATE TABLE IF NOT EXISTS audit.function_calls (
    id BIGSERIAL PRIMARY KEY,
    call_time TIMESTAMPTZ DEFAULT now(),
    function_name TEXT NOT NULL,
    caller_role TEXT NOT NULL,
    input_params TEXT,
    success BOOLEAN NOT NULL,
    error_message TEXT
);



-- ========== stg schema ==========
CREATE TABLE stg.person_load(
    row_id   BIGSERIAL PRIMARY KEY,
    payload  TEXT,
    loaded_at TIMESTAMPTZ DEFAULT now()
);