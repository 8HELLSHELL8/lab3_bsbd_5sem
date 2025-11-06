


CREATE TABLE ref.segment (
    segment_id   INTEGER PRIMARY KEY,
    segment_name TEXT NOT NULL UNIQUE,
    segment_info TEXT
);


ALTER TABLE app.account ADD COLUMN segment_id INTEGER NOT NULL REFERENCES ref.segment(segment_id);
ALTER TABLE app.access_point ADD COLUMN segment_id INTEGER NOT NULL REFERENCES ref.segment(segment_id);
ALTER TABLE app.card ADD COLUMN segment_id INTEGER NOT NULL REFERENCES ref.segment(segment_id);
ALTER TABLE app.access_right ADD COLUMN segment_id INTEGER NOT NULL REFERENCES ref.segment(segment_id);
ALTER TABLE app.access_event ADD COLUMN segment_id INTEGER NOT NULL REFERENCES ref.segment(segment_id);
ALTER TABLE ref.person ADD COLUMN segment_id INTEGER NOT NULL REFERENCES ref.segment(segment_id);
ALTER TABLE ref.locations ADD COLUMN segment_id INTEGER NOT NULL REFERENCES ref.segment(segment_id);

CREATE INDEX ON app.account (segment_id);
CREATE INDEX ON app.access_point (segment_id);
CREATE INDEX ON app.card (segment_id);
CREATE INDEX ON app.access_right (segment_id);
CREATE INDEX ON app.access_event (segment_id);
CREATE INDEX ON ref.person (segment_id);
CREATE INDEX ON ref.locations (segment_id);

ALTER TABLE app.account ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.access_point ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.card ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.access_right ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.access_event ENABLE ROW LEVEL SECURITY;
ALTER TABLE ref.person ENABLE ROW LEVEL SECURITY;
ALTER TABLE ref.locations ENABLE ROW LEVEL SECURITY;

CREATE TABLE ref.user_segment (
    role_name   TEXT NOT NULL,
    segment_id  INTEGER NOT NULL REFERENCES ref.segment(segment_id),
    PRIMARY KEY (role_name, segment_id) 
);


CREATE OR REPLACE FUNCTION app.set_session_ctx()
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    user_segment_id INTEGER;
    current_user_name TEXT;
BEGIN
    current_user_name := current_user;
    
    RAISE NOTICE 'Setting context for user: %', current_user_name;

    SELECT us.segment_id
    INTO user_segment_id
    FROM ref.user_segment us
    WHERE us.role_name = current_user_name;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Role "%" is not mapped to any segment.', current_user_name;
    END IF;

    PERFORM set_config('app.segment_id', user_segment_id::text, false);
    
    RETURN 'Session context set: segment_id = ' || user_segment_id;
END;
$$;

CREATE ROLE user_lejena LOGIN PASSWORD '123';
CREATE ROLE user_frunze LOGIN PASSWORD '123';
CREATE ROLE user_bb LOGIN PASSWORD '123';
CREATE ROLE user_city LOGIN PASSWORD '123';
GRANT user_reader, user_writer TO user_lejena, user_frunze, user_bb, user_city;
GRANT CONNECT ON DATABASE laba_3 TO user_lejena, user_frunze, user_bb, user_city;
GRANT EXECUTE ON FUNCTION app.set_session_ctx() TO user_lejena, user_frunze, user_bb, user_auditor, user_owner;
GRANT SELECT ON ref.user_segment TO user_auditor;
ALTER ROLE user_security WITH BYPASSRLS;

-- Политики для таблицы app.account

CREATE POLICY account_select_policy ON app.account FOR SELECT
    USING (current_user = 'user_auditor' OR segment_id = current_setting('app.segment_id')::INTEGER);
CREATE POLICY account_insert_policy ON app.account FOR INSERT
    WITH CHECK (segment_id = current_setting('app.segment_id')::INTEGER);
CREATE POLICY account_update_policy ON app.account FOR UPDATE
    USING (segment_id = current_setting('app.segment_id')::INTEGER)
    WITH CHECK (segment_id = current_setting('app.segment_id')::INTEGER);
CREATE POLICY account_delete_policy ON app.account FOR DELETE
    USING (segment_id = current_setting('app.segment_id')::INTEGER);

-- Политики для таблицы app.access_point

CREATE POLICY access_point_select_policy ON app.access_point FOR SELECT
    USING (current_user = 'user_auditor' OR segment_id = current_setting('app.segment_id')::INTEGER);
CREATE POLICY access_point_insert_policy ON app.access_point FOR INSERT
    WITH CHECK (segment_id = current_setting('app.segment_id')::INTEGER);
CREATE POLICY access_point_update_policy ON app.access_point FOR UPDATE
    USING (segment_id = current_setting('app.segment_id')::INTEGER)
    WITH CHECK (segment_id = current_setting('app.segment_id')::INTEGER);
CREATE POLICY access_point_delete_policy ON app.access_point FOR DELETE
    USING (segment_id = current_setting('app.segment_id')::INTEGER);

-- Политики для таблицы app.card

CREATE POLICY card_select_policy ON app.card FOR SELECT
    USING (current_user = 'user_auditor' OR segment_id = current_setting('app.segment_id')::INTEGER);
CREATE POLICY card_insert_policy ON app.card FOR INSERT
    WITH CHECK (segment_id = current_setting('app.segment_id')::INTEGER);
CREATE POLICY card_update_policy ON app.card FOR UPDATE
    USING (segment_id = current_setting('app.segment_id')::INTEGER)
    WITH CHECK (segment_id = current_setting('app.segment_id')::INTEGER);
CREATE POLICY card_delete_policy ON app.card FOR DELETE
    USING (segment_id = current_setting('app.segment_id')::INTEGER);

-- Политики для таблицы app.access_right

CREATE POLICY access_right_select_policy ON app.access_right FOR SELECT
    USING (current_user = 'user_auditor' OR segment_id = current_setting('app.segment_id')::INTEGER);
CREATE POLICY access_right_insert_policy ON app.access_right FOR INSERT
    WITH CHECK (segment_id = current_setting('app.segment_id')::INTEGER);
CREATE POLICY access_right_update_policy ON app.access_right FOR UPDATE
    USING (segment_id = current_setting('app.segment_id')::INTEGER)
    WITH CHECK (segment_id = current_setting('app.segment_id')::INTEGER);
CREATE POLICY access_right_delete_policy ON app.access_right FOR DELETE
    USING (segment_id = current_setting('app.segment_id')::INTEGER);

-- Политики для таблицы app.access_event

CREATE POLICY access_event_select_policy ON app.access_event FOR SELECT
    USING (current_user = 'user_auditor' OR segment_id = current_setting('app.segment_id')::INTEGER);
CREATE POLICY access_event_insert_policy ON app.access_event FOR INSERT
    WITH CHECK (segment_id = current_setting('app.segment_id')::INTEGER);
CREATE POLICY access_event_update_policy ON app.access_event FOR UPDATE
    USING (segment_id = current_setting('app.segment_id')::INTEGER)
    WITH CHECK (segment_id = current_setting('app.segment_id')::INTEGER);
CREATE POLICY access_event_delete_policy ON app.access_event FOR DELETE
    USING (segment_id = current_setting('app.segment_id')::INTEGER);

-- Политики для таблицы ref.person

CREATE POLICY person_select_policy ON ref.person FOR SELECT
    USING (current_user = 'user_auditor' OR segment_id = current_setting('app.segment_id')::INTEGER);
CREATE POLICY person_insert_policy ON ref.person FOR INSERT
    WITH CHECK (segment_id = current_setting('app.segment_id')::INTEGER);
CREATE POLICY person_update_policy ON ref.person FOR UPDATE
    USING (segment_id = current_setting('app.segment_id')::INTEGER)
    WITH CHECK (segment_id = current_setting('app.segment_id')::INTEGER);
CREATE POLICY person_delete_policy ON ref.person FOR DELETE
    USING (segment_id = current_setting('app.segment_id')::INTEGER);

-- Политики для таблицы ref.locations

CREATE POLICY locations_select_policy ON ref.locations FOR SELECT
    USING (current_user = 'user_auditor' OR segment_id = current_setting('app.segment_id')::INTEGER);
CREATE POLICY locations_insert_policy ON ref.locations FOR INSERT
    WITH CHECK (segment_id = current_setting('app.segment_id')::INTEGER);
CREATE POLICY locations_update_policy ON ref.locations FOR UPDATE
    USING (segment_id = current_setting('app.segment_id')::INTEGER)
    WITH CHECK (segment_id = current_setting('app.segment_id')::INTEGER);
CREATE POLICY locations_delete_policy ON ref.locations FOR DELETE
    USING (segment_id = current_setting('app.segment_id')::INTEGER);




