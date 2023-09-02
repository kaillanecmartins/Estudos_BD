/*
	ATIVIDADE 01 - SQL PROGRAMADA
    KAILLANE CORRÊA MARTINS
*/

/*1º Crie um banco de dados com pelo menos 3 entidades e um relacionamento entre duas delas.*/
CREATE TABLE hospede(
    idHospede int not null auto_increment primary key,
    cpfHospede varchar(15) not null,
    nome varchar(100),
    email varchar(100)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE quarto(
    idQuarto int auto_increment not null,
    numeroQuarto int not null,
    precoDiaria double,
    primary key (idQuarto)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

create table reserva(
    idReserva int not null auto_increment primary key,
    idHospede int not null,
    idQuarto int not null,
    constraint fk_1 foreign key (idHospede) references hospede(idHospede),
    constraint fk_2 foreign key (idQuarto) references quarto(idQuarto)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*-------------------------------------------------------------------------*/

/*2º Defina uma relação de especialização entre duas das entidades. */
CREATE TABLE suite(
    idQuarto int auto_increment not null primary key,
    descricao varchar(255),
    FOREIGN KEY (idQuarto) REFERENCES quarto(idQuarto)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*-------------------------------------------------------------------------*/

/*3º Escreva um procedimento para pelo menos uma operação CRUD com as informações
 na entidade super e na entidade derivada em uma única chamada. */
DELIMITER //

CREATE PROCEDURE InserirSuite(
    IN numeroQuarto int,
    IN precoDiaria double,
    IN descricao VARCHAR(255)
)
BEGIN
    INSERT INTO quarto (numeroQuarto, precoDiaria)
    VALUES (numeroQuarto, precoDiaria);

    INSERT INTO suite (descricao, idQuarto)
    VALUES (descricao, LAST_INSERT_ID());
END //

DELIMITER ;

# teste: call InserirSuite(54321, 300.0, 'serviço de quarto incluso, banheiro espaçoso');

/*-------------------------------------------------------------------------*/

/*4º Escreva pelo menos duas funções para seu BD*/

DELIMITER //

CREATE FUNCTION CalcularEstadia(precoDiaria double, numDias int)
RETURNS double
BEGIN
    RETURN precoDiaria * numDias;
END //

DELIMITER ;

#teste: select CalcularEstadia(precoDiaria, 5) as Total from quarto where idQuarto = 1;

/*-------------------------------------------------------------------------*/

DELIMITER //

CREATE FUNCTION VerificarQuartoVazio(idQuarto int)
RETURNS varchar(5)
BEGIN
    DECLARE quarto_vazio BOOLEAN;

    SELECT COUNT(*) INTO quarto_vazio
    FROM reserva;

    IF quarto_vazio = 0 THEN
        RETURN 'SIM';
    ELSE
        RETURN 'NÃO';
    END IF;
END //

DELIMITER ;

#teste: SELECT VerificarQuartoVazio(1) as Quarto_Vazio;

/*-------------------------------------------------------------------------*/

create table registro_reservas (
	id_reserva int not null primary key,
    data_registro date
);

/*5º  Inclua pelo menos dois gatilhos em seu BD*/

DELIMITER //
CREATE TRIGGER RegistroReserva
AFTER INSERT ON reserva
FOR EACH ROW
BEGIN
    INSERT INTO registro_reservas (id_reserva, data_registro)
    VALUES (NEW.idReserva, NOW());
END;
//
DELIMITER ;

/*-------------------------------------------------------------------------*/

DELIMITER //

CREATE TRIGGER VerificarCPFPadrao
BEFORE INSERT ON hospede
FOR EACH ROW
BEGIN
    DECLARE cpf_padrao VARCHAR(15);
    SET cpf_padrao = '^[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}$';

    IF NEW.cpfHospede NOT REGEXP cpf_padrao OR CHAR_LENGTH(NEW.cpfHospede) != 14 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'CPF do hóspede inserido fora do padrão.';
    END IF;
END //
DELIMITER ;

#teste: insert into hospede values(null, '12345687', 'Teste', 'teste123@mail');