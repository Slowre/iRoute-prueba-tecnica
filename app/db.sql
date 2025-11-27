CREATE DATABASE IF NOT EXISTS db_prueba CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish2_ci;

USE db_prueba;

CREATE TABLE IF NOT EXISTS commerce(
    id INT AUTO_INCREMENT PRIMARY KEY,
    pc_nomcomred VARCHAR(255) NOT NULL,
    pc_numdoc VARCHAR(30) NOT NULL,
    pc_processdate DATE NOT NULL,
    pc_direccion VARCHAR(255) NOT NULL,
    pc_telefono VARCHAR(10) NOT NULL,
    pc_email VARCHAR(255) NOT NULL
);

DELIMITER //

CREATE PROCEDURE sp_create_commerce (
    IN in_pc_nomcomred VARCHAR(255),
    IN in_pc_numdoc VARCHAR(30),
    IN in_pc_processdate DATE,
    IN in_pc_direccion VARCHAR(255),
    IN in_pc_telefono VARCHAR(10),
    IN in_pc_email VARCHAR(255)
)
BEGIN
    INSERT INTO commerce (
        pc_nomcomred,
        pc_numdoc,
        pc_processdate,
        pc_direccion,
        pc_telefono,
        pc_email
    )
    VALUES (
        IFNULL(in_pc_nomcomred,''),
        IFNULL(in_pc_numdoc,''),
        IFNULL(in_pc_processdate,''),
        IFNULL(in_pc_direccion,''),
        IFNULL(in_pc_telefono,''),
        IFNULL(in_pc_email,'')
    );
END //

DELIMITER ;

CREATE TABLE IF NOT EXISTS commerce_quarantine(
    id INT AUTO_INCREMENT PRIMARY KEY,
    pc_nomcomred VARCHAR(255) NOT NULL,
    pc_numdoc VARCHAR(30) NOT NULL,
    pc_processdate DATE NOT NULL,
    pc_direccion VARCHAR(255) NOT NULL,
    pc_telefono VARCHAR(10) NOT NULL,
    pc_email VARCHAR(255) NOT NULL,
    motivo VARCHAR(255) NOT NULL
);

DELIMITER // 
CREATE PROCEDURE sp_validate_commerce (
    IN in_pc_processdate DATE,
    OUT cant_quarantine BIGINT
) BEGIN
    INSERT INTO commerce_quarantine (
        pc_nomcomred,
        pc_numdoc,
        pc_processdate,
        pc_direccion,
        pc_telefono,
        pc_email,
        motivo
    )
    (SELECT
        IFNULL(co.pc_nomcomred,''),
        IFNULL(co.pc_numdoc,''),
        IFNULL(co.pc_processdate,NULL),
        IFNULL(co.pc_direccion,''),
        IFNULL(co.pc_telefono, ''),
        IFNULL(co.pc_email,''),
        ''
    FROM commerce co
    WHERE 
        (co.pc_processdate = in_pc_processdate OR STR_TO_DATE(co.pc_processdate, '%Y-%m-%d') IS NULL) 
        AND
        (
            co.pc_nomcomred IS NULL OR co.pc_nomcomred ="" OR
            co.pc_numdoc Is NULL OR co.pc_numdoc ="" OR co.pc_numdoc REGEXP '[^0-9]' OR 
            STR_TO_DATE(co.pc_processdate, '%Y-%m-%d') IS NULL
        )
     );

    SELECT ROW_COUNT() INTO cant_quarantine;

    DELETE FROM commerce
    WHERE 
        (pc_processdate = in_pc_processdate OR STR_TO_DATE(pc_processdate, '%Y-%m-%d') IS NULL) 
        AND
        (
            pc_nomcomred IS NULL OR pc_nomcomred ="" OR
            pc_numdoc Is NULL OR pc_numdoc ="" OR pc_numdoc REGEXP '[^0-9]' OR 
            STR_TO_DATE(pc_processdate, '%Y-%m-%d') IS NULL
        );
    
    UPDATE commerce_quarantine SET motivo = "";
    UPDATE commerce_quarantine coqu SET motivo = CONCAT_WS(', ',coqu.motivo,'Fecha inválida')  WHERE STR_TO_DATE(coqu.pc_processdate, '%Y-%m-%d') IS NULL;
    UPDATE commerce_quarantine coqu SET motivo = CONCAT_WS(', ',coqu.motivo, 'El nombre del comercio se encuentra vacio') WHERE coqu.pc_nomcomred IS NULL OR coqu.pc_nomcomred ="";
    UPDATE commerce_quarantine coqu SET motivo = CONCAT_WS(', ',coqu.motivo, 'Número de documento vacío') WHERE coqu.pc_numdoc Is NULL OR coqu.pc_numdoc ="" ;
    UPDATE commerce_quarantine coqu SET motivo = CONCAT_WS(', ',coqu.motivo, 'Número de documento tiene letras o caracteres especiales') WHERE coqu.pc_numdoc REGEXP '[^0-9]';

END//
DELIMITER ;


CALL sp_create_commerce('Comercial ABC', '1234567890', '2025-01-15', 'Av. Quito 321', '0998877665', 'abc@gmail.com');
CALL sp_create_commerce('Tienda Lopez', '0923456789', '2025-01-15', 'Calle 10', '0944556677', 'tienda@lopez.com');
CALL sp_create_commerce('Mercado Sur', '0012345678', '2025-01-15', 'Av. Sur 89', '0981122334', 'msur@mail.com');
CALL sp_create_commerce('Ferreteria El Martillo', '1112223334', '2025-01-15', 'Av. Colon', '022334455', 'martillo@ferre.com');
CALL sp_create_commerce('Panaderia Dulce', '9876543210', '2025-01-15', 'Calle Central', '0999988776', 'dulce@pan.com');
CALL sp_create_commerce('Farmacia Vida', '1231231231', '2025-01-15', 'Av. Libertad 123', '0987766554', 'vida@farmacia.com');
CALL sp_create_commerce('Comercio Quito', '0001112223', '2025-01-15', 'Av. Amazonas', '0995544332', 'quito@com.com');
CALL sp_create_commerce('Tecnishop', '5566778899', '2025-01-15', 'Calle Tech', '0985554433', 'info@tech.com');
CALL sp_create_commerce('Electro Lopez', '8899001122', '2025-01-15', 'Av. Lopez', '0977445566', 'elop@mail.com');
CALL sp_create_commerce('Bazar El Mundo', '1238904567', '2025-01-15', 'Calle Mundo', '0998877123', 'mundo@bazar.com');

CALL sp_create_commerce('', '1234567890', '2025-01-15', 'Av. Quito 321', '0998877665', 'vac@mail.com');

CALL sp_create_commerce(NULL, '1234567890', '2025-01-15', 'Calle 123', '0994433221', 'nullname@mail.com');

CALL sp_create_commerce('Comercio X', '', '2025-01-15', 'Av. X', '0998877665', 'cx@mail.com');

CALL sp_create_commerce('Comercio Y', NULL, '2025-01-15', 'Av. Y', '0998877123', 'cy@mail.com');

CALL sp_create_commerce('ABC Store', '12AB56', '2025-01-15', 'Calle 45', '0991112233', 'abc@mail.com');

CALL sp_create_commerce('Tienda #1', '123-456', '2025-01-15', 'Av. Oeste', '099221144', 't1@mail.com');

CALL sp_create_commerce('Comercio Fecha Mala', '123456', '2025-99-99', 'Av. Fail', '0998877665', 'fail@mail.com');

CALL sp_create_commerce('Comercio Texto', '123456', 'not-a-date', 'Calle 99', '0984455667', 'text@mail.com');

CALL sp_create_commerce('Comercio Tel', '123456', '2025-01-15', 'Av. North', '', 'tel@mail.com');

CALL sp_create_commerce('', 'ABC123', '2025-01-15', 'Calle 3', '0998877665', 'mix@mail.com');