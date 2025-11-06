
-- ========== 0. Отключаем PUBLIC-доступ ==========
REVOKE ALL ON DATABASE laba_3 FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM PUBLIC;

-- ========== 1. Создание функциональных ролей ==========
CREATE ROLE app_reader NOLOGIN;
CREATE ROLE app_writer NOLOGIN;
CREATE ROLE app_owner NOLOGIN;
CREATE ROLE auditor NOLOGIN;

-- ========== 2. Роли разделения обязанностей ==========
CREATE ROLE ddl_admin NOLOGIN;
CREATE ROLE dml_admin NOLOGIN;
CREATE ROLE security_admin NOLOGIN;

-- ========== 3. Привилегии на схемы ==========
-- Доступ к схемам
GRANT USAGE ON SCHEMA app, ref TO app_reader;
GRANT USAGE ON SCHEMA app TO app_writer;
GRANT USAGE ON SCHEMA audit, app, ref TO auditor;

-- Привилегии для app_reader
GRANT SELECT ON ALL TABLES IN SCHEMA app, ref TO app_reader;

-- Привилегии для app_writer
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA app TO app_writer;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA app, ref, stg TO app_writer;

-- Привилегии для app_owner
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA app, ref, stg TO app_owner;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA app, ref, stg TO app_owner;
GRANT ALL ON SCHEMA app, ref, stg TO app_owner;

-- Привилегии для ddl_admin (DDL операции)
GRANT CREATE, USAGE ON SCHEMA app, ref, stg TO ddl_admin;

-- Привилегии для dml_admin (работа с данными)
GRANT USAGE ON SCHEMA app, ref, stg TO dml_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA app, ref, stg TO dml_admin;

-- Привилегии для auditor
GRANT SELECT ON ALL TABLES IN SCHEMA audit, app, ref TO auditor;

-- Ограничение audit
REVOKE INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA audit FROM PUBLIC;
REVOKE INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA audit FROM app_writer, app_owner;



-- ========== Default privileges =========
ALTER DEFAULT PRIVILEGES IN SCHEMA app, ref, stg
GRANT SELECT ON TABLES TO app_reader;

ALTER DEFAULT PRIVILEGES IN SCHEMA app, ref, stg
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_writer;

ALTER DEFAULT PRIVILEGES IN SCHEMA app, ref, stg
GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO dml_admin;

GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA app, ref, stg TO dml_admin;

ALTER DEFAULT PRIVILEGES IN SCHEMA app, ref, stg
GRANT ALL ON TABLES TO app_owner;

ALTER DEFAULT PRIVILEGES IN SCHEMA app, ref, stg
GRANT USAGE ON SEQUENCES TO app_writer;



-- ========== Тестовые пользователи ==========
REVOKE EXECUTE ON FUNCTION app.issue_card_for_account, app.grant_access_to_point, app.log_access_attempt FROM app_reader;
CREATE ROLE user_reader LOGIN PASSWORD 'reader123';
GRANT app_reader TO user_reader;


CREATE ROLE user_writer LOGIN PASSWORD 'writer123';
GRANT app_writer TO user_writer;

CREATE ROLE user_auditor LOGIN PASSWORD 'audit123';
GRANT auditor TO user_auditor;

CREATE ROLE user_owner LOGIN PASSWORD 'owner123';
GRANT app_owner TO user_owner;

GRANT ddl_admin TO security_admin;
GRANT dml_admin TO security_admin;
GRANT app_owner TO security_admin;
CREATE ROLE user_security LOGIN PASSWORD 'security123';
GRANT security_admin TO user_security;

CREATE ROLE user_dml LOGIN PASSWORD 'dml';
GRANT dml_admin TO user_dml;

CREATE ROLE user_ddl LOGIN PASSWORD 'ddl';
GRANT ddl_admin TO user_ddl;

GRANT CONNECT ON DATABASE laba_3 TO user_reader;
GRANT CONNECT ON DATABASE laba_3 TO user_owner;
GRANT CONNECT ON DATABASE laba_3 TO user_writer;
GRANT CONNECT ON DATABASE laba_3 TO user_auditor;
GRANT CONNECT ON DATABASE laba_3 TO user_security;
GRANT CONNECT ON DATABASE laba_3 TO user_dml;
GRANT CONNECT ON DATABASE laba_3 TO user_ddl;

-- Предоставить права на выполнение
GRANT EXECUTE ON FUNCTION app.issue_card_for_account TO app_writer;
GRANT EXECUTE ON FUNCTION app.grant_access_to_point TO app_writer;
GRANT EXECUTE ON FUNCTION app.log_access_attempt TO app_writer;

-- Также для dml_admin, если нужно
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA app TO dml_admin;
