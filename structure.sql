--
-- File generated with SQLiteStudio v3.0.6 on seg out 12 11:58:58 2015
--
-- Text encoding used: UTF-8
--
PRAGMA foreign_keys = off;
BEGIN TRANSACTION;

-- Table: receitas
DROP TABLE IF EXISTS receitas;
CREATE TABLE receitas (id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT, receita TEXT);

-- Table: relate_ingrediente_receita
DROP TABLE IF EXISTS relate_ingrediente_receita;
CREATE TABLE relate_ingrediente_receita (id INTEGER PRIMARY KEY AUTOINCREMENT, ingrediente_id INTEGER REFERENCES ingredientes (id), receita_id INTEGER REFERENCES receitas (id), quantidade INTEGER);

-- Table: ingredientes
DROP TABLE IF EXISTS ingredientes;
CREATE TABLE ingredientes (id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT);

COMMIT TRANSACTION;
PRAGMA foreign_keys = on;
