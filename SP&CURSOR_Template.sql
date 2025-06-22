--- A SIMPLE TEMPLATE

DELIMITER //

CREATE PROCEDURE proc_name(IN param1 TYPE, OUT param2 TYPE, INOUT param3 TYPE)
BEGIN
    -- 4. Declare variables
    DECLARE v_var1 TYPE DEFAULT value;
    DECLARE v_var2 TYPE DEFAULT value;
    DECLARE done INT DEFAULT 0;

    -- 5. Declare handlers
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- 6. Declare cursor
    DECLARE cur_name CURSOR FOR
        SELECT col1, col2
        FROM table_name
        WHERE ...;

    -- 7. Declare exception handlers (already done above for NOT FOUND)
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback if error
        ROLLBACK;
        SET param2 = -1;
        SELECT 'Error occurred — rollback done';
    END;

    -- 8. Initialize OUT params
    SET param2 = 0;

    -- 9. Start transaction
    START TRANSACTION;

    -- 10. Open cursor
    OPEN cur_name;

    -- 11. Loop
    loop1: LOOP

        -- 12. Fetch
        FETCH cur_name INTO v_var1, v_var2;

        -- 13. If done then leave
        IF done THEN
            LEAVE loop1;
        END IF;

        -- 14. Business logic
        -- Example:
        -- IF v_var1 > 100 THEN
        --     SET param2 = param2 + 1;
        -- END IF;

    END LOOP;

    -- 16. Close cursor
    CLOSE cur_name;

    -- 17. Commit transaction
    COMMIT;

END //

DELIMITER ;
-------------------------------------------------------------------------------------------------------------------------------------


---## TEMPLATE WITH CONDITIONS

DELIMITER //

CREATE PROCEDURE proc_with_if_case(IN param1 INT, OUT param2 INT)
BEGIN
    DECLARE v_id INT;
    DECLARE v_value INT;
    DECLARE done INT DEFAULT 0;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    DECLARE cur1 CURSOR FOR
        SELECT id, some_value FROM some_table WHERE some_column = param1;

    SET param2 = 0;

    START TRANSACTION;

    OPEN cur1;

    loop1: LOOP

        FETCH cur1 INTO v_id, v_value;

        IF done THEN
            LEAVE loop1;
        END IF;

        -- IF block inside loop
        IF v_value > 100 THEN
            SET param2 = param2 + 10;
        ELSEIF v_value BETWEEN 50 AND 100 THEN
            SET param2 = param2 + 5;
        ELSE
            SET param2 = param2 + 1;
        END IF;

        -- CASE block inside loop
        CASE 
            WHEN v_value >= 200 THEN 
                SET param2 = param2 + 20;
            WHEN v_value >= 150 THEN 
                SET param2 = param2 + 15;
            ELSE 
                SET param2 = param2 + 0;
        END CASE;

    END LOOP;

    CLOSE cur1;

    COMMIT;

END //

DELIMITER ;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- MULTIPLE CURSORS

DELIMITER //

CREATE PROCEDURE proc_with_multiple_cursors()
BEGIN
    DECLARE v_id1 INT;
    DECLARE v_value1 INT;
    DECLARE v_id2 INT;
    DECLARE v_value2 INT;
    DECLARE done1 INT DEFAULT 0;
    DECLARE done2 INT DEFAULT 0;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done1 = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error occurred — rollback done';
    END;

    DECLARE cur1 CURSOR FOR
        SELECT id, value FROM table1 WHERE ...;

    DECLARE cur2 CURSOR FOR
        SELECT id, value FROM table2 WHERE ...;

    START TRANSACTION;

    OPEN cur1;
    OPEN cur2;

    -- Cursor 1 loop
    loop1: LOOP
        FETCH cur1 INTO v_id1, v_value1;

        IF done1 THEN
            LEAVE loop1;
        END IF;

        -- Business logic for cursor 1
        -- Example: UPDATE table3 SET col = v_value1 WHERE id = v_id1;

    END LOOP;

    CLOSE cur1;

    -- Cursor 2 loop
    SET done2 = 0;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done2 = 1;

    loop2: LOOP
        FETCH cur2 INTO v_id2, v_value2;

        IF done2 THEN
            LEAVE loop2;
        END IF;

        -- Business logic for cursor 2
        -- Example: INSERT INTO log_table VALUES (v_id2, v_value2, NOW());

    END LOOP;

    CLOSE cur2;

    COMMIT;

END //

DELIMITER ;
