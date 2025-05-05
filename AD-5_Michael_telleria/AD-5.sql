
/* SELECCIONAMOS LA BASE DE DATOS*/
CREATE DATABASE BIBLIOTECA;
use biblioteca;

/* CREACION DE TABLAS*/
CREATE TABLE `libros` (
  `COD` int(11) NOT NULL AUTO_INCREMENT,
  `TITULO` varchar(100) NOT NULL,
  `ISBN` varchar(12) NOT NULL,
  `GENERO` varchar(20) NOT NULL,
  `PAGINA` int NOT NULL,
  `AUTOR` VARCHAR(100) NOT NULL,
  `EDITORIAL` VARCHAR(50) NOT NULL,
  `EDICION` VARCHAR(50)NOT NULL,
  PRIMARY KEY (`COD`),
  UNIQUE KEY `ISBN` (`ISBN`),
  KEY `GENERO` (`GENERO`)
) ;

CREATE TABLE `usuarios` (
  `COD` int(11) NOT NULL AUTO_INCREMENT,
  `NOMBRE` varchar(100) NOT NULL,
  `apel1` varchar(100) NOT NULL,
  `apel2` varchar(100) NOT NULL,
  `TLF` varchar(15) DEFAULT NULL,
  `EMAIL` varchar(120) DEFAULT NULL,
  `DISTRITO` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`COD`),
  UNIQUE KEY `TLF` (`TLF`),
  KEY `DISTRITO` (`DISTRITO`)
) ;

CREATE TABLE `prestamos` (
  `CODPREST` int(11) NOT NULL,
  `CODUSU` int(11) NOT NULL,
  `CODLIB` int(11) NOT NULL,
  `FECHAPRES` timestamp NOT NULL DEFAULT current_timestamp(),
  `FECHADEVO` date DEFAULT NULL,
  `DIASPENALIZA` int(11) DEFAULT NULL,
  `NIVEL_SANCION` VARCHAR(50) DEFAULT NULL,
  `MENSAJE` varchar(400) DEFAULT NULL,
  KEY `CODUSU` (`CODUSU`),
  KEY `CODLIB` (`CODLIB`),
  CONSTRAINT `prestamos_ibfk_1` FOREIGN KEY (`CODUSU`) REFERENCES `usuarios` (`COD`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `prestamos_ibfk_2` FOREIGN KEY (`CODLIB`) REFERENCES `libros` (`COD`) ON DELETE CASCADE ON UPDATE CASCADE
)  ;

CREATE TABLE SANCIONADOS (
    COD_SANCION INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    CODIGO_USUARIO INT,
    CODIGO_PRESTAMO INT,
    FECHA_PRESTAMO TIMESTAMP,
    DIAS_SANCION INT,
    MENSAJE VARCHAR(400),
    FOREIGN KEY (CODIGO_USUARIO) REFERENCES USUARIOS(COD)ON DELETE CASCADE ON UPDATE CASCADE
);


/* CREACION DE LAS STORED PROCEDURES*/

/* PRIMER PROCEDIMIENTO */
CREATE DEFINER=`root`@`localhost` PROCEDURE `prest`(codpres int,codusu int,codlib int,fpres timestamp,fdevo date,diapen int,NIVEL_SANCION VARCHAR(50),MENSAJE varchar(400))
BEGIN
	
    insert into prestamos (CODPREST,CODUSU,CODLIB,FECHAPRES,FECHADEVO,DIASPENALIZA,NIVEL_SANCION,MENSAJE)
    values (codpres,codusu,codlib,fpres,fdevo,diapen,NIVEL_SANCION,MENSAJE)

END

/* SEGUNDO PROCEDIMIENTO */

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertusu`(cod int,nomb varchar(50),apel1 varchar(50),apel2 varchar(50),tlf varchar(50),email varchar(100),dist varchar(50))
BEGIN
	
    insert into usuarios (cod ,nombre,apel1,apel2,tlf ,email,distrito)
    values (cod ,nomb,apel1,apel2,tlf ,email,dist);

END;

/* TERCER PROCEDIMIENTO */
CREATE DEFINER=`root`@`localhost` PROCEDURE `altaLib`(cod int,titu varchar(50),isbn varchar(50),genr varchar(50),PAGINA int,AUTOR VARCHAR(100),EDITORIAL VARCHAR(50),EDICION VARCHAR(50))
BEGIN
	
    insert into LIBROS (cod,titulo,isbn,genero,pag,AUTOR,EDITORIAL,EDICION)
    values (cod,titu,isbn,genr,PAGINA,AUTOR,EDITORIAL,EDICION);

END;

/* CUARTO PROCEDIMIENTO*/

CREATE DEFINER=`root`@`localhost` PROCEDURE `GESTOR`()
BEGIN

	UPDATE PRESTAMOS p
	JOIN USUARIOS u ON p.CODUSU = u.COD
	SET 
		p.NIVEL_SANCION = SANCION_USUARIO(p.FECHAPRES, p.FECHADEVO),
		p.MENSAJE = MENSAJES_SANCION(u.NOMBRE, u.APEL1, u.APEL2, p.FECHAPRES, p.FECHADEVO, p.CODPREST);
	
	
    
    INSERT INTO SANCIONADOS (CODIGO_USUARIO, FECHA_PRESTAMO, DIAS_SANCION, MENSAJE)
    
    SELECT CODUSU,FECHAPRES,DATEDIFF(FECHADEVO, FECHAPRES) AS DIAS_SANCION,MENSAJE
    FROM PRESTAMOS
    WHERE NIVEL_SANCION IN ('GRAVE', 'MUY GRAVE');   
        
 
END;

/* PRIMERA FUNCION*/

CREATE DEFINER=`root`@`localhost` FUNCTION `SANCION_USUARIO`(fpres timestamp,fdevo date) RETURNS varchar(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
BEGIN
	 DECLARE resultado VARCHAR(50);
     DECLARE dias INT;
	 SET dias = DATEDIFF(fdevo, fpres);

    IF (dias < 7) THEN
        SET resultado = 'ACTIVO';
    ELSEIF (dias >= 7) AND (dias < 12) THEN
        SET resultado = 'GRAVE';
    ELSEIF (dias >= 12) THEN
        SET resultado = 'MUY GRAVE';
    END IF;

RETURN resultado;
END;

/* SEGUNDA FUNCION*/

CREATE DEFINER=`root`@`localhost` FUNCTION `MENSAJES_SANCION`(nomb varchar(50),APEL1 VARCHAR (50),APEL2 VARCHAR(50),FPREST timestamp,FDEVO DATE,CODPREST INT) RETURNS varchar(400) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
BEGIN
	declare mensaje varchar (400);
    declare DIAS_RETRASO int;
    DECLARE FDEVO_PREVISTA INT;
    DECLARE RESULTADO varchar(50);
 
    
    SET resultado = SANCION_USUARIO(fprest, fdevo);
    SET DIAS_RETRASO = DATEDIFF(FDEVO, FPREST);
    SET FDEVO_PREVISTA = 7;
    

	set mensaje= concat('Estimado usuario',' ',NOMB,' ',APEL1,' ',APEL2,' ', 
    'el pasado día',' ',DATE_FORMAT(FPREST, "%Y/%m/%d"),'-','realizó un préstamo en nuestra biblioteca con código',
    ' ',CODPREST,' ','Han pasado ', DIAS_RETRASO ,'días desde el préstamo,','y ha superado la fecha de entrega prevista en '
    ,' ',FDEVO_PREVISTA ,' ','días,por lo que le corresponde una sanción',' ',RESULTADO);
	


RETURN mensaje;
END;

/* DATOS DE PRUEBA*/


select * from usuarios;
select * from libros;
select * from prestamos;
select * from sancionados;

call insertusu(123,'pop','eye','pop','78787878','pop@gmail.com','san fransisco');
call insertusu(234,'pap','can','pot','73244378','pap@gmail.com','Los Angeles');
call insertusu(3456,'pep','pep','pot','74234878','pep@gmail.com','Detroid');

call altaLib(234,'mil besos','94357469357','romace',445, 'JUAN', 'JUN', '8');
call altaLib(234,'el principe','94357469357','AAAA',445, 'JUANSI', 'JUNU', '6');
call prest(1,123,234,'1978-08-11','2025-04-11',0,'null','null');
call prest(2,234,234,'1978-08-11','2025-04-11',0,'null','null');
call prest(3,3456,234,'1978-08-11','2025-04-11',0,'null','null');

select biblioteca.MENSAJES_SANCION('pop', 'eye', 'pop', '2025-01-9', '2025-04-11', 1);

INSERT INTO SANCIONADOS (COD_SANCION, CODIGO_USUARIO, CODIGO_PRESTAMO, FECHA_PRESTAMO, DIAS_SANCION, MENSAJE)
VALUES (0, 123,1, '2025-01-09','0','N');

call biblioteca.GESTOR();










