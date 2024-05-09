drop table if exists Vendidas;

drop table if exists AsocOfertas;

drop table if exists Localidad;

drop table if exists Evento;

drop table if exists Recinto;

drop table if exists Tipo_Usuario;

drop table if exists Cliente;

drop table if exists Anuladas;

CREATE TABLE Recinto (
    Nombre varchar(50),
    Ciudad varchar(50),
    Capacidad int NOT NULL,
    PRIMARY KEY(Ciudad, Nombre)
);

CREATE TABLE Cliente (
    Nombre varchar(50),
    Apellido varchar(50),
    NIF int,
    Metodo_Pago enum("PayPal", "Tarjeta", "Bizum"),
    PRIMARY KEY(NIF)
);

CREATE TABLE Localidad (
    Numero int check(Numero > 0),
    Nombre_recinto varchar(50),
    Ciudad_recinto varchar(50),
    PRIMARY KEY(Numero, Nombre_recinto, Ciudad_recinto),
    FOREIGN KEY (Ciudad_recinto, Nombre_recinto) REFERENCES Recinto(Ciudad, Nombre)
);

CREATE TABLE Tipo_Usuario (
    Tipo enum("Infantil", "Jubilado", "Adulto", "Parado"),
    PRIMARY KEY(Tipo)
);

CREATE TABLE Evento (
    Dia DATE,
    Nombre_recinto varchar(50),
    Ciudad_recinto varchar(50),
    Nombre_espectaculo varchar(50),
    Limite_entradas_usuario int NOT NULL DEFAULT 10,
    Estado enum("Abierto", "Cerrado", "Finalizado") NOT NULL DEFAULT "Abierto",
    TiempoAnulacion int NOT NULL DEFAULT 1,
    Penalizacion int NOT NULL DEFAULT 10,
    Numero_inf int DEFAULT 10,
    Numero_jub int DEFAULT 10,
    Numero_adu int DEFAULT 10,
    Numero_par int DEFAULT 10,
    PRIMARY KEY(
        Dia,
        Nombre_recinto,
        Ciudad_recinto
    ),
    FOREIGN KEY (Ciudad_recinto, Nombre_recinto) REFERENCES Recinto(Ciudad, Nombre)
);

CREATE TABLE AsocOfertas (
    Dia_evento DATE,
    Numero_localidad int,
    Ciudad_recinto varchar(50),
    Nombre_recinto varchar(50),
    Tipo enum("Infantil", "Jubilado", "Adulto", "Parado"),
    Precio int NOT NULL DEFAULT 10,
    PRIMARY KEY(
        Dia_evento,
        Numero_localidad,
        Ciudad_recinto,
        Nombre_recinto,
        Tipo
    ),
    FOREIGN KEY (Dia_evento, Nombre_recinto, Ciudad_recinto) REFERENCES Evento(Dia, Nombre_recinto, Ciudad_recinto),
    FOREIGN KEY (Numero_localidad, Nombre_recinto, Ciudad_recinto) REFERENCES Localidad(Numero, Nombre_recinto, Ciudad_recinto),
    FOREIGN KEY (Tipo) REFERENCES Tipo_Usuario(Tipo)
);

create table Vendidas(
    Dia_evento DATE,
    Numero_localidad int,
    Tipo enum("Infantil", "Jubilado", "Adulto", "Parado"),
    Ciudad_recinto varchar(50),
    Nombre_recinto varchar(50),
    Cliente int NOT NULL,
    PRIMARY KEY(
        Dia_evento,
        Numero_localidad,
        Ciudad_recinto,
        Nombre_recinto
    ),
    FOREIGN KEY (
        Dia_evento,
        Numero_localidad,
        Ciudad_recinto,
        Nombre_recinto,
        Tipo
    ) REFERENCES AsocOfertas(
        Dia_evento,
        Numero_localidad,
        Ciudad_recinto,
        Nombre_recinto,
        Tipo
    ),
    FOREIGN KEY (Tipo) REFERENCES Tipo_Usuario(Tipo),
    FOREIGN KEY (Cliente) REFERENCES Cliente(NIF)
);

CREATE TABLE Anuladas (
    Cliente int,
    Numero_localidad int,
    Dia_evento DATE,
    Nombre_recinto varchar(50),
    Ciudad_recinto varchar(50),
    Precio int,
    Momento_anulacion timestamp default NOW(),
    Penalizacion float default 0
);