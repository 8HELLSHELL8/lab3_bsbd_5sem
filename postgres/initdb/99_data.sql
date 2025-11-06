INSERT INTO ref.segment (segment_id, segment_name) VALUES
(1, 'Адриена Лежена'),
(2, 'Немировича-Данченко'),
(3, 'Депутатская'),
(4, 'Красный проспект'),
(5, 'Фрунзе'),
(6, 'Бориса-Богаткова');

INSERT INTO ref.user_segment (role_name, segment_id) VALUES
    ('user_lejena', 1),
    ('user_frunze', 5),
    ('user_bb', 6),
    ('user_city', 4), 
    ('user_auditor', 1),
    ('user_auditor', 5),
    ('user_auditor', 4),
    ('user_auditor', 6),
    ('user_security', 1),
    ('user_security', 5),
    ('user_security', 4),
    ('user_security', 6);
    

INSERT INTO ref.auth_method (method_id, name, description) VALUES
(1, 'card', 'Access via RFID card'),
(2, 'pin', 'Access via PIN code'),
(3, 'biometric', 'Access via fingerprint');

INSERT INTO ref.status (status_id, name, description) VALUES
(1, 'granted', 'Access granted successfully'),
(2, 'denied', 'Access denied'),
(3, 'expired', 'Card or access right expired');

INSERT INTO ref.role (role_id, name, description) VALUES
(1, 'admin', 'System administrator'),
(2, 'security', 'Security personnel'),
(3, 'employee', 'Regular employee'),
(4, 'manager', 'Department manager');

INSERT INTO ref.locations (name, description, segment_id) VALUES
-- Segment 1: Адриена Лежена
('Main Entrance', 'Primary building entrance', 1),
('Server Room', 'Data center and servers', 1),
('Parking Gate', 'Vehicle access control', 1),

-- Segment 5: Фрунзе  
('Research Lab', 'R&D laboratory access', 5),
('Archive Room', 'Document storage facility', 5),
('Back Entrance', 'Secondary building entrance', 5),

-- Segment 6: Бориса-Богаткова
('Production Hall', 'Manufacturing area', 6),
('Warehouse', 'Inventory storage', 6),
('Loading Dock', 'Shipping and receiving', 6),

-- Segment 4: Красный проспект (central office)
('Executive Floor', 'Management offices', 4),
('Conference Hall', 'Meeting and event space', 4),
('Main Reception', 'Visitor reception area', 4);

INSERT INTO ref.person (name, surname, last_name, birthday, gender, national_id, phone, segment_id) VALUES
-- Segment 1: Адриена Лежена
('John', 'Smith', 'Michael', '1985-03-15', 'M', 'ID123456', '+1111111111', 1),
('Sarah', 'Johnson', 'Marie', '1990-07-22', 'F', 'ID123457', '+1111111112', 1),
('Robert', 'Brown', 'James', '1982-11-30', 'M', 'ID123458', '+1111111113', 1),

-- Segment 5: Фрунзе
('Emily', 'Davis', 'Rose', '1988-05-14', 'F', 'ID123459', '+1111111114', 5),
('Michael', 'Wilson', 'Thomas', '1979-09-08', 'M', 'ID123460', '+1111111115', 5),
('Jennifer', 'Miller', 'Anne', '1993-12-03', 'F', 'ID123461', '+1111111116', 5),

-- Segment 6: Бориса-Богаткова
('David', 'Taylor', 'William', '1987-01-25', 'M', 'ID123462', '+1111111117', 6),
('Lisa', 'Anderson', 'Grace', '1991-08-19', 'F', 'ID123463', '+1111111118', 6),
('Daniel', 'Thomas', 'Robert', '1984-04-11', 'M', 'ID123464', '+1111111119', 6),

-- Segment 4: Красный проспект (central office)
('James', 'Wilson', 'Edward', '1975-06-18', 'M', 'ID123465', '+1111111120', 4),
('Maria', 'Garcia', 'Isabella', '1980-02-27', 'F', 'ID123466', '+1111111121', 4);

INSERT INTO app.account (username, password, role, person_id, segment_id) VALUES
-- Segment 1
('john.smith', 'hashed_password_1', 3, 1, 1),
('sarah.johnson', 'hashed_password_2', 2, 2, 1),
('robert.brown', 'hashed_password_3', 3, 3, 1),

-- Segment 5
('emily.davis', 'hashed_password_4', 4, 4, 5),
('michael.wilson', 'hashed_password_5', 3, 5, 5),
('jennifer.miller', 'hashed_password_6', 3, 6, 5),

-- Segment 6
('david.taylor', 'hashed_password_7', 4, 7, 6),
('lisa.anderson', 'hashed_password_8', 3, 8, 6),
('daniel.thomas', 'hashed_password_9', 3, 9, 6),

-- Segment 4 (central office)
('james.wilson', 'hashed_password_10', 1, 10, 4),
('maria.garcia', 'hashed_password_11', 4, 11, 4);

INSERT INTO app.access_point (name, location, is_active, description, segment_id) VALUES
-- Segment 1
('ENT-LEJ-01', 1, true, 'Main entrance turnstile', 1),
('SRV-LEJ-01', 2, true, 'Server room biometric scanner', 1),
('PRK-LEJ-01', 3, true, 'Parking barrier control', 1),

-- Segment 5
('LAB-FRUN-01', 4, true, 'Research lab card reader', 5),
('ARC-FRUN-01', 5, true, 'Archive room access', 5),
('BKE-FRUN-01', 6, true, 'Back entrance control', 5),

-- Segment 6
('PRD-BB-01', 7, true, 'Production hall gate', 6),
('WH-BB-01', 8, true, 'Warehouse entrance', 6),
('LD-BB-01', 9, true, 'Loading dock terminal', 6),

-- Segment 4
('EXE-CITY-01', 10, true, 'Executive floor access', 4),
('CFR-CITY-01', 11, true, 'Conference hall door', 4),
('RCV-CITY-01', 12, true, 'Main reception desk', 4);

INSERT INTO app.card (card_number, account_id, segment_id) VALUES
-- Segment 1
('CARD-LEJ-001', 1, 1),
('CARD-LEJ-002', 2, 1),
('CARD-LEJ-003', 3, 1),

-- Segment 5
('CARD-FRUN-001', 4, 5),
('CARD-FRUN-002', 5, 5),
('CARD-FRUN-003', 6, 5),

-- Segment 6
('CARD-BB-001', 7, 6),
('CARD-BB-002', 8, 6),
('CARD-BB-003', 9, 6),

-- Segment 4
('CARD-CITY-001', 10, 4),
('CARD-CITY-002', 11, 4);

INSERT INTO app.access_right (person_id, ap_id, valid_from, valid_to, segment_id) VALUES
-- Segment 1 access rights
(1, 1, '2024-01-01 00:00:00', '2024-12-31 23:59:59', 1),
(1, 2, '2024-01-01 00:00:00', '2024-12-31 23:59:59', 1),
(2, 1, '2024-01-01 00:00:00', NULL, 1),
(3, 1, '2024-01-01 00:00:00', '2024-06-30 23:59:59', 1),

-- Segment 5 access rights
(4, 4, '2024-01-01 00:00:00', NULL, 5),
(4, 5, '2024-01-01 00:00:00', NULL, 5),
(5, 4, '2024-01-01 00:00:00', '2024-12-31 23:59:59', 5),

-- Segment 6 access rights
(7, 7, '2024-01-01 00:00:00', NULL, 6),
(7, 8, '2024-01-01 00:00:00', NULL, 6),
(8, 7, '2024-01-01 00:00:00', '2024-08-31 23:59:59', 6),

-- Segment 4 access rights (central office has access to some areas in other segments)
(10, 10, '2024-01-01 00:00:00', NULL, 4),
(10, 1, '2024-01-01 00:00:00', NULL, 4),  -- Executive has access to main entrance of segment 1
(10, 4, '2024-01-01 00:00:00', NULL, 4),  -- Executive has access to research lab of segment 5
(11, 10, '2024-01-01 00:00:00', NULL, 4);

-- Insert access events
INSERT INTO app.access_event (person_id, account_id, ap_id, event_time, method, result, detail, segment_id) VALUES
-- Segment 1 events
(1, 1, 1, '2024-01-15 08:30:00', 1, 1, 'Morning entry', 1),
(2, 2, 1, '2024-01-15 08:45:00', 1, 1, 'Security check', 1),
(1, 1, 2, '2024-01-15 09:00:00', 3, 1, 'Server room access', 1),

-- Segment 5 events
(4, 4, 4, '2024-01-15 09:15:00', 1, 1, 'Lab entry', 5),
(5, 5, 4, '2024-01-15 09:30:00', 1, 2, 'Access denied - weekend', 5),

-- Segment 6 events
(7, 7, 7, '2024-01-15 07:45:00', 1, 1, 'Production start', 6),
(8, 8, 8, '2024-01-15 10:00:00', 1, 1, 'Warehouse access', 6),

-- Segment 4 events
(10, 10, 10, '2024-01-15 08:00:00', 1, 1, 'Executive floor entry', 4),
(10, 10, 1, '2024-01-14 14:30:00', 1, 1, 'Visit to Lejena office', 4);