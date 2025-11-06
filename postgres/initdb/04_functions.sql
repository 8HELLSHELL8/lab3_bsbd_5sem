------------------------------------------------- логирование входа
CREATE OR REPLACE FUNCTION audit.log_user_login() 
RETURNS event_trigger AS
$$ 
BEGIN
    INSERT INTO audit.login_log (username, client_ip) 
    VALUES (session_user, inet_client_addr());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


CREATE EVENT TRIGGER audit_user_login_trigger ON login
EXECUTE FUNCTION audit.log_user_login();
ALTER EVENT TRIGGER audit_user_login_trigger ENABLE ALWAYS;



------------------------------------------------- выпуск карты доступа одних из пользователей
CREATE OR REPLACE FUNCTION app.issue_card_for_account(
    p_account_id BIGINT,
    p_card_number TEXT
)
RETURNS BIGINT
SECURITY DEFINER
SET search_path = app, ref, audit, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    v_card_id BIGINT;
    v_is_active BOOLEAN;
    params TEXT; 
BEGIN

    --создание объекта
    params := jsonb_build_object('account_id', p_account_id, 'card_number', p_card_number)::TEXT;

    --проверка наличия аккаунта и его активного статуса
    SELECT is_active INTO v_is_active
    FROM app.account
    WHERE account_id = p_account_id;

    IF NOT FOUND THEN
        INSERT INTO audit.function_calls (function_name, caller_role, input_params, success, error_message)
        VALUES ('issue_card_for_account', current_user, params, false, 'Account not found');
        RAISE EXCEPTION 'Account % not found', p_account_id;
    END IF;

    IF NOT v_is_active THEN
        INSERT INTO audit.function_calls (function_name, caller_role, input_params, success, error_message)
        VALUES ('issue_card_for_account', current_user, params, false, 'Account is inactive');
        RAISE EXCEPTION 'Account % is inactive', p_account_id;
    END IF;

    --проверка уникальности номера карты
    IF EXISTS (SELECT 1 FROM app.card WHERE card_number = p_card_number) THEN
        INSERT INTO audit.function_calls (function_name, caller_role, input_params, success, error_message)
        VALUES ('issue_card_for_account', current_user, params, false, 'Card number already exists');
        RAISE EXCEPTION 'Card number "%" already exists', p_card_number;
    END IF;

    INSERT INTO app.card (card_number, account_id)
    VALUES (p_card_number, p_account_id)
    RETURNING card_id INTO v_card_id;

    INSERT INTO audit.function_calls (function_name, caller_role, input_params, success)
    VALUES ('issue_card_for_account', current_user, params, true);

    RETURN v_card_id;

EXCEPTION WHEN OTHERS THEN
    INSERT INTO audit.function_calls (function_name, caller_role, input_params, success, error_message)
    VALUES ('issue_card_for_account', current_user, params, false, SQLERRM);
    RAISE;
END;
$$;







--------------назначение права доступа к конкретной точке на определенный период
CREATE OR REPLACE FUNCTION app.grant_access_to_point(
    p_person_id BIGINT,
    p_ap_id BIGINT,
    p_valid_from TIMESTAMPTZ,
    p_valid_to TIMESTAMPTZ DEFAULT NULL
)
RETURNS BIGINT
SECURITY DEFINER
SET search_path = app, ref, audit, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    v_right_id BIGINT;
    v_person_exists BOOLEAN;
    v_ap_active BOOLEAN;
    params TEXT;
BEGIN
    params := jsonb_build_object(
        'person_id', p_person_id,
        'ap_id', p_ap_id,
        'valid_from', p_valid_from,
        'valid_to', p_valid_to
    )::TEXT;

    --проверка существования человека
    SELECT EXISTS (SELECT 1 FROM ref.person WHERE person_id = p_person_id)
    INTO v_person_exists;
    IF NOT v_person_exists THEN
        INSERT INTO audit.function_calls (function_name, caller_role, input_params, success, error_message)
        VALUES ('grant_access_to_point', current_user, params, false, 'Person not found');
        RAISE EXCEPTION 'Person with ID % not found', p_person_id;
    END IF;

    --проверка активности точки доступа
    SELECT is_active INTO v_ap_active
    FROM app.access_point
    WHERE ap_id = p_ap_id;

    IF NOT FOUND THEN
        INSERT INTO audit.function_calls (function_name, caller_role, input_params, success, error_message)
        VALUES ('grant_access_to_point', current_user, params, false, 'Access point not found');
        RAISE EXCEPTION 'Access point % not found', p_ap_id;
    END IF;

    IF NOT v_ap_active THEN
        INSERT INTO audit.function_calls (function_name, caller_role, input_params, success, error_message)
        VALUES ('grant_access_to_point', current_user, params, false, 'Access point is inactive');
        RAISE EXCEPTION 'Access point % is inactive', p_ap_id;
    END IF;

    --проверка валидности дат
    IF p_valid_to IS NOT NULL AND p_valid_to <= p_valid_from THEN
        INSERT INTO audit.function_calls (function_name, caller_role, input_params, success, error_message)
        VALUES ('grant_access_to_point', current_user, params, false, 'valid_to must be > valid_from');
        RAISE EXCEPTION 'valid_to must be greater than valid_from';
    END IF;

    INSERT INTO app.access_right (person_id, ap_id, valid_from, valid_to)
    VALUES (p_person_id, p_ap_id, p_valid_from, p_valid_to)
    RETURNING access_right_id INTO v_right_id;

    INSERT INTO audit.function_calls (function_name, caller_role, input_params, success)
    VALUES ('grant_access_to_point', current_user, params, true);

    RETURN v_right_id;

EXCEPTION WHEN OTHERS THEN
    INSERT INTO audit.function_calls (function_name, caller_role, input_params, success, error_message)
    VALUES ('grant_access_to_point', current_user, params, false, SQLERRM);
    RAISE;
END;
$$;





-------------------------------------------------логирование попытки доступа к точке
CREATE OR REPLACE FUNCTION app.log_access_attempt(
    p_person_id BIGINT,
    p_ap_id BIGINT,
    p_method_id INT,
    p_result_id INT DEFAULT NULL,
    p_detail TEXT DEFAULT NULL
)
RETURNS BIGINT
SECURITY DEFINER
SET search_path = app, ref, audit, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    v_event_id BIGINT;
    v_account_id BIGINT;
    v_has_valid_access BOOLEAN;
    v_auto_result_id INT;
    v_method_exists BOOLEAN;
    v_status_granted_id INT := (SELECT status_id FROM ref.status WHERE name = 'GRANTED');
    v_status_denied_id INT := (SELECT status_id FROM ref.status WHERE name = 'DENIED');
    params TEXT; 
BEGIN

    params := jsonb_build_object(
        'person_id', p_person_id,
        'ap_id', p_ap_id,
        'method_id', p_method_id,
        'result_id', p_result_id,
        'detail', p_detail
    )::TEXT;

    --проверка метода аутентификации
    SELECT EXISTS (SELECT 1 FROM ref.auth_method WHERE method_id = p_method_id)
    INTO v_method_exists;
    IF NOT v_method_exists THEN
        INSERT INTO audit.function_calls (function_name, caller_role, input_params, success, error_message)
        VALUES ('log_access_attempt', current_user, params, false, 'Invalid auth method');
        RAISE EXCEPTION 'Authentication method % not found', p_method_id;
    END IF;

    --поиск account_id по person_id
    SELECT account_id INTO v_account_id
    FROM app.account
    WHERE person_id = p_person_id AND is_active = true
    LIMIT 1;

    --проверка наличия актуального права доступа
    SELECT EXISTS (
        SELECT 1
        FROM app.access_right ar
        WHERE ar.person_id = p_person_id
          AND ar.ap_id = p_ap_id
          AND ar.valid_from <= NOW()
          AND (ar.valid_to IS NULL OR ar.valid_to >= NOW())
    ) INTO v_has_valid_access;

    --автоматическое определение результата
    IF p_result_id IS NULL THEN
        v_auto_result_id := CASE
            WHEN v_has_valid_access THEN v_status_granted_id
            ELSE v_status_denied_id
        END;
    ELSE
        v_auto_result_id := p_result_id;
    END IF;

    --вставка события доступа
    INSERT INTO app.access_event (
        person_id, account_id, ap_id, event_time, method, result, detail
    ) VALUES (
        p_person_id,
        v_account_id,
        p_ap_id,
        NOW(),
        p_method_id,
        v_auto_result_id,
        COALESCE(p_detail, CASE
            WHEN v_has_valid_access THEN 'Access granted'
            ELSE 'Access denied: no valid access right'
        END)
    )
    RETURNING event_id INTO v_event_id;

    INSERT INTO audit.function_calls (function_name, caller_role, input_params, success)
    VALUES ('log_access_attempt', current_user, params, true);

    RETURN v_event_id;

EXCEPTION WHEN OTHERS THEN
    INSERT INTO audit.function_calls (function_name, caller_role, input_params, success, error_message)
    VALUES ('log_access_attempt', current_user, params, false, SQLERRM);
    RAISE;
END;
$$;



-------------------------------------------------проверка активности точки
CREATE OR REPLACE FUNCTION app.trg_check_access_point_active()
RETURNS TRIGGER
SET search_path = app, pg_temp
LANGUAGE plpgsql
AS $$
DECLARE
    v_is_active BOOLEAN;
BEGIN
    SELECT is_active INTO v_is_active
    FROM app.access_point
    WHERE ap_id = NEW.ap_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Access point % does not exist', NEW.ap_id;
    END IF;

    IF NOT v_is_active THEN
        RAISE EXCEPTION 'Cannot grant access to inactive access point %', NEW.ap_id;
    END IF;

    RETURN NEW;
END;
$$;

-- Триггер
CREATE TRIGGER trg_access_right_check_ap_active
BEFORE INSERT OR UPDATE ON app.access_right
FOR EACH ROW
EXECUTE FUNCTION app.trg_check_access_point_active();