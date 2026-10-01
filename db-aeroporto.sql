-- Etapa 1: DDL — Criação do Esquema

create table aeronaves(
	id serial PRIMARY key,
	modelo varchar (200) not null,
	codigo_cauda VARCHAR(10) unique not null, --(ex: 'ABC-123')
	capacidade int not null check(capacidade > 0)
)

create table pilotos (
	id serial primary key,
	nome VARCHAR(200) not null,
	codigo_anac VARCHAR(6) unique not null,
	horas_voo int default 0 check(horas_voo >= 0)
)

create table voos (
	id serial primary key,
	aeronave_id int REFERENCES aeronaves(id),
	piloto_id int REFERENCES pilotos(id),
	numero_voo varchar(50) not null,
	origem VARCHAR(100) not null,
	destino VARCHAR(100) not null,
	data_hora TIMESTAMP default current_timestamp,
	status VARCHAR(50) check (status in ('Agendado', 'Em Voo', 'Concluido', 'Cancelado')) default 'Agendado'
)

create table passageiros(
	id serial primary key,
	nome varchar(200) not null,
	cpf VARCHAR(11) unique not null,
	email VARCHAR(100) unique not null
)

create table passagens(
	id serial primary key,
	voo_id int REFERENCES voos(id),
	passageiro_id int references passageiros(id),
	assento varchar(4) not null, --(ex: '12A')
	classe varchar(20) check (classe in('Economica', 'Executiva')) DEFAULT 'Economica',
	valor decimal(10, 2) check (valor > 0) not null 
)




-- Etapa 2: DML — Inserção de Dados

insert into aeronaves(modelo, codigo_cauda, capacidade) VALUES
('Boing 737', 'AAA-111', '400'),
('Boing 737', 'BBB-222', '400'),
('Air-Bus 12', 'CCC-333', '350'),
('Air-Bus 22', 'DDD-444', '300'),
('Boing 749', 'EEE-555', '450')


insert into pilotos (nome, codigo_anac, horas_voo) VALUES
('Ricrado Mendes', '112233', '120'),
('Paulo Antunes', '222333', '40'),
('Cláudio Ribeiro', '445566', '20'),
('Willer Barros', '555666', '0'),
('Antônio Fagundes', '778899', '125')


insert into passageiros (nome, cpf, email) VALUES
('Ângela Ferreira', '11111111111', 'angela.ferreira@gmail.com'),
('Otávio Tavares', '22222222222', 'otavio.tavares@gmail.com'),
('Caetano Veloso', '33333333333', 'caetano.veloso@gmail.com'),
('Gustavo Lima', '44444444444', 'gustavo.lima@gmail.com'),
('Claudia Leite', '55555555555', 'claudia.leite@gmail.com')


INSERT into voos (aeronave_id, piloto_id, numero_voo, origem, destino, status) VALUES
	(1, 1, '144', 'São Paulo', 'Miami', 'Agendado'),
	(3, 3, '146', 'Rio de Janeiro', 'Bogotá', 'Cancelado'),
	(2, 2, '145', 'Florianópolis', 'São Paulo', 'Em Voo'),
	(4, 4, '147', 'São Paulo', 'Paris', 'Concluido'),
	(5, 5, '148', 'Florianópolis', 'Buenos Aires', 'Agendado')


insert into passagens (voo_id, passageiro_id, assento, classe, valor) VALUES
	(1, 1, '12A', 'Executiva', 810.00),
	(2, 2, '13A', 'Executiva', 1200.00),
	(3, 3, '12B', 'Executiva', 790.00),
	(4, 4, '16A', 'Economica', 510.00),
	(5, 5, '22B', 'Economica', 610.00)




-- Etapa 3: DQL — Consultas Avançadas


-- Q1 
select 
	v.numero_voo as voo,
	v.origem,
	v.destino,
	a.modelo,
	p.nome as piloto,
	v.status
from
	aeronaves a
join voos v on v.aeronave_id = a.id
join pilotos p on v.piloto_id = p.id
WHERE
	v.status in ('Agendado', 'Em Voo')


-- Q2
select 
	passagens.classe,
	sum(passagens.valor) as valor_total
from
	passagens
group by
	passagens.classe



-- Q3
select
	passageiros.nome as passageiro,
	voos.numero_voo,
	passagens.assento,
	passagens.valor,
	passagens.classe
from
	passagens
	
join passageiros on passagens.passageiro_id = passagens.id
join voos on passagens.voo_id = voos.id

where 
	passagens.classe = 'Executiva' and
	passagens.valor > 800.00

order by passagens.valor desc



-- Etapa 4: Views — Visões de Negócio

-- V1
create VIEW  vw_painel_aeroporto AS
select
	v.numero_voo,
	v.data_hora,
	v.origem,
	v.destino,
	a.modelo,
	a.codigo_cauda,
	v.status
from
	voos v
join aeronaves a on v.aeronave_id = a.id

-- V2
CREATE VIEW vw_faturamento_por_voo AS
SELECT 
    v.id AS voo_id,
    v.numero_voo,
    v.destino,
    COUNT(p.id) AS total_passageiros,
    SUM(p.valor) AS receita_total
FROM 
    voos v
JOIN 
    passagens p ON v.id = p.voo_id
GROUP BY 
    v.id, 
    v.numero_voo, 
    v.destino