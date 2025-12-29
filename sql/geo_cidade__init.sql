const sqlTemplate = `
CREATE SCHEMA IF NOT EXISTS geo_{{schema}};
CREATE TABLE IF NOT EXISTS geo_{{schema}}.cad_mun as

select 
  gid,
  cd_mun,
  nm_mun,
  '' as tp_mun,
  true as ativo,
  'Cadastro Município' as categoria,
  st_transform( geom, {{src}}) as geom
from ibge22.br_mun 
where nm_mun = '{{nm_mun}}';

CREATE TABLE IF NOT EXISTS geo_{{schema}}.cad_bairro as

select 
  gid,
  cd_bairro,
  nm_bairro,
  '' as tp_bairro,
  true as ativo,
  'Cadastro Bairro' as categoria,
  st_transform( geom, {{src}}) as geom
from ibge22.br_bairros_cd2022 
where nm_mun = '{{nm_mun}}';

CREATE TABLE IF NOT EXISTS geo_{{schema}}.data_pgt ( 
  full_id int8 NULL,
  osm_id int8 NULL,
  osm_type varchar(20) NULL,
  "name" varchar({{st_distance}}) NULL,
  alt_name varchar({{st_distance}}) NULL,
  full_info json NULL,
  chave varchar({{st_distance}}) NULL,
  valor_chave varchar({{st_distance}}) NULL,
  tipo_geometria varchar(200) NULL,
  uf varchar(2) NULL,
  cidade varchar(50) NULL,
  bairro varchar(50) NULL,
  geometria public.geometry NULL,
  dt_raspagem timestamp NULL
);

CREATE TABLE IF NOT EXISTS geo_{{schema}}.int_mar (
  gid numeric NULL,
  geom public.geometry(multipolygon, {{src}}) NULL,
  id numeric NULL,
  categoria varchar(254) NULL,
  cd_int varchar(254) NULL,
  tp_int varchar(254) NULL,
  nm_int varchar(254) NULL,
  ativo bool NULL
);

CREATE TABLE IF NOT EXISTS geo_{{schema}}.int_lagoa (
  gid int4 NULL,
  geom public.geometry(multipolygon, {{src}}) NULL,
  id int8 NULL,
  cd_int varchar(254) NULL,
  nm_int varchar(254) NULL,
  tp_int varchar(254) NULL,
  categoria varchar(254) NULL,
  ativo bool NULL
);

CREATE TABLE IF NOT EXISTS geo_{{schema}}.int_centro (
  gid int4 NULL,
  nm_int text NULL,
  cd_int text NULL,
  tp_int varchar(254) NULL,
  categoria text NULL,
  geom public.geometry(multipolygon, {{src}}) NULL,
  ativo bool NULL
);

CREATE TABLE IF NOT EXISTS geo_{{schema}}.int_vias_principais (
  gid int8 NULL,
  cd_int text NULL,
  nm_int text NULL,
  tp_int text NULL,
  categoria text NULL,
  geom public.geometry NULL,
  ativo bool NULL
);

CREATE TABLE IF NOT EXISTS geo_{{schema}}.cad_logr (
	gid serial4 NOT NULL,
	objectid int4 NULL,
	__gid numeric NULL,
	codlogra numeric NULL,
	cep_e varchar(19) NULL,
	cod_proc varchar(19) NULL,
	pav numeric NULL,
	ele numeric NULL,
	ilu numeric NULL,
	meio numeric NULL,
	sequencial numeric NULL,
	pista numeric NULL,
	acumulo numeric NULL,
	sentido numeric NULL,
	nomelog varchar(254) NULL,
	id_pavimen numeric NULL,
	usuario_ad varchar(50) NULL,
	dt_inc varchar(24) NULL,
	dt_upd varchar(24) NULL,
	created_us varchar(254) NULL,
	created_da varchar(24) NULL,
	last_edite varchar(254) NULL,
	last_edi_1 varchar(24) NULL,
	shape__len numeric NULL,
	geom public.geometry(multilinestring, {{src}}) NULL,
	cd_logr varchar(254) NULL,
	tp_logr varchar(254) NULL,
	nm_logr varchar(254) NULL,
	categoria varchar(254) DEFAULT 'Cadastro Logradouro'::character varying NULL,
	ativo bool DEFAULT true NULL,
	CONSTRAINT cad_logr_pkey PRIMARY KEY (gid)
);


CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_empresas
TABLESPACE pg_default
AS SELECT ee.date_part,
    ee.id,
    ee.address,
    ee.cnpj_basico_simples,
    ee.opcao_pelo_simples,
    ee.data_opcao_simples,
    ee.data_exclusao_simples,
    ee.opcao_mei,
    ee.data_opcao_mei,
    ee.data_exclusao_mei,
    ee.cnpj_basico_empresa,
    ee.razao_social,
    ee.natureza_juridica,
    ee.qualificacao_responsavel,
    ee.capital_social,
    ee.porte,
    ee.dt_raspagem,
    ee.descricao_naturezas_juridicas,
    ee.descricao_porte,
    ee.id_estabelecimento,
    ee.cnpj_basico_estabelecimento,
    ee.cnpj,
    ee.nome_fantasia,
    ee.cnae_fiscal_principal,
    ee.tipo_logradouro,
    ee.logradouro,
    ee.numero,
    ee.complemento,
    ee.bairro,
    ee.cep,
    ee.uf,
    ee.municipio,
    ee.ddd,
    ee.telefone,
    ee.email,
    ee.data_inicio_atividade,
    ee.execucao,
    ee.data_raspagem,
    ee.descricao_mun,
    ee.descricao_cnae,
    ee.cnae,
    ee.cod_secao,
    ee.desc_secao,
    ee.cod_divisao,
    ee.desc_divisao,
    ee.desc_grupo,
    ee.desc_classe,
    ee.desc_subclasse,
    ee.endereco_consulta,
    ee.latitude,
    ee.longitude,
    ee.precisao_geocoding,
    ee.geom,
    ef.gid_cliente,
    ef.ponto,
    ef.cidade,
    ef.latlonglote,
    st_distance(ef.ponto::geography, ee.geom::geography, true) AS st_distance,
    (st_y(st_centroid(ee.geom)) || ','::text) || st_x(st_centroid(ee.geom)) AS latlong
   FROM ( SELECT empresas_geral.date_part,
            empresas_geral.id,
            empresas_geral.address,
            empresas_geral.cnpj_basico_simples,
            empresas_geral.opcao_pelo_simples,
            empresas_geral.data_opcao_simples,
            empresas_geral.data_exclusao_simples,
            empresas_geral.opcao_mei,
            empresas_geral.data_opcao_mei,
            empresas_geral.data_exclusao_mei,
            empresas_geral.cnpj_basico_empresa,
            empresas_geral.razao_social,
            empresas_geral.natureza_juridica,
            empresas_geral.qualificacao_responsavel,
            empresas_geral.capital_social,
            empresas_geral.porte,
            empresas_geral.dt_raspagem,
            empresas_geral.descricao_naturezas_juridicas,
            empresas_geral.descricao_porte,
            empresas_geral.id_estabelecimento,
            empresas_geral.cnpj_basico_estabelecimento,
            empresas_geral.cnpj,
            empresas_geral.nome_fantasia,
            empresas_geral.cnae_fiscal_principal,
            empresas_geral.tipo_logradouro,
            empresas_geral.logradouro,
            empresas_geral.numero,
            empresas_geral.complemento,
            empresas_geral.bairro,
            empresas_geral.cep,
            empresas_geral.uf,
            empresas_geral.municipio,
            empresas_geral.ddd,
            empresas_geral.telefone,
            empresas_geral.email,
            empresas_geral.data_inicio_atividade,
            empresas_geral.execucao,
            empresas_geral.data_raspagem,
            empresas_geral.descricao_mun,
            empresas_geral.descricao_cnae,
            empresas_geral.cnae,
            empresas_geral.cod_secao,
            empresas_geral.desc_secao,
            empresas_geral.cod_divisao,
            empresas_geral.desc_divisao,
            empresas_geral.desc_grupo,
            empresas_geral.desc_classe,
            empresas_geral.desc_subclasse,
            empresas_geral.endereco_consulta,
            empresas_geral.latitude,
            empresas_geral.longitude,
            empresas_geral.precisao_geocoding,
            st_makepoint(empresas_geral.longitude::double precision, empresas_geral.latitude::double precision) AS geom
           FROM receitafederal.empresas_geral
          WHERE empresas_geral.precisao_geocoding <> 'APPROXIMATE'::text AND empresas_geral.descricao_mun::text ~~* '{{nm_mun_maiusculosemacento}}'::text) ee,
    ( SELECT DISTINCT ON (imoveis.gid) imoveis.gid AS gid_cliente,
            st_centroid(imoveis.geom) AS ponto,
            imoveis.cidade,
            imoveis.uf,
            (st_y(st_centroid(imoveis.geom)) || ','::text) || st_x(st_centroid(imoveis.geom)) AS latlonglote
           FROM esteira.imoveis) ef
  WHERE st_dwithin(ef.ponto::geography, ee.geom::geography, {{st_distance}}::double precision, true) AND (ef.cidade::text ~~* ANY (ARRAY['{{nm_mun}}'::text])) AND ef.uf::text = '{{nm_uf}}'::text
WITH DATA;

CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.int_mix
TABLESPACE pg_default
AS SELECT row_number() OVER (ORDER BY ee.classe) AS gid,
    ee.poligono_envolvente AS geom,
    ee.classe AS cd_int,
    ee.classe AS nm_int,
    ''::text AS tp_int,
    'Inteligência RFB'::text AS categoria,
    true AS ativo
   FROM ( SELECT st_convexhull(st_collect(x.raio)) AS poligono_envolvente,
            x.classe
           FROM ( SELECT fim.raio,
                    fim.classe,
                    fim.cluster_id
                   FROM ( WITH buffered_data AS (
                                 SELECT st_buffer(st_transform(st_setsrid(st_makepoint(x_2.longitude::double precision, x_2.latitude::double precision), 4326), {{src}}), 50::double precision) AS raio,
                                    x_2.classe
                                   FROM ( SELECT tir.classe,
    tc.longitude,
    tc.latitude
   FROM ( SELECT empresas_geral.date_part,
      empresas_geral.id,
      empresas_geral.address,
      empresas_geral.cnpj_basico_simples,
      empresas_geral.opcao_pelo_simples,
      empresas_geral.data_opcao_simples,
      empresas_geral.data_exclusao_simples,
      empresas_geral.opcao_mei,
      empresas_geral.data_opcao_mei,
      empresas_geral.data_exclusao_mei,
      empresas_geral.cnpj_basico_empresa,
      empresas_geral.razao_social,
      empresas_geral.natureza_juridica,
      empresas_geral.qualificacao_responsavel,
      empresas_geral.capital_social,
      empresas_geral.porte,
      empresas_geral.dt_raspagem,
      empresas_geral.descricao_naturezas_juridicas,
      empresas_geral.descricao_porte,
      empresas_geral.id_estabelecimento,
      empresas_geral.cnpj_basico_estabelecimento,
      empresas_geral.cnpj,
      empresas_geral.nome_fantasia,
      empresas_geral.cnae_fiscal_principal,
      empresas_geral.tipo_logradouro,
      empresas_geral.logradouro,
      empresas_geral.numero,
      empresas_geral.complemento,
      empresas_geral.bairro,
      empresas_geral.cep,
      empresas_geral.uf,
      empresas_geral.municipio,
      empresas_geral.ddd,
      empresas_geral.telefone,
      empresas_geral.email,
      empresas_geral.data_inicio_atividade,
      empresas_geral.execucao,
      empresas_geral.data_raspagem,
      empresas_geral.descricao_mun,
      empresas_geral.descricao_cnae,
      empresas_geral.cnae,
      empresas_geral.cod_secao,
      empresas_geral.desc_secao,
      empresas_geral.cod_divisao,
      empresas_geral.desc_divisao,
      empresas_geral.desc_grupo,
      empresas_geral.desc_classe,
      empresas_geral.desc_subclasse,
      empresas_geral.endereco_consulta,
      empresas_geral.latitude,
      empresas_geral.longitude,
      empresas_geral.precisao_geocoding
     FROM receitafederal.empresas_geral
    WHERE empresas_geral.precisao_geocoding <> 'APPROXIMATE'::text AND empresas_geral.descricao_mun::text ~~* '{{nm_mun_maiusculosemacento}}'::text) tc
     JOIN ( SELECT tb_indicadores.classe,
      tb_indicadores.codigo
     FROM apireceita.tb_indicadores
    WHERE tb_indicadores.classe::text = 'Armazém, Açougue e Hortifruti'::text) tir ON tc.cnae_fiscal_principal = tir.codigo::numeric) x_2
                                )
                         SELECT buffered_data.raio,
                            buffered_data.classe,
                            st_clusterdbscan(buffered_data.raio, eps => 40::double precision, minpoints => 5) OVER () AS cluster_id
                           FROM buffered_data) fim
                  WHERE fim.cluster_id IS NOT NULL) x
          GROUP BY x.classe, x.cluster_id
        UNION
         SELECT st_convexhull(st_collect(x.raio)) AS poligono_envolvente,
            x.classe
           FROM ( SELECT fim.raio,
                    fim.classe,
                    fim.cluster_id
                   FROM ( WITH buffered_data AS (
                                 SELECT st_buffer(st_transform(st_setsrid(st_makepoint(x_2.longitude::double precision, x_2.latitude::double precision), 4326), {{src}}), 50::double precision) AS raio,
                                    x_2.classe
                                   FROM ( SELECT tir.classe,
    tc.longitude,
    tc.latitude
   FROM ( SELECT empresas_geral.date_part,
      empresas_geral.id,
      empresas_geral.address,
      empresas_geral.cnpj_basico_simples,
      empresas_geral.opcao_pelo_simples,
      empresas_geral.data_opcao_simples,
      empresas_geral.data_exclusao_simples,
      empresas_geral.opcao_mei,
      empresas_geral.data_opcao_mei,
      empresas_geral.data_exclusao_mei,
      empresas_geral.cnpj_basico_empresa,
      empresas_geral.razao_social,
      empresas_geral.natureza_juridica,
      empresas_geral.qualificacao_responsavel,
      empresas_geral.capital_social,
      empresas_geral.porte,
      empresas_geral.dt_raspagem,
      empresas_geral.descricao_naturezas_juridicas,
      empresas_geral.descricao_porte,
      empresas_geral.id_estabelecimento,
      empresas_geral.cnpj_basico_estabelecimento,
      empresas_geral.cnpj,
      empresas_geral.nome_fantasia,
      empresas_geral.cnae_fiscal_principal,
      empresas_geral.tipo_logradouro,
      empresas_geral.logradouro,
      empresas_geral.numero,
      empresas_geral.complemento,
      empresas_geral.bairro,
      empresas_geral.cep,
      empresas_geral.uf,
      empresas_geral.municipio,
      empresas_geral.ddd,
      empresas_geral.telefone,
      empresas_geral.email,
      empresas_geral.data_inicio_atividade,
      empresas_geral.execucao,
      empresas_geral.data_raspagem,
      empresas_geral.descricao_mun,
      empresas_geral.descricao_cnae,
      empresas_geral.cnae,
      empresas_geral.cod_secao,
      empresas_geral.desc_secao,
      empresas_geral.cod_divisao,
      empresas_geral.desc_divisao,
      empresas_geral.desc_grupo,
      empresas_geral.desc_classe,
      empresas_geral.desc_subclasse,
      empresas_geral.endereco_consulta,
      empresas_geral.latitude,
      empresas_geral.longitude,
      empresas_geral.precisao_geocoding
     FROM receitafederal.empresas_geral
    WHERE empresas_geral.precisao_geocoding <> 'APPROXIMATE'::text AND empresas_geral.descricao_mun::text ~~* '{{nm_mun_maiusculosemacento}}'::text) tc
     JOIN ( SELECT tb_indicadores.classe,
      tb_indicadores.codigo
     FROM apireceita.tb_indicadores
    WHERE tb_indicadores.classe::text = 'Café, Lanchonete e Padaria'::text) tir ON tc.cnae_fiscal_principal = tir.codigo::numeric) x_2
                                )
                         SELECT buffered_data.raio,
                            buffered_data.classe,
                            st_clusterdbscan(buffered_data.raio, eps => 50::double precision, minpoints => 5) OVER () AS cluster_id
                           FROM buffered_data) fim
                  WHERE fim.cluster_id IS NOT NULL) x
          GROUP BY x.classe, x.cluster_id
        UNION
         SELECT st_convexhull(st_collect(x.raio)) AS poligono_envolvente,
            x.classe
           FROM ( SELECT fim.raio,
                    fim.classe,
                    fim.cluster_id
                   FROM ( WITH buffered_data AS (
                                 SELECT st_buffer(st_transform(st_setsrid(st_makepoint(x_2.longitude::double precision, x_2.latitude::double precision), 4326), {{src}}), 50::double precision) AS raio,
                                    x_2.classe
                                   FROM ( SELECT tir.classe,
    tc.longitude,
    tc.latitude
   FROM ( SELECT empresas_geral.date_part,
      empresas_geral.id,
      empresas_geral.address,
      empresas_geral.cnpj_basico_simples,
      empresas_geral.opcao_pelo_simples,
      empresas_geral.data_opcao_simples,
      empresas_geral.data_exclusao_simples,
      empresas_geral.opcao_mei,
      empresas_geral.data_opcao_mei,
      empresas_geral.data_exclusao_mei,
      empresas_geral.cnpj_basico_empresa,
      empresas_geral.razao_social,
      empresas_geral.natureza_juridica,
      empresas_geral.qualificacao_responsavel,
      empresas_geral.capital_social,
      empresas_geral.porte,
      empresas_geral.dt_raspagem,
      empresas_geral.descricao_naturezas_juridicas,
      empresas_geral.descricao_porte,
      empresas_geral.id_estabelecimento,
      empresas_geral.cnpj_basico_estabelecimento,
      empresas_geral.cnpj,
      empresas_geral.nome_fantasia,
      empresas_geral.cnae_fiscal_principal,
      empresas_geral.tipo_logradouro,
      empresas_geral.logradouro,
      empresas_geral.numero,
      empresas_geral.complemento,
      empresas_geral.bairro,
      empresas_geral.cep,
      empresas_geral.uf,
      empresas_geral.municipio,
      empresas_geral.ddd,
      empresas_geral.telefone,
      empresas_geral.email,
      empresas_geral.data_inicio_atividade,
      empresas_geral.execucao,
      empresas_geral.data_raspagem,
      empresas_geral.descricao_mun,
      empresas_geral.descricao_cnae,
      empresas_geral.cnae,
      empresas_geral.cod_secao,
      empresas_geral.desc_secao,
      empresas_geral.cod_divisao,
      empresas_geral.desc_divisao,
      empresas_geral.desc_grupo,
      empresas_geral.desc_classe,
      empresas_geral.desc_subclasse,
      empresas_geral.endereco_consulta,
      empresas_geral.latitude,
      empresas_geral.longitude,
      empresas_geral.precisao_geocoding
     FROM receitafederal.empresas_geral
    WHERE empresas_geral.precisao_geocoding <> 'APPROXIMATE'::text AND empresas_geral.descricao_mun::text ~~* '{{nm_mun_maiusculosemacento}}'::text) tc
     JOIN ( SELECT tb_indicadores.classe,
      tb_indicadores.codigo
     FROM apireceita.tb_indicadores
    WHERE tb_indicadores.classe::text = 'Comércio Atacadista'::text) tir ON tc.cnae_fiscal_principal = tir.codigo::numeric) x_2
                                )
                         SELECT buffered_data.raio,
                            buffered_data.classe,
                            st_clusterdbscan(buffered_data.raio, eps => 100::double precision, minpoints => 10) OVER () AS cluster_id
                           FROM buffered_data) fim
                  WHERE fim.cluster_id IS NOT NULL) x
          GROUP BY x.classe, x.cluster_id
        UNION
         SELECT st_convexhull(st_collect(x.raio)) AS poligono_envolvente,
            x.classe
           FROM ( SELECT fim.raio,
                    fim.classe,
                    fim.cluster_id
                   FROM ( WITH buffered_data AS (
                                 SELECT st_buffer(st_transform(st_setsrid(st_makepoint(x_2.longitude::double precision, x_2.latitude::double precision), 4326), {{src}}), 50::double precision) AS raio,
                                    x_2.classe
                                   FROM ( SELECT tir.classe,
    tc.longitude,
    tc.latitude
   FROM ( SELECT empresas_geral.date_part,
      empresas_geral.id,
      empresas_geral.address,
      empresas_geral.cnpj_basico_simples,
      empresas_geral.opcao_pelo_simples,
      empresas_geral.data_opcao_simples,
      empresas_geral.data_exclusao_simples,
      empresas_geral.opcao_mei,
      empresas_geral.data_opcao_mei,
      empresas_geral.data_exclusao_mei,
      empresas_geral.cnpj_basico_empresa,
      empresas_geral.razao_social,
      empresas_geral.natureza_juridica,
      empresas_geral.qualificacao_responsavel,
      empresas_geral.capital_social,
      empresas_geral.porte,
      empresas_geral.dt_raspagem,
      empresas_geral.descricao_naturezas_juridicas,
      empresas_geral.descricao_porte,
      empresas_geral.id_estabelecimento,
      empresas_geral.cnpj_basico_estabelecimento,
      empresas_geral.cnpj,
      empresas_geral.nome_fantasia,
      empresas_geral.cnae_fiscal_principal,
      empresas_geral.tipo_logradouro,
      empresas_geral.logradouro,
      empresas_geral.numero,
      empresas_geral.complemento,
      empresas_geral.bairro,
      empresas_geral.cep,
      empresas_geral.uf,
      empresas_geral.municipio,
      empresas_geral.ddd,
      empresas_geral.telefone,
      empresas_geral.email,
      empresas_geral.data_inicio_atividade,
      empresas_geral.execucao,
      empresas_geral.data_raspagem,
      empresas_geral.descricao_mun,
      empresas_geral.descricao_cnae,
      empresas_geral.cnae,
      empresas_geral.cod_secao,
      empresas_geral.desc_secao,
      empresas_geral.cod_divisao,
      empresas_geral.desc_divisao,
      empresas_geral.desc_grupo,
      empresas_geral.desc_classe,
      empresas_geral.desc_subclasse,
      empresas_geral.endereco_consulta,
      empresas_geral.latitude,
      empresas_geral.longitude,
      empresas_geral.precisao_geocoding
     FROM receitafederal.empresas_geral
    WHERE empresas_geral.precisao_geocoding <> 'APPROXIMATE'::text AND empresas_geral.descricao_mun::text ~~* '{{nm_mun_maiusculosemacento}}'::text) tc
     JOIN ( SELECT tb_indicadores.classe,
      tb_indicadores.codigo
     FROM apireceita.tb_indicadores
    WHERE tb_indicadores.classe::text = 'Comércio e Reparação de Peças e Veículos'::text) tir ON tc.cnae_fiscal_principal = tir.codigo::numeric) x_2
                                )
                         SELECT buffered_data.raio,
                            buffered_data.classe,
                            st_clusterdbscan(buffered_data.raio, eps => 100::double precision, minpoints => 15) OVER () AS cluster_id
                           FROM buffered_data) fim
                  WHERE fim.cluster_id IS NOT NULL) x
          GROUP BY x.classe, x.cluster_id
        UNION
         SELECT st_convexhull(st_collect(x.raio)) AS poligono_envolvente,
            x.classe
           FROM ( SELECT fim.raio,
                    fim.classe,
                    fim.cluster_id
                   FROM ( WITH buffered_data AS (
                                 SELECT st_buffer(st_transform(st_setsrid(st_makepoint(x_2.longitude::double precision, x_2.latitude::double precision), 4326), {{src}}), 50::double precision) AS raio,
                                    x_2.classe
                                   FROM ( SELECT tir.classe,
    tc.longitude,
    tc.latitude
   FROM ( SELECT empresas_geral.date_part,
      empresas_geral.id,
      empresas_geral.address,
      empresas_geral.cnpj_basico_simples,
      empresas_geral.opcao_pelo_simples,
      empresas_geral.data_opcao_simples,
      empresas_geral.data_exclusao_simples,
      empresas_geral.opcao_mei,
      empresas_geral.data_opcao_mei,
      empresas_geral.data_exclusao_mei,
      empresas_geral.cnpj_basico_empresa,
      empresas_geral.razao_social,
      empresas_geral.natureza_juridica,
      empresas_geral.qualificacao_responsavel,
      empresas_geral.capital_social,
      empresas_geral.porte,
      empresas_geral.dt_raspagem,
      empresas_geral.descricao_naturezas_juridicas,
      empresas_geral.descricao_porte,
      empresas_geral.id_estabelecimento,
      empresas_geral.cnpj_basico_estabelecimento,
      empresas_geral.cnpj,
      empresas_geral.nome_fantasia,
      empresas_geral.cnae_fiscal_principal,
      empresas_geral.tipo_logradouro,
      empresas_geral.logradouro,
      empresas_geral.numero,
      empresas_geral.complemento,
      empresas_geral.bairro,
      empresas_geral.cep,
      empresas_geral.uf,
      empresas_geral.municipio,
      empresas_geral.ddd,
      empresas_geral.telefone,
      empresas_geral.email,
      empresas_geral.data_inicio_atividade,
      empresas_geral.execucao,
      empresas_geral.data_raspagem,
      empresas_geral.descricao_mun,
      empresas_geral.descricao_cnae,
      empresas_geral.cnae,
      empresas_geral.cod_secao,
      empresas_geral.desc_secao,
      empresas_geral.cod_divisao,
      empresas_geral.desc_divisao,
      empresas_geral.desc_grupo,
      empresas_geral.desc_classe,
      empresas_geral.desc_subclasse,
      empresas_geral.endereco_consulta,
      empresas_geral.latitude,
      empresas_geral.longitude,
      empresas_geral.precisao_geocoding
     FROM receitafederal.empresas_geral
    WHERE empresas_geral.precisao_geocoding <> 'APPROXIMATE'::text AND empresas_geral.descricao_mun::text ~~* '{{nm_mun_maiusculosemacento}}'::text) tc
     JOIN ( SELECT tb_indicadores.classe,
      tb_indicadores.codigo
     FROM apireceita.tb_indicadores
    WHERE tb_indicadores.classe::text = 'Comércio Varejista'::text) tir ON tc.cnae_fiscal_principal = tir.codigo::numeric) x_2
                                )
                         SELECT buffered_data.raio,
                            buffered_data.classe,
                            st_clusterdbscan(buffered_data.raio, eps => 50::double precision, minpoints => 20) OVER () AS cluster_id
                           FROM buffered_data) fim
                  WHERE fim.cluster_id IS NOT NULL) x
          GROUP BY x.classe, x.cluster_id
        UNION
         SELECT st_convexhull(st_collect(x.raio)) AS poligono_envolvente,
            x.classe
           FROM ( SELECT fim.raio,
                    fim.classe,
                    fim.cluster_id
                   FROM ( WITH buffered_data AS (
                                 SELECT st_buffer(st_transform(st_setsrid(st_makepoint(x_2.longitude::double precision, x_2.latitude::double precision), 4326), {{src}}), 50::double precision) AS raio,
                                    x_2.classe
                                   FROM ( SELECT tir.classe,
    tc.longitude,
    tc.latitude
   FROM ( SELECT empresas_geral.date_part,
      empresas_geral.id,
      empresas_geral.address,
      empresas_geral.cnpj_basico_simples,
      empresas_geral.opcao_pelo_simples,
      empresas_geral.data_opcao_simples,
      empresas_geral.data_exclusao_simples,
      empresas_geral.opcao_mei,
      empresas_geral.data_opcao_mei,
      empresas_geral.data_exclusao_mei,
      empresas_geral.cnpj_basico_empresa,
      empresas_geral.razao_social,
      empresas_geral.natureza_juridica,
      empresas_geral.qualificacao_responsavel,
      empresas_geral.capital_social,
      empresas_geral.porte,
      empresas_geral.dt_raspagem,
      empresas_geral.descricao_naturezas_juridicas,
      empresas_geral.descricao_porte,
      empresas_geral.id_estabelecimento,
      empresas_geral.cnpj_basico_estabelecimento,
      empresas_geral.cnpj,
      empresas_geral.nome_fantasia,
      empresas_geral.cnae_fiscal_principal,
      empresas_geral.tipo_logradouro,
      empresas_geral.logradouro,
      empresas_geral.numero,
      empresas_geral.complemento,
      empresas_geral.bairro,
      empresas_geral.cep,
      empresas_geral.uf,
      empresas_geral.municipio,
      empresas_geral.ddd,
      empresas_geral.telefone,
      empresas_geral.email,
      empresas_geral.data_inicio_atividade,
      empresas_geral.execucao,
      empresas_geral.data_raspagem,
      empresas_geral.descricao_mun,
      empresas_geral.descricao_cnae,
      empresas_geral.cnae,
      empresas_geral.cod_secao,
      empresas_geral.desc_secao,
      empresas_geral.cod_divisao,
      empresas_geral.desc_divisao,
      empresas_geral.desc_grupo,
      empresas_geral.desc_classe,
      empresas_geral.desc_subclasse,
      empresas_geral.endereco_consulta,
      empresas_geral.latitude,
      empresas_geral.longitude,
      empresas_geral.precisao_geocoding
     FROM receitafederal.empresas_geral
    WHERE empresas_geral.precisao_geocoding <> 'APPROXIMATE'::text AND empresas_geral.descricao_mun::text ~~* '{{nm_mun_maiusculosemacento}}'::text) tc
     JOIN ( SELECT tb_indicadores.classe,
      tb_indicadores.codigo
     FROM apireceita.tb_indicadores
    WHERE tb_indicadores.classe::text = 'Consultório'::text) tir ON tc.cnae_fiscal_principal = tir.codigo::numeric) x_2
                                )
                         SELECT buffered_data.raio,
                            buffered_data.classe,
                            st_clusterdbscan(buffered_data.raio, eps => 100::double precision, minpoints => 20) OVER () AS cluster_id
                           FROM buffered_data) fim
                  WHERE fim.cluster_id IS NOT NULL) x
          GROUP BY x.classe, x.cluster_id
        UNION
         SELECT st_convexhull(st_collect(x.raio)) AS poligono_envolvente,
            x.classe
           FROM ( SELECT fim.raio,
                    fim.classe,
                    fim.cluster_id
                   FROM ( WITH buffered_data AS (
                                 SELECT st_buffer(st_transform(st_setsrid(st_makepoint(x_2.longitude::double precision, x_2.latitude::double precision), 4326), {{src}}), 50::double precision) AS raio,
                                    x_2.classe
                                   FROM ( SELECT tir.classe,
    tc.longitude,
    tc.latitude
   FROM ( SELECT empresas_geral.date_part,
      empresas_geral.id,
      empresas_geral.address,
      empresas_geral.cnpj_basico_simples,
      empresas_geral.opcao_pelo_simples,
      empresas_geral.data_opcao_simples,
      empresas_geral.data_exclusao_simples,
      empresas_geral.opcao_mei,
      empresas_geral.data_opcao_mei,
      empresas_geral.data_exclusao_mei,
      empresas_geral.cnpj_basico_empresa,
      empresas_geral.razao_social,
      empresas_geral.natureza_juridica,
      empresas_geral.qualificacao_responsavel,
      empresas_geral.capital_social,
      empresas_geral.porte,
      empresas_geral.dt_raspagem,
      empresas_geral.descricao_naturezas_juridicas,
      empresas_geral.descricao_porte,
      empresas_geral.id_estabelecimento,
      empresas_geral.cnpj_basico_estabelecimento,
      empresas_geral.cnpj,
      empresas_geral.nome_fantasia,
      empresas_geral.cnae_fiscal_principal,
      empresas_geral.tipo_logradouro,
      empresas_geral.logradouro,
      empresas_geral.numero,
      empresas_geral.complemento,
      empresas_geral.bairro,
      empresas_geral.cep,
      empresas_geral.uf,
      empresas_geral.municipio,
      empresas_geral.ddd,
      empresas_geral.telefone,
      empresas_geral.email,
      empresas_geral.data_inicio_atividade,
      empresas_geral.execucao,
      empresas_geral.data_raspagem,
      empresas_geral.descricao_mun,
      empresas_geral.descricao_cnae,
      empresas_geral.cnae,
      empresas_geral.cod_secao,
      empresas_geral.desc_secao,
      empresas_geral.cod_divisao,
      empresas_geral.desc_divisao,
      empresas_geral.desc_grupo,
      empresas_geral.desc_classe,
      empresas_geral.desc_subclasse,
      empresas_geral.endereco_consulta,
      empresas_geral.latitude,
      empresas_geral.longitude,
      empresas_geral.precisao_geocoding
     FROM receitafederal.empresas_geral
    WHERE empresas_geral.precisao_geocoding <> 'APPROXIMATE'::text AND empresas_geral.descricao_mun::text ~~* '{{nm_mun_maiusculosemacento}}'::text) tc
     JOIN ( SELECT tb_indicadores.classe,
      tb_indicadores.codigo
     FROM apireceita.tb_indicadores
    WHERE tb_indicadores.classe::text = 'Cultura, Arte e Entretenimento'::text) tir ON tc.cnae_fiscal_principal = tir.codigo::numeric) x_2
                                )
                         SELECT buffered_data.raio,
                            buffered_data.classe,
                            st_clusterdbscan(buffered_data.raio, eps => 200::double precision, minpoints => 5) OVER () AS cluster_id
                           FROM buffered_data) fim
                  WHERE fim.cluster_id IS NOT NULL) x
          GROUP BY x.classe, x.cluster_id
        UNION
         SELECT st_convexhull(st_collect(x.raio)) AS poligono_envolvente,
            x.classe
           FROM ( SELECT fim.raio,
                    fim.classe,
                    fim.cluster_id
                   FROM ( WITH buffered_data AS (
                                 SELECT st_buffer(st_transform(st_setsrid(st_makepoint(x_2.longitude::double precision, x_2.latitude::double precision), 4326), {{src}}), 50::double precision) AS raio,
                                    x_2.classe
                                   FROM ( SELECT tir.classe,
    tc.longitude,
    tc.latitude
   FROM ( SELECT empresas_geral.date_part,
      empresas_geral.id,
      empresas_geral.address,
      empresas_geral.cnpj_basico_simples,
      empresas_geral.opcao_pelo_simples,
      empresas_geral.data_opcao_simples,
      empresas_geral.data_exclusao_simples,
      empresas_geral.opcao_mei,
      empresas_geral.data_opcao_mei,
      empresas_geral.data_exclusao_mei,
      empresas_geral.cnpj_basico_empresa,
      empresas_geral.razao_social,
      empresas_geral.natureza_juridica,
      empresas_geral.qualificacao_responsavel,
      empresas_geral.capital_social,
      empresas_geral.porte,
      empresas_geral.dt_raspagem,
      empresas_geral.descricao_naturezas_juridicas,
      empresas_geral.descricao_porte,
      empresas_geral.id_estabelecimento,
      empresas_geral.cnpj_basico_estabelecimento,
      empresas_geral.cnpj,
      empresas_geral.nome_fantasia,
      empresas_geral.cnae_fiscal_principal,
      empresas_geral.tipo_logradouro,
      empresas_geral.logradouro,
      empresas_geral.numero,
      empresas_geral.complemento,
      empresas_geral.bairro,
      empresas_geral.cep,
      empresas_geral.uf,
      empresas_geral.municipio,
      empresas_geral.ddd,
      empresas_geral.telefone,
      empresas_geral.email,
      empresas_geral.data_inicio_atividade,
      empresas_geral.execucao,
      empresas_geral.data_raspagem,
      empresas_geral.descricao_mun,
      empresas_geral.descricao_cnae,
      empresas_geral.cnae,
      empresas_geral.cod_secao,
      empresas_geral.desc_secao,
      empresas_geral.cod_divisao,
      empresas_geral.desc_divisao,
      empresas_geral.desc_grupo,
      empresas_geral.desc_classe,
      empresas_geral.desc_subclasse,
      empresas_geral.endereco_consulta,
      empresas_geral.latitude,
      empresas_geral.longitude,
      empresas_geral.precisao_geocoding
     FROM receitafederal.empresas_geral
    WHERE empresas_geral.precisao_geocoding <> 'APPROXIMATE'::text AND empresas_geral.descricao_mun::text ~~* '{{nm_mun_maiusculosemacento}}'::text) tc
     JOIN ( SELECT tb_indicadores.classe,
      tb_indicadores.codigo
     FROM apireceita.tb_indicadores
    WHERE tb_indicadores.classe::text = 'Ensino Infantil e Médio'::text) tir ON tc.cnae_fiscal_principal = tir.codigo::numeric) x_2
                                )
                         SELECT buffered_data.raio,
                            buffered_data.classe,
                            st_clusterdbscan(buffered_data.raio, eps => 500::double precision, minpoints => 5) OVER () AS cluster_id
                           FROM buffered_data) fim
                  WHERE fim.cluster_id IS NOT NULL) x
          GROUP BY x.classe, x.cluster_id
        UNION
         SELECT st_convexhull(st_collect(x.raio)) AS poligono_envolvente,
            x.classe
           FROM ( SELECT fim.raio,
                    fim.classe,
                    fim.cluster_id
                   FROM ( WITH buffered_data AS (
                                 SELECT st_buffer(st_transform(st_setsrid(st_makepoint(x_2.longitude::double precision, x_2.latitude::double precision), 4326), {{src}}), 50::double precision) AS raio,
                                    x_2.classe
                                   FROM ( SELECT tir.classe,
    tc.longitude,
    tc.latitude
   FROM ( SELECT empresas_geral.date_part,
      empresas_geral.id,
      empresas_geral.address,
      empresas_geral.cnpj_basico_simples,
      empresas_geral.opcao_pelo_simples,
      empresas_geral.data_opcao_simples,
      empresas_geral.data_exclusao_simples,
      empresas_geral.opcao_mei,
      empresas_geral.data_opcao_mei,
      empresas_geral.data_exclusao_mei,
      empresas_geral.cnpj_basico_empresa,
      empresas_geral.razao_social,
      empresas_geral.natureza_juridica,
      empresas_geral.qualificacao_responsavel,
      empresas_geral.capital_social,
      empresas_geral.porte,
      empresas_geral.dt_raspagem,
      empresas_geral.descricao_naturezas_juridicas,
      empresas_geral.descricao_porte,
      empresas_geral.id_estabelecimento,
      empresas_geral.cnpj_basico_estabelecimento,
      empresas_geral.cnpj,
      empresas_geral.nome_fantasia,
      empresas_geral.cnae_fiscal_principal,
      empresas_geral.tipo_logradouro,
      empresas_geral.logradouro,
      empresas_geral.numero,
      empresas_geral.complemento,
      empresas_geral.bairro,
      empresas_geral.cep,
      empresas_geral.uf,
      empresas_geral.municipio,
      empresas_geral.ddd,
      empresas_geral.telefone,
      empresas_geral.email,
      empresas_geral.data_inicio_atividade,
      empresas_geral.execucao,
      empresas_geral.data_raspagem,
      empresas_geral.descricao_mun,
      empresas_geral.descricao_cnae,
      empresas_geral.cnae,
      empresas_geral.cod_secao,
      empresas_geral.desc_secao,
      empresas_geral.cod_divisao,
      empresas_geral.desc_divisao,
      empresas_geral.desc_grupo,
      empresas_geral.desc_classe,
      empresas_geral.desc_subclasse,
      empresas_geral.endereco_consulta,
      empresas_geral.latitude,
      empresas_geral.longitude,
      empresas_geral.precisao_geocoding
     FROM receitafederal.empresas_geral
    WHERE empresas_geral.precisao_geocoding <> 'APPROXIMATE'::text AND empresas_geral.descricao_mun::text ~~* '{{nm_mun_maiusculosemacento}}'::text) tc
     JOIN ( SELECT tb_indicadores.classe,
      tb_indicadores.codigo
     FROM apireceita.tb_indicadores
    WHERE tb_indicadores.classe::text = 'Ensino Superior e Técnico'::text) tir ON tc.cnae_fiscal_principal = tir.codigo::numeric) x_2
                                )
                         SELECT buffered_data.raio,
                            buffered_data.classe,
                            st_clusterdbscan(buffered_data.raio, eps => 500::double precision, minpoints => 5) OVER () AS cluster_id
                           FROM buffered_data) fim
                  WHERE fim.cluster_id IS NOT NULL) x
          GROUP BY x.classe, x.cluster_id
        UNION
         SELECT st_convexhull(st_collect(x.raio)) AS poligono_envolvente,
            x.classe
           FROM ( SELECT fim.raio,
                    fim.classe,
                    fim.cluster_id
                   FROM ( WITH buffered_data AS (
                                 SELECT st_buffer(st_transform(st_setsrid(st_makepoint(x_2.longitude::double precision, x_2.latitude::double precision), 4326), {{src}}), 50::double precision) AS raio,
                                    x_2.classe
                                   FROM ( SELECT tir.classe,
    tc.longitude,
    tc.latitude
   FROM ( SELECT empresas_geral.date_part,
      empresas_geral.id,
      empresas_geral.address,
      empresas_geral.cnpj_basico_simples,
      empresas_geral.opcao_pelo_simples,
      empresas_geral.data_opcao_simples,
      empresas_geral.data_exclusao_simples,
      empresas_geral.opcao_mei,
      empresas_geral.data_opcao_mei,
      empresas_geral.data_exclusao_mei,
      empresas_geral.cnpj_basico_empresa,
      empresas_geral.razao_social,
      empresas_geral.natureza_juridica,
      empresas_geral.qualificacao_responsavel,
      empresas_geral.capital_social,
      empresas_geral.porte,
      empresas_geral.dt_raspagem,
      empresas_geral.descricao_naturezas_juridicas,
      empresas_geral.descricao_porte,
      empresas_geral.id_estabelecimento,
      empresas_geral.cnpj_basico_estabelecimento,
      empresas_geral.cnpj,
      empresas_geral.nome_fantasia,
      empresas_geral.cnae_fiscal_principal,
      empresas_geral.tipo_logradouro,
      empresas_geral.logradouro,
      empresas_geral.numero,
      empresas_geral.complemento,
      empresas_geral.bairro,
      empresas_geral.cep,
      empresas_geral.uf,
      empresas_geral.municipio,
      empresas_geral.ddd,
      empresas_geral.telefone,
      empresas_geral.email,
      empresas_geral.data_inicio_atividade,
      empresas_geral.execucao,
      empresas_geral.data_raspagem,
      empresas_geral.descricao_mun,
      empresas_geral.descricao_cnae,
      empresas_geral.cnae,
      empresas_geral.cod_secao,
      empresas_geral.desc_secao,
      empresas_geral.cod_divisao,
      empresas_geral.desc_divisao,
      empresas_geral.desc_grupo,
      empresas_geral.desc_classe,
      empresas_geral.desc_subclasse,
      empresas_geral.endereco_consulta,
      empresas_geral.latitude,
      empresas_geral.longitude,
      empresas_geral.precisao_geocoding
     FROM receitafederal.empresas_geral
    WHERE empresas_geral.precisao_geocoding <> 'APPROXIMATE'::text AND empresas_geral.descricao_mun::text ~~* '{{nm_mun_maiusculosemacento}}'::text) tc
     JOIN ( SELECT tb_indicadores.classe,
      tb_indicadores.codigo
     FROM apireceita.tb_indicadores
    WHERE tb_indicadores.classe::text = 'Gastronômico'::text) tir ON tc.cnae_fiscal_principal = tir.codigo::numeric) x_2
                                )
                         SELECT buffered_data.raio,
                            buffered_data.classe,
                            st_clusterdbscan(buffered_data.raio, eps => 150::double precision, minpoints => 10) OVER () AS cluster_id
                           FROM buffered_data) fim
                  WHERE fim.cluster_id IS NOT NULL) x
          GROUP BY x.classe, x.cluster_id
        UNION
         SELECT st_convexhull(st_collect(x.raio)) AS poligono_envolvente,
            x.classe
           FROM ( SELECT fim.raio,
                    fim.classe,
                    fim.cluster_id
                   FROM ( WITH buffered_data AS (
                                 SELECT st_buffer(st_transform(st_setsrid(st_makepoint(x_2.longitude::double precision, x_2.latitude::double precision), 4326), {{src}}), 50::double precision) AS raio,
                                    x_2.classe
                                   FROM ( SELECT tir.classe,
    tc.longitude,
    tc.latitude
   FROM ( SELECT empresas_geral.date_part,
      empresas_geral.id,
      empresas_geral.address,
      empresas_geral.cnpj_basico_simples,
      empresas_geral.opcao_pelo_simples,
      empresas_geral.data_opcao_simples,
      empresas_geral.data_exclusao_simples,
      empresas_geral.opcao_mei,
      empresas_geral.data_opcao_mei,
      empresas_geral.data_exclusao_mei,
      empresas_geral.cnpj_basico_empresa,
      empresas_geral.razao_social,
      empresas_geral.natureza_juridica,
      empresas_geral.qualificacao_responsavel,
      empresas_geral.capital_social,
      empresas_geral.porte,
      empresas_geral.dt_raspagem,
      empresas_geral.descricao_naturezas_juridicas,
      empresas_geral.descricao_porte,
      empresas_geral.id_estabelecimento,
      empresas_geral.cnpj_basico_estabelecimento,
      empresas_geral.cnpj,
      empresas_geral.nome_fantasia,
      empresas_geral.cnae_fiscal_principal,
      empresas_geral.tipo_logradouro,
      empresas_geral.logradouro,
      empresas_geral.numero,
      empresas_geral.complemento,
      empresas_geral.bairro,
      empresas_geral.cep,
      empresas_geral.uf,
      empresas_geral.municipio,
      empresas_geral.ddd,
      empresas_geral.telefone,
      empresas_geral.email,
      empresas_geral.data_inicio_atividade,
      empresas_geral.execucao,
      empresas_geral.data_raspagem,
      empresas_geral.descricao_mun,
      empresas_geral.descricao_cnae,
      empresas_geral.cnae,
      empresas_geral.cod_secao,
      empresas_geral.desc_secao,
      empresas_geral.cod_divisao,
      empresas_geral.desc_divisao,
      empresas_geral.desc_grupo,
      empresas_geral.desc_classe,
      empresas_geral.desc_subclasse,
      empresas_geral.endereco_consulta,
      empresas_geral.latitude,
      empresas_geral.longitude,
      empresas_geral.precisao_geocoding
     FROM receitafederal.empresas_geral
    WHERE empresas_geral.precisao_geocoding <> 'APPROXIMATE'::text AND empresas_geral.descricao_mun::text ~~* '{{nm_mun_maiusculosemacento}}'::text) tc
     JOIN ( SELECT tb_indicadores.classe,
      tb_indicadores.codigo
     FROM apireceita.tb_indicadores
    WHERE tb_indicadores.classe::text = 'Hipermercado e Supermercado'::text) tir ON tc.cnae_fiscal_principal = tir.codigo::numeric) x_2
                                )
                         SELECT buffered_data.raio,
                            buffered_data.classe,
                            st_clusterdbscan(buffered_data.raio, eps => 500::double precision, minpoints => 4) OVER () AS cluster_id
                           FROM buffered_data) fim
                  WHERE fim.cluster_id IS NOT NULL) x
          GROUP BY x.classe, x.cluster_id
        UNION
         SELECT st_convexhull(st_collect(x.raio)) AS poligono_envolvente,
            x.classe
           FROM ( SELECT fim.raio,
                    fim.classe,
                    fim.cluster_id
                   FROM ( WITH buffered_data AS (
                                 SELECT st_buffer(st_transform(st_setsrid(st_makepoint(x_2.longitude::double precision, x_2.latitude::double precision), 4326), {{src}}), 50::double precision) AS raio,
                                    x_2.classe
                                   FROM ( SELECT tir.classe,
    tc.longitude,
    tc.latitude
   FROM ( SELECT empresas_geral.date_part,
      empresas_geral.id,
      empresas_geral.address,
      empresas_geral.cnpj_basico_simples,
      empresas_geral.opcao_pelo_simples,
      empresas_geral.data_opcao_simples,
      empresas_geral.data_exclusao_simples,
      empresas_geral.opcao_mei,
      empresas_geral.data_opcao_mei,
      empresas_geral.data_exclusao_mei,
      empresas_geral.cnpj_basico_empresa,
      empresas_geral.razao_social,
      empresas_geral.natureza_juridica,
      empresas_geral.qualificacao_responsavel,
      empresas_geral.capital_social,
      empresas_geral.porte,
      empresas_geral.dt_raspagem,
      empresas_geral.descricao_naturezas_juridicas,
      empresas_geral.descricao_porte,
      empresas_geral.id_estabelecimento,
      empresas_geral.cnpj_basico_estabelecimento,
      empresas_geral.cnpj,
      empresas_geral.nome_fantasia,
      empresas_geral.cnae_fiscal_principal,
      empresas_geral.tipo_logradouro,
      empresas_geral.logradouro,
      empresas_geral.numero,
      empresas_geral.complemento,
      empresas_geral.bairro,
      empresas_geral.cep,
      empresas_geral.uf,
      empresas_geral.municipio,
      empresas_geral.ddd,
      empresas_geral.telefone,
      empresas_geral.email,
      empresas_geral.data_inicio_atividade,
      empresas_geral.execucao,
      empresas_geral.data_raspagem,
      empresas_geral.descricao_mun,
      empresas_geral.descricao_cnae,
      empresas_geral.cnae,
      empresas_geral.cod_secao,
      empresas_geral.desc_secao,
      empresas_geral.cod_divisao,
      empresas_geral.desc_divisao,
      empresas_geral.desc_grupo,
      empresas_geral.desc_classe,
      empresas_geral.desc_subclasse,
      empresas_geral.endereco_consulta,
      empresas_geral.latitude,
      empresas_geral.longitude,
      empresas_geral.precisao_geocoding
     FROM receitafederal.empresas_geral
    WHERE empresas_geral.precisao_geocoding <> 'APPROXIMATE'::text AND empresas_geral.descricao_mun::text ~~* '{{nm_mun_maiusculosemacento}}'::text) tc
     JOIN ( SELECT tb_indicadores.classe,
      tb_indicadores.codigo
     FROM apireceita.tb_indicadores
    WHERE tb_indicadores.classe::text = 'Hospital e Clínica'::text) tir ON tc.cnae_fiscal_principal = tir.codigo::numeric) x_2
                                )
                         SELECT buffered_data.raio,
                            buffered_data.classe,
                            st_clusterdbscan(buffered_data.raio, eps => 200::double precision, minpoints => 10) OVER () AS cluster_id
                           FROM buffered_data) fim
                  WHERE fim.cluster_id IS NOT NULL) x
          GROUP BY x.classe, x.cluster_id
        UNION
         SELECT st_convexhull(st_collect(x.raio)) AS poligono_envolvente,
            x.classe
           FROM ( SELECT fim.raio,
                    fim.classe,
                    fim.cluster_id
                   FROM ( WITH buffered_data AS (
                                 SELECT st_buffer(st_transform(st_setsrid(st_makepoint(x_2.longitude::double precision, x_2.latitude::double precision), 4326), {{src}}), 50::double precision) AS raio,
                                    x_2.classe
                                   FROM ( SELECT tir.classe,
    tc.longitude,
    tc.latitude
   FROM ( SELECT empresas_geral.date_part,
      empresas_geral.id,
      empresas_geral.address,
      empresas_geral.cnpj_basico_simples,
      empresas_geral.opcao_pelo_simples,
      empresas_geral.data_opcao_simples,
      empresas_geral.data_exclusao_simples,
      empresas_geral.opcao_mei,
      empresas_geral.data_opcao_mei,
      empresas_geral.data_exclusao_mei,
      empresas_geral.cnpj_basico_empresa,
      empresas_geral.razao_social,
      empresas_geral.natureza_juridica,
      empresas_geral.qualificacao_responsavel,
      empresas_geral.capital_social,
      empresas_geral.porte,
      empresas_geral.dt_raspagem,
      empresas_geral.descricao_naturezas_juridicas,
      empresas_geral.descricao_porte,
      empresas_geral.id_estabelecimento,
      empresas_geral.cnpj_basico_estabelecimento,
      empresas_geral.cnpj,
      empresas_geral.nome_fantasia,
      empresas_geral.cnae_fiscal_principal,
      empresas_geral.tipo_logradouro,
      empresas_geral.logradouro,
      empresas_geral.numero,
      empresas_geral.complemento,
      empresas_geral.bairro,
      empresas_geral.cep,
      empresas_geral.uf,
      empresas_geral.municipio,
      empresas_geral.ddd,
      empresas_geral.telefone,
      empresas_geral.email,
      empresas_geral.data_inicio_atividade,
      empresas_geral.execucao,
      empresas_geral.data_raspagem,
      empresas_geral.descricao_mun,
      empresas_geral.descricao_cnae,
      empresas_geral.cnae,
      empresas_geral.cod_secao,
      empresas_geral.desc_secao,
      empresas_geral.cod_divisao,
      empresas_geral.desc_divisao,
      empresas_geral.desc_grupo,
      empresas_geral.desc_classe,
      empresas_geral.desc_subclasse,
      empresas_geral.endereco_consulta,
      empresas_geral.latitude,
      empresas_geral.longitude,
      empresas_geral.precisao_geocoding
     FROM receitafederal.empresas_geral
    WHERE empresas_geral.precisao_geocoding <> 'APPROXIMATE'::text AND empresas_geral.descricao_mun::text ~~* '{{nm_mun_maiusculosemacento}}'::text) tc
     JOIN ( SELECT tb_indicadores.classe,
      tb_indicadores.codigo
     FROM apireceita.tb_indicadores
    WHERE tb_indicadores.classe::text = 'Hipermercado e Supermercado'::text) tir ON tc.cnae_fiscal_principal = tir.codigo::numeric) x_2
                                )
                         SELECT buffered_data.raio,
                            buffered_data.classe,
                            st_clusterdbscan(buffered_data.raio, eps => 500::double precision, minpoints => 4) OVER () AS cluster_id
                           FROM buffered_data) fim
                  WHERE fim.cluster_id IS NOT NULL) x
          GROUP BY x.classe, x.cluster_id
        UNION
         SELECT st_convexhull(st_collect(x.raio)) AS poligono_envolvente,
            x.classe
           FROM ( SELECT fim.raio,
                    fim.classe,
                    fim.cluster_id
                   FROM ( WITH buffered_data AS (
                                 SELECT st_buffer(st_transform(st_setsrid(st_makepoint(x_2.longitude::double precision, x_2.latitude::double precision), 4326), {{src}}), 50::double precision) AS raio,
                                    x_2.classe
                                   FROM ( SELECT tir.classe,
    tc.longitude,
    tc.latitude
   FROM ( SELECT empresas_geral.date_part,
      empresas_geral.id,
      empresas_geral.address,
      empresas_geral.cnpj_basico_simples,
      empresas_geral.opcao_pelo_simples,
      empresas_geral.data_opcao_simples,
      empresas_geral.data_exclusao_simples,
      empresas_geral.opcao_mei,
      empresas_geral.data_opcao_mei,
      empresas_geral.data_exclusao_mei,
      empresas_geral.cnpj_basico_empresa,
      empresas_geral.razao_social,
      empresas_geral.natureza_juridica,
      empresas_geral.qualificacao_responsavel,
      empresas_geral.capital_social,
      empresas_geral.porte,
      empresas_geral.dt_raspagem,
      empresas_geral.descricao_naturezas_juridicas,
      empresas_geral.descricao_porte,
      empresas_geral.id_estabelecimento,
      empresas_geral.cnpj_basico_estabelecimento,
      empresas_geral.cnpj,
      empresas_geral.nome_fantasia,
      empresas_geral.cnae_fiscal_principal,
      empresas_geral.tipo_logradouro,
      empresas_geral.logradouro,
      empresas_geral.numero,
      empresas_geral.complemento,
      empresas_geral.bairro,
      empresas_geral.cep,
      empresas_geral.uf,
      empresas_geral.municipio,
      empresas_geral.ddd,
      empresas_geral.telefone,
      empresas_geral.email,
      empresas_geral.data_inicio_atividade,
      empresas_geral.execucao,
      empresas_geral.data_raspagem,
      empresas_geral.descricao_mun,
      empresas_geral.descricao_cnae,
      empresas_geral.cnae,
      empresas_geral.cod_secao,
      empresas_geral.desc_secao,
      empresas_geral.cod_divisao,
      empresas_geral.desc_divisao,
      empresas_geral.desc_grupo,
      empresas_geral.desc_classe,
      empresas_geral.desc_subclasse,
      empresas_geral.endereco_consulta,
      empresas_geral.latitude,
      empresas_geral.longitude,
      empresas_geral.precisao_geocoding
     FROM receitafederal.empresas_geral
    WHERE empresas_geral.precisao_geocoding <> 'APPROXIMATE'::text AND empresas_geral.descricao_mun::text ~~* '{{nm_mun_maiusculosemacento}}'::text) tc
     JOIN ( SELECT tb_indicadores.classe,
      tb_indicadores.codigo
     FROM apireceita.tb_indicadores
    WHERE tb_indicadores.classe::text = 'Hospedagem'::text) tir ON tc.cnae_fiscal_principal = tir.codigo::numeric) x_2
                                )
                         SELECT buffered_data.raio,
                            buffered_data.classe,
                            st_clusterdbscan(buffered_data.raio, eps => 200::double precision, minpoints => 10) OVER () AS cluster_id
                           FROM buffered_data) fim
                  WHERE fim.cluster_id IS NOT NULL) x
          GROUP BY x.classe, x.cluster_id
        UNION
         SELECT st_convexhull(st_collect(x.raio)) AS poligono_envolvente,
            x.classe
           FROM ( SELECT fim.raio,
                    fim.classe,
                    fim.cluster_id
                   FROM ( WITH buffered_data AS (
                                 SELECT st_buffer(st_transform(st_setsrid(st_makepoint(x_2.longitude::double precision, x_2.latitude::double precision), 4326), {{src}}), 50::double precision) AS raio,
                                    x_2.classe
                                   FROM ( SELECT tir.classe,
    tc.longitude,
    tc.latitude
   FROM ( SELECT empresas_geral.date_part,
      empresas_geral.id,
      empresas_geral.address,
      empresas_geral.cnpj_basico_simples,
      empresas_geral.opcao_pelo_simples,
      empresas_geral.data_opcao_simples,
      empresas_geral.data_exclusao_simples,
      empresas_geral.opcao_mei,
      empresas_geral.data_opcao_mei,
      empresas_geral.data_exclusao_mei,
      empresas_geral.cnpj_basico_empresa,
      empresas_geral.razao_social,
      empresas_geral.natureza_juridica,
      empresas_geral.qualificacao_responsavel,
      empresas_geral.capital_social,
      empresas_geral.porte,
      empresas_geral.dt_raspagem,
      empresas_geral.descricao_naturezas_juridicas,
      empresas_geral.descricao_porte,
      empresas_geral.id_estabelecimento,
      empresas_geral.cnpj_basico_estabelecimento,
      empresas_geral.cnpj,
      empresas_geral.nome_fantasia,
      empresas_geral.cnae_fiscal_principal,
      empresas_geral.tipo_logradouro,
      empresas_geral.logradouro,
      empresas_geral.numero,
      empresas_geral.complemento,
      empresas_geral.bairro,
      empresas_geral.cep,
      empresas_geral.uf,
      empresas_geral.municipio,
      empresas_geral.ddd,
      empresas_geral.telefone,
      empresas_geral.email,
      empresas_geral.data_inicio_atividade,
      empresas_geral.execucao,
      empresas_geral.data_raspagem,
      empresas_geral.descricao_mun,
      empresas_geral.descricao_cnae,
      empresas_geral.cnae,
      empresas_geral.cod_secao,
      empresas_geral.desc_secao,
      empresas_geral.cod_divisao,
      empresas_geral.desc_divisao,
      empresas_geral.desc_grupo,
      empresas_geral.desc_classe,
      empresas_geral.desc_subclasse,
      empresas_geral.endereco_consulta,
      empresas_geral.latitude,
      empresas_geral.longitude,
      empresas_geral.precisao_geocoding
     FROM receitafederal.empresas_geral
    WHERE empresas_geral.precisao_geocoding <> 'APPROXIMATE'::text AND empresas_geral.descricao_mun::text ~~* '{{nm_mun_maiusculosemacento}}'::text) tc
     JOIN ( SELECT tb_indicadores.classe,
      tb_indicadores.codigo
     FROM apireceita.tb_indicadores
    WHERE tb_indicadores.classe::text = 'Serviço Público'::text) tir ON tc.cnae_fiscal_principal = tir.codigo::numeric) x_2
                                )
                         SELECT buffered_data.raio,
                            buffered_data.classe,
                            st_clusterdbscan(buffered_data.raio, eps => 100::double precision, minpoints => 5) OVER () AS cluster_id
                           FROM buffered_data) fim
                  WHERE fim.cluster_id IS NOT NULL) x
          GROUP BY x.classe, x.cluster_id
        UNION
         SELECT st_convexhull(st_collect(x.raio)) AS poligono_envolvente,
            x.classe
           FROM ( SELECT fim.raio,
                    fim.classe,
                    fim.cluster_id
                   FROM ( WITH buffered_data AS (
                                 SELECT st_buffer(st_transform(st_setsrid(st_makepoint(x_2.longitude::double precision, x_2.latitude::double precision), 4326), {{src}}), 50::double precision) AS raio,
                                    x_2.classe
                                   FROM ( SELECT tir.classe,
    tc.longitude,
    tc.latitude
   FROM ( SELECT empresas_geral.date_part,
      empresas_geral.id,
      empresas_geral.address,
      empresas_geral.cnpj_basico_simples,
      empresas_geral.opcao_pelo_simples,
      empresas_geral.data_opcao_simples,
      empresas_geral.data_exclusao_simples,
      empresas_geral.opcao_mei,
      empresas_geral.data_opcao_mei,
      empresas_geral.data_exclusao_mei,
      empresas_geral.cnpj_basico_empresa,
      empresas_geral.razao_social,
      empresas_geral.natureza_juridica,
      empresas_geral.qualificacao_responsavel,
      empresas_geral.capital_social,
      empresas_geral.porte,
      empresas_geral.dt_raspagem,
      empresas_geral.descricao_naturezas_juridicas,
      empresas_geral.descricao_porte,
      empresas_geral.id_estabelecimento,
      empresas_geral.cnpj_basico_estabelecimento,
      empresas_geral.cnpj,
      empresas_geral.nome_fantasia,
      empresas_geral.cnae_fiscal_principal,
      empresas_geral.tipo_logradouro,
      empresas_geral.logradouro,
      empresas_geral.numero,
      empresas_geral.complemento,
      empresas_geral.bairro,
      empresas_geral.cep,
      empresas_geral.uf,
      empresas_geral.municipio,
      empresas_geral.ddd,
      empresas_geral.telefone,
      empresas_geral.email,
      empresas_geral.data_inicio_atividade,
      empresas_geral.execucao,
      empresas_geral.data_raspagem,
      empresas_geral.descricao_mun,
      empresas_geral.descricao_cnae,
      empresas_geral.cnae,
      empresas_geral.cod_secao,
      empresas_geral.desc_secao,
      empresas_geral.cod_divisao,
      empresas_geral.desc_divisao,
      empresas_geral.desc_grupo,
      empresas_geral.desc_classe,
      empresas_geral.desc_subclasse,
      empresas_geral.endereco_consulta,
      empresas_geral.latitude,
      empresas_geral.longitude,
      empresas_geral.precisao_geocoding
     FROM receitafederal.empresas_geral
    WHERE empresas_geral.precisao_geocoding <> 'APPROXIMATE'::text AND empresas_geral.descricao_mun::text ~~* '{{nm_mun_maiusculosemacento}}'::text) tc
     JOIN ( SELECT tb_indicadores.classe,
      tb_indicadores.codigo
     FROM apireceita.tb_indicadores
    WHERE tb_indicadores.classe::text = 'Hospedagem'::text) tir ON tc.cnae_fiscal_principal = tir.codigo::numeric) x_2
                                )
                         SELECT buffered_data.raio,
                            buffered_data.classe,
                            st_clusterdbscan(buffered_data.raio, eps => 200::double precision, minpoints => 10) OVER () AS cluster_id
                           FROM buffered_data) fim
                  WHERE fim.cluster_id IS NOT NULL) x
          GROUP BY x.classe, x.cluster_id
        UNION
         SELECT st_convexhull(st_collect(x.raio)) AS poligono_envolvente,
            x.classe
           FROM ( SELECT fim.raio,
                    fim.classe,
                    fim.cluster_id
                   FROM ( WITH buffered_data AS (
                                 SELECT st_buffer(st_transform(st_setsrid(st_makepoint(x_2.longitude::double precision, x_2.latitude::double precision), 4326), {{src}}), 50::double precision) AS raio,
                                    x_2.classe
                                   FROM ( SELECT tir.classe,
    tc.longitude,
    tc.latitude
   FROM ( SELECT empresas_geral.date_part,
      empresas_geral.id,
      empresas_geral.address,
      empresas_geral.cnpj_basico_simples,
      empresas_geral.opcao_pelo_simples,
      empresas_geral.data_opcao_simples,
      empresas_geral.data_exclusao_simples,
      empresas_geral.opcao_mei,
      empresas_geral.data_opcao_mei,
      empresas_geral.data_exclusao_mei,
      empresas_geral.cnpj_basico_empresa,
      empresas_geral.razao_social,
      empresas_geral.natureza_juridica,
      empresas_geral.qualificacao_responsavel,
      empresas_geral.capital_social,
      empresas_geral.porte,
      empresas_geral.dt_raspagem,
      empresas_geral.descricao_naturezas_juridicas,
      empresas_geral.descricao_porte,
      empresas_geral.id_estabelecimento,
      empresas_geral.cnpj_basico_estabelecimento,
      empresas_geral.cnpj,
      empresas_geral.nome_fantasia,
      empresas_geral.cnae_fiscal_principal,
      empresas_geral.tipo_logradouro,
      empresas_geral.logradouro,
      empresas_geral.numero,
      empresas_geral.complemento,
      empresas_geral.bairro,
      empresas_geral.cep,
      empresas_geral.uf,
      empresas_geral.municipio,
      empresas_geral.ddd,
      empresas_geral.telefone,
      empresas_geral.email,
      empresas_geral.data_inicio_atividade,
      empresas_geral.execucao,
      empresas_geral.data_raspagem,
      empresas_geral.descricao_mun,
      empresas_geral.descricao_cnae,
      empresas_geral.cnae,
      empresas_geral.cod_secao,
      empresas_geral.desc_secao,
      empresas_geral.cod_divisao,
      empresas_geral.desc_divisao,
      empresas_geral.desc_grupo,
      empresas_geral.desc_classe,
      empresas_geral.desc_subclasse,
      empresas_geral.endereco_consulta,
      empresas_geral.latitude,
      empresas_geral.longitude,
      empresas_geral.precisao_geocoding
     FROM receitafederal.empresas_geral
    WHERE empresas_geral.precisao_geocoding <> 'APPROXIMATE'::text AND empresas_geral.descricao_mun::text ~~* '{{nm_mun_maiusculosemacento}}'::text) tc
     JOIN ( SELECT tb_indicadores.classe,
      tb_indicadores.codigo
     FROM apireceita.tb_indicadores
    WHERE tb_indicadores.classe::text = 'Vida Noturna'::text) tir ON tc.cnae_fiscal_principal = tir.codigo::numeric) x_2
                                )
                         SELECT buffered_data.raio,
                            buffered_data.classe,
                            st_clusterdbscan(buffered_data.raio, eps => 100::double precision, minpoints => 5) OVER () AS cluster_id
                           FROM buffered_data) fim
                  WHERE fim.cluster_id IS NOT NULL) x
          GROUP BY x.classe, x.cluster_id) ee
WITH DATA;

-- View indexes:
CREATE INDEX IF NOT EXISTS idx_int_mix_geom ON geo_{{schema}}.int_mix USING gist (geom);

CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.int_area_valorizada
TABLESPACE pg_default
AS SELECT row_number() OVER (ORDER BY ee.classe) AS gid,
    ee.poligono_envolvente AS geom,
    ee.cd_int,
    ee.nm_int,
    ee.classe AS tp_int,
    'Inteligência Área Valorizada'::text AS categoria,
    true AS ativo
   FROM ( SELECT st_convexhull(st_collect(foo.raio)) AS poligono_envolvente,
            foo.classe,
            foo.cluster_id,
            'Apartamento'::text AS cd_int,
            'Área Valorizada Apartamento'::text AS nm_int
           FROM ( SELECT comdbscan.raio,
                    comdbscan.classe,
                    comdbscan.cluster_id
                   FROM ( WITH buffered_data AS (
                                 SELECT st_buffer(st_transform(subquery2.ponto, {{src}}), 50::double precision) AS raio, 
                                    'Área Valorizada'::text AS classe,
                                    subquery2.vm,
                                    subquery2.pct_rank,
                                    subquery2.bairro_tratado,
                                    subquery2.ponto
                                   FROM ( SELECT subquery.vm,
    percent_rank() OVER (PARTITION BY subquery.bairro_tratado ORDER BY subquery.vm) AS pct_rank,
    subquery.bairro_tratado,
    subquery.ponto
   FROM ( SELECT round((monit_geral.valor::integer / NULLIF(monit_geral.area::integer, 0))::numeric, 0) AS vm,
      monit_geral.area,
      monit_geral.valor,
      monit_geral.tipo_imovel,
      monit_geral.tipo_negocio,
      monit_geral.tipo_uso,
      monit_geral.cidade,
      monit_geral.bairro_tratado,
      monit_geral.precisao,
      monit_geral.ponto,
      monit_geral.lat,
      monit_geral.lon,
      monit_geral.data_tabela,
      (st_y(monit_geral.ponto) || ','::text) || st_x(monit_geral.ponto) AS latlong,
      (date_part('year'::text, monit_geral.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral.data_tabela)::text, 2, '0'::text) AS date_part
     FROM observatorio.monit_geral
    WHERE (monit_geral.cidade::text = ANY (ARRAY['{{nm_mun}}'::text])) AND monit_geral.tipo_negocio::text = 'Venda'::text AND monit_geral.tipo_imovel::text = 'Apartamento'::text AND monit_geral.ponto IS NOT NULL AND monit_geral.precisao = 4 AND (((date_part('year'::text, monit_geral.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral.data_tabela)::text, 2, '0'::text))::numeric IN ( SELECT max(((date_part('year'::text, monit_geral_1.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral_1.data_tabela)::text, 2, '0'::text))::numeric) AS data_tabela 
       FROM observatorio.monit_geral monit_geral_1
      WHERE monit_geral_1.cidade::text = '{{nm_mun}}'::text 
      GROUP BY monit_geral_1.data_tabela
     HAVING count(monit_geral_1.id) > 300
      ORDER BY (((date_part('year'::text, monit_geral_1.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral_1.data_tabela)::text, 2, '0'::text))::numeric) DESC
     LIMIT 1))) subquery) subquery2
                                  WHERE subquery2.pct_rank >= 0.75::double precision
                                )
                         SELECT buffered_data.raio,
                            buffered_data.classe,
                            st_clusterdbscan(buffered_data.raio, eps => 100::double precision, minpoints => 5) OVER () AS cluster_id
                           FROM buffered_data) comdbscan
                  WHERE comdbscan.cluster_id IS NOT NULL) foo
          GROUP BY foo.classe, foo.cluster_id
        UNION
         SELECT st_convexhull(st_collect(foo.raio)) AS poligono_envolvente,
            foo.classe,
            foo.cluster_id,
            'Galpão'::text AS cd_int,
            'Área Valorizada Galpão'::text AS nm_int
           FROM ( SELECT comdbscan.raio,
                    comdbscan.classe,
                    comdbscan.cluster_id
                   FROM ( WITH buffered_data AS (
                                 SELECT st_buffer(st_transform(subquery2.ponto, {{src}}), 50::double precision) AS raio,
                                    'Área Valorizada'::text AS classe,
                                    subquery2.vm,
                                    subquery2.pct_rank,
                                    subquery2.bairro_tratado,
                                    subquery2.ponto
                                   FROM ( SELECT subquery.vm,
    percent_rank() OVER (PARTITION BY subquery.bairro_tratado ORDER BY subquery.vm) AS pct_rank,
    subquery.bairro_tratado,
    subquery.ponto
   FROM ( SELECT round((monit_geral.valor::integer / NULLIF(monit_geral.area::integer, 0))::numeric, 0) AS vm,
      monit_geral.area,
      monit_geral.valor,
      monit_geral.tipo_imovel,
      monit_geral.tipo_negocio,
      monit_geral.tipo_uso,
      monit_geral.cidade,
      monit_geral.bairro_tratado,
      monit_geral.precisao,
      monit_geral.ponto,
      monit_geral.lat,
      monit_geral.lon,
      monit_geral.data_tabela,
      (st_y(monit_geral.ponto) || ','::text) || st_x(monit_geral.ponto) AS latlong,
      (date_part('year'::text, monit_geral.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral.data_tabela)::text, 2, '0'::text) AS date_part
     FROM observatorio.monit_geral
    WHERE (monit_geral.cidade::text = ANY (ARRAY['{{nm_mun}}'::text])) AND monit_geral.tipo_negocio::text = 'Venda'::text AND monit_geral.tipo_imovel::text = 'Galpão/Deoósito/Armazém'::text AND monit_geral.ponto IS NOT NULL AND monit_geral.precisao = 4 AND (((date_part('year'::text, monit_geral.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral.data_tabela)::text, 2, '0'::text))::numeric IN ( SELECT max(((date_part('year'::text, monit_geral_1.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral_1.data_tabela)::text, 2, '0'::text))::numeric) AS data_tabela 
       FROM observatorio.monit_geral monit_geral_1
      WHERE monit_geral_1.cidade::text = '{{nm_mun}}'::text 
      GROUP BY monit_geral_1.data_tabela
     HAVING count(monit_geral_1.id) > 300
      ORDER BY (((date_part('year'::text, monit_geral_1.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral_1.data_tabela)::text, 2, '0'::text))::numeric) DESC
     LIMIT 1))) subquery) subquery2
                                  WHERE subquery2.pct_rank >= 0.75::double precision
                                )
                         SELECT buffered_data.raio,
                            buffered_data.classe,
                            st_clusterdbscan(buffered_data.raio, eps => 100::double precision, minpoints => 5) OVER () AS cluster_id
                           FROM buffered_data) comdbscan
                  WHERE comdbscan.cluster_id IS NOT NULL) foo
          GROUP BY foo.classe, foo.cluster_id
        UNION
         SELECT st_convexhull(st_collect(foo.raio)) AS poligono_envolvente,
            foo.classe,
            foo.cluster_id,
            'Casa'::text AS cd_int,
            'Área Valorizada Casa'::text AS nm_int
           FROM ( SELECT comdbscan.raio,
                    comdbscan.classe,
                    comdbscan.cluster_id
                   FROM ( WITH buffered_data AS (
                                 SELECT st_buffer(st_transform(subquery2.ponto, {{src}}), 50::double precision) AS raio,
                                    'Área Valorizada'::text AS classe,
                                    subquery2.vm,
                                    subquery2.pct_rank,
                                    subquery2.bairro_tratado,
                                    subquery2.ponto
                                   FROM ( SELECT subquery.vm,
    percent_rank() OVER (PARTITION BY subquery.bairro_tratado ORDER BY subquery.vm) AS pct_rank,
    subquery.bairro_tratado,
    subquery.ponto
   FROM ( SELECT round((monit_geral.valor::integer / NULLIF(monit_geral.area::integer, 0))::numeric, 0) AS vm,
      monit_geral.area,
      monit_geral.valor,
      monit_geral.tipo_imovel,
      monit_geral.tipo_negocio,
      monit_geral.tipo_uso,
      monit_geral.cidade,
      monit_geral.bairro_tratado,
      monit_geral.precisao,
      monit_geral.ponto,
      monit_geral.lat,
      monit_geral.lon,
      monit_geral.data_tabela,
      (st_y(monit_geral.ponto) || ','::text) || st_x(monit_geral.ponto) AS latlong,
      (date_part('year'::text, monit_geral.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral.data_tabela)::text, 2, '0'::text) AS date_part
     FROM observatorio.monit_geral
    WHERE (monit_geral.cidade::text = ANY (ARRAY['{{nm_mun}}'::text])) AND monit_geral.tipo_negocio::text = 'Venda'::text AND monit_geral.tipo_imovel::text = 'Casa'::text AND monit_geral.ponto IS NOT NULL AND monit_geral.precisao = 4 AND (((date_part('year'::text, monit_geral.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral.data_tabela)::text, 2, '0'::text))::numeric IN ( SELECT max(((date_part('year'::text, monit_geral_1.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral_1.data_tabela)::text, 2, '0'::text))::numeric) AS data_tabela 
       FROM observatorio.monit_geral monit_geral_1
      WHERE monit_geral_1.cidade::text = 'nm_mun'::text 
      GROUP BY monit_geral_1.data_tabela
     HAVING count(monit_geral_1.id) > 300
      ORDER BY (((date_part('year'::text, monit_geral_1.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral_1.data_tabela)::text, 2, '0'::text))::numeric) DESC
     LIMIT 1))) subquery) subquery2
                                  WHERE subquery2.pct_rank >= 0.75::double precision
                                )
                         SELECT buffered_data.raio,
                            buffered_data.classe,
                            st_clusterdbscan(buffered_data.raio, eps => 100::double precision, minpoints => 5) OVER () AS cluster_id
                           FROM buffered_data) comdbscan
                  WHERE comdbscan.cluster_id IS NOT NULL) foo
          GROUP BY foo.classe, foo.cluster_id
        UNION
         SELECT st_convexhull(st_collect(foo.raio)) AS poligono_envolvente,
            foo.classe,
            foo.cluster_id,
            'Comercial'::text AS cd_int,
            'Área Valorizada Comercial'::text AS nm_int
           FROM ( SELECT comdbscan.raio,
                    comdbscan.classe,
                    comdbscan.cluster_id
                   FROM ( WITH buffered_data AS (
                                 SELECT st_buffer(st_transform(subquery2.ponto, {{src}}), 50::double precision) AS raio,
                                    'Área Valorizada'::text AS classe,
                                    subquery2.vm,
                                    subquery2.pct_rank,
                                    subquery2.bairro_tratado,
                                    subquery2.ponto
                                   FROM ( SELECT subquery.vm,
    percent_rank() OVER (PARTITION BY subquery.bairro_tratado ORDER BY subquery.vm) AS pct_rank,
    subquery.bairro_tratado,
    subquery.ponto
   FROM ( SELECT round((monit_geral.valor::integer / NULLIF(monit_geral.area::integer, 0))::numeric, 0) AS vm,
      monit_geral.area,
      monit_geral.valor,
      monit_geral.tipo_imovel,
      monit_geral.tipo_negocio,
      monit_geral.tipo_uso,
      monit_geral.cidade,
      monit_geral.bairro_tratado,
      monit_geral.precisao,
      monit_geral.ponto,
      monit_geral.lat,
      monit_geral.lon,
      monit_geral.data_tabela,
      (st_y(monit_geral.ponto) || ','::text) || st_x(monit_geral.ponto) AS latlong,
      (date_part('year'::text, monit_geral.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral.data_tabela)::text, 2, '0'::text) AS date_part
     FROM observatorio.monit_geral
    WHERE (monit_geral.cidade::text = ANY (ARRAY['{{nm_mun}}'::text])) AND monit_geral.tipo_negocio::text = 'Venda'::text AND (monit_geral.tipo_imovel::text = ANY (ARRAY['Imóvel Comercial'::text, 'Consultório'::text, 'Ponto Comercial/Loja/Box'::text])) AND monit_geral.ponto IS NOT NULL AND monit_geral.precisao = 4 AND (((date_part('year'::text, monit_geral.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral.data_tabela)::text, 2, '0'::text))::numeric IN ( SELECT max(((date_part('year'::text, monit_geral_1.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral_1.data_tabela)::text, 2, '0'::text))::numeric) AS data_tabela 
       FROM observatorio.monit_geral monit_geral_1
      WHERE monit_geral_1.cidade::text = '{{nm_mun}}'::text 
      GROUP BY monit_geral_1.data_tabela
     HAVING count(monit_geral_1.id) > 300
      ORDER BY (((date_part('year'::text, monit_geral_1.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral_1.data_tabela)::text, 2, '0'::text))::numeric) DESC
     LIMIT 1))) subquery) subquery2
                                  WHERE subquery2.pct_rank >= 0.75::double precision
                                )
                         SELECT buffered_data.raio,
                            buffered_data.classe,
                            st_clusterdbscan(buffered_data.raio, eps => 100::double precision, minpoints => 5) OVER () AS cluster_id
                           FROM buffered_data) comdbscan
                  WHERE comdbscan.cluster_id IS NOT NULL) foo
          GROUP BY foo.classe, foo.cluster_id) ee
WITH DATA;


CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.zon_int_previa
TABLESPACE pg_default
AS SELECT int_previa.gid,
    int_previa.gid_cliente,
    int_previa.cliente,
    int_previa.gid_int,
    int_previa.categoria,
    int_previa.ativo,
    int_previa.area_zon_atingimento,
    int_previa.area_do_terreno,
    int_previa.geometria_zon_atingimento,
    int_previa.geom_terreno,
    int_previa.cd_int,
    int_previa.tp_int,
    int_previa.nm_int
   FROM ( SELECT row_number() OVER (ORDER BY a.gid) AS gid,
            a.gid AS gid_cliente,
            a.cliente,
            b_1.gid AS gid_int,
            b_1.categoria,
            b_1.ativo,
            st_area(st_intersection_deprecated_by_postgis_301(a.geom_terreno, b_1.geom)) AS area_zon_atingimento,
            st_area(a.geom_terreno) AS area_do_terreno,
            st_intersection_deprecated_by_postgis_301(a.geom_terreno, b_1.geom) AS geometria_zon_atingimento,
            a.geom_terreno,
            b_1.cd_int,
            b_1.tp_int,
            b_1.nm_int
           FROM ( SELECT imoveis.gid,
                    imoveis.cliente,
                    imoveis.cidade,
                    imoveis.uf,
                    st_transform(imoveis.geom, {{src}}) AS geom_terreno
                   FROM esteira.imoveis
                  WHERE imoveis.cidade::text = '{{nm_mun}}'::text AND imoveis.uf::text = '{{nm_uf}}'::text) a
             LEFT JOIN ( SELECT int_mar.gid,
                    int_mar.geom,
                    int_mar.categoria,
                    int_mar.cd_int,
                    int_mar.tp_int,
                    int_mar.nm_int,
                    int_mar.ativo
                   FROM geo_{{schema}}.int_mar) b_1 ON b_1.geom && st_transform(a.geom_terreno, {{src}}) AND st_intersects(b_1.geom, st_transform(a.geom_terreno, {{src}}))
        UNION
         SELECT row_number() OVER (ORDER BY a.gid) AS gid,
            a.gid AS gid_cliente,
            a.cliente,
            b_1.gid AS gid_int,
            b_1.categoria,
            b_1.ativo,
            st_area(st_intersection_deprecated_by_postgis_301(a.geom_terreno, b_1.geom)) AS area_zon_atingimento,
            st_area(a.geom_terreno) AS area_do_terreno,
            st_intersection_deprecated_by_postgis_301(a.geom_terreno, b_1.geom) AS geometria_zon_atingimento,
            a.geom_terreno,
            b_1.cd_int,
            b_1.tp_int,
            b_1.nm_int
           FROM ( SELECT imoveis.gid,
                    imoveis.cliente,
                    imoveis.cidade,
                    imoveis.uf,
                    st_transform(imoveis.geom, {{src}}) AS geom_terreno
                   FROM esteira.imoveis
                  WHERE imoveis.cidade::text = '{{nm_mun}}'::text AND imoveis.uf::text = '{{nm_uf}}'::text) a
             LEFT JOIN ( SELECT int_lagoa.gid,
                    int_lagoa.geom,
                    int_lagoa.id,
                    int_lagoa.cd_int,
                    int_lagoa.nm_int,
                    int_lagoa.tp_int,
                    int_lagoa.categoria,
                    int_lagoa.ativo
                   FROM geo_{{schema}}.int_lagoa) b_1 ON b_1.geom && st_transform(a.geom_terreno, {{src}}) AND st_intersects(b_1.geom, st_transform(a.geom_terreno, {{src}}))
        UNION
         SELECT row_number() OVER (ORDER BY a.gid) AS gid,
            a.gid AS gid_cliente,
            a.cliente,
            b_1.gid AS gid_int,
            b_1.categoria,
            b_1.ativo,
            st_area(st_intersection_deprecated_by_postgis_301(a.geom_terreno, b_1.geom)) AS area_zon_atingimento,
            st_area(a.geom_terreno) AS area_do_terreno,
            st_intersection_deprecated_by_postgis_301(a.geom_terreno, b_1.geom) AS geometria_zon_atingimento,
            a.geom_terreno,
            b_1.cd_int,
            b_1.tp_int,
            b_1.nm_int
           FROM ( SELECT imoveis.gid,
                    imoveis.cliente,
                    imoveis.cidade,
                    imoveis.uf,
                    st_transform(imoveis.geom, {{src}}) AS geom_terreno
                   FROM esteira.imoveis
                  WHERE imoveis.cidade::text = '{{nm_mun}}'::text AND imoveis.uf::text = '{{nm_uf}}'::text) a
             JOIN ( SELECT int_vias_principais.gid,
                    int_vias_principais.geom,
                    int_vias_principais.cd_int,
                    int_vias_principais.nm_int,
                    int_vias_principais.tp_int,
                    int_vias_principais.categoria,
                    int_vias_principais.ativo
                   FROM geo_{{schema}}.int_vias_principais) b_1 ON b_1.geom && st_transform(a.geom_terreno, {{src}}) AND st_intersects(b_1.geom, st_transform(a.geom_terreno, {{src}}))) int_previa
UNION
 SELECT row_number() OVER (ORDER BY a.gid) AS gid,
    a.gid AS gid_cliente,
    a.cliente,
    b_1.gid AS gid_int,
    b_1.categoria,
    b_1.ativo,
    st_area(st_intersection_deprecated_by_postgis_301(a.geom_terreno, b_1.geom)) AS area_zon_atingimento,
    st_area(a.geom_terreno) AS area_do_terreno,
    st_intersection_deprecated_by_postgis_301(a.geom_terreno, b_1.geom) AS geometria_zon_atingimento,
    a.geom_terreno,
    b_1.cd_int,
    b_1.tp_int,
    b_1.nm_int
   FROM ( SELECT imoveis.gid,
            imoveis.cliente,
            imoveis.cidade,
            imoveis.uf,
            st_buffer(st_transform(imoveis.geom, {{src}}), 200::double precision) AS geom_terreno
           FROM esteira.imoveis
          WHERE imoveis.cidade::text = '{{nm_mun}}'::text AND imoveis.uf::text = '{{nm_uf}}'::text) a
     LEFT JOIN ( SELECT int_mix.gid,
            st_transform(int_mix.geom, {{src}}) AS geom,
            int_mix.cd_int,
            int_mix.nm_int,
            int_mix.tp_int,
            int_mix.categoria,
            int_mix.ativo
           FROM geo_{{schema}}.int_mix) b_1 ON st_intersects(b_1.geom, a.geom_terreno)
UNION
 SELECT row_number() OVER (ORDER BY a.gid) AS gid,
    a.gid AS gid_cliente,
    a.cliente,
    b_1.gid AS gid_int,
    b_1.categoria,
    b_1.ativo,
    st_area(st_intersection_deprecated_by_postgis_301(a.geom_terreno, b_1.geom)) AS area_zon_atingimento,
    st_area(a.geom_terreno) AS area_do_terreno,
    st_intersection_deprecated_by_postgis_301(a.geom_terreno, b_1.geom) AS geometria_zon_atingimento,
    a.geom_terreno,
    b_1.cd_int,
    b_1.tp_int,
    b_1.nm_int
   FROM ( SELECT imoveis.gid,
            imoveis.cliente,
            imoveis.cidade,
            imoveis.uf,
            st_transform(imoveis.geom, {{src}}) AS geom_terreno
           FROM esteira.imoveis
          WHERE imoveis.cidade::text = '{{nm_mun}}'::text AND imoveis.uf::text = '{{nm_uf}}'::text) a
     LEFT JOIN ( SELECT int_centro.gid,
            st_transform(int_centro.geom, {{src}}) AS geom,
            int_centro.cd_int,
            int_centro.nm_int,
            int_centro.tp_int,
            int_centro.categoria,
            int_centro.ativo
           FROM geo_{{schema}}.int_centro) b_1 ON b_1.geom && st_transform(a.geom_terreno, {{src}}) AND st_intersects(b_1.geom, st_transform(a.geom_terreno, {{src}}))
UNION
 SELECT row_number() OVER (ORDER BY a.gid) AS gid,
    a.gid AS gid_cliente,
    a.cliente,
    b_1.gid AS gid_int,
    b_1.categoria,
    b_1.ativo,
    st_area(st_intersection_deprecated_by_postgis_301(a.geom_terreno, b_1.geom)) AS area_zon_atingimento,
    st_area(a.geom_terreno) AS area_do_terreno,
    st_intersection_deprecated_by_postgis_301(a.geom_terreno, b_1.geom) AS geometria_zon_atingimento,
    a.geom_terreno,
    b_1.cd_int,
    b_1.tp_int,
    b_1.nm_int
   FROM ( SELECT imoveis.gid,
            imoveis.cliente,
            imoveis.cidade,
            imoveis.uf,
            st_buffer(st_transform(imoveis.geom, {{src}}), 200::double precision) AS geom_terreno
           FROM esteira.imoveis
          WHERE imoveis.cidade::text = '{{nm_mun}}'::text AND imoveis.uf::text = '{{nm_uf}}'::text) a
     LEFT JOIN ( SELECT int_mix.gid,
            st_transform(int_mix.geom, {{src}}) AS geom,
            int_mix.cd_int,
            int_mix.nm_int,
            int_mix.tp_int,
            int_mix.categoria,
            int_mix.ativo
           FROM geo_{{schema}}.int_mix) b_1 ON st_intersects(b_1.geom, a.geom_terreno)
UNION
 SELECT row_number() OVER (ORDER BY a.gid) AS gid,
    a.gid AS gid_cliente,
    a.cliente,
    b_1.gid AS gid_int,
    b_1.categoria,
    b_1.ativo,
    st_area(st_intersection_deprecated_by_postgis_301(a.geom_terreno, b_1.geom)) AS area_zon_atingimento,
    st_area(a.geom_terreno) AS area_do_terreno,
    st_intersection_deprecated_by_postgis_301(a.geom_terreno, b_1.geom) AS geometria_zon_atingimento,
    a.geom_terreno,
    b_1.cd_int,
    b_1.tp_int,
    b_1.nm_int
   FROM ( SELECT imoveis.gid,
            imoveis.cliente,
            imoveis.cidade,
            imoveis.uf,
            st_buffer(st_transform(imoveis.geom, {{src}}), 200::double precision) AS geom_terreno
           FROM esteira.imoveis
          WHERE imoveis.cidade::text = '{{nm_mun}}'::text AND imoveis.uf::text = '{{nm_uf}}'::text) a
     LEFT JOIN ( SELECT int_area_valorizada.gid,
            st_transform(int_area_valorizada.geom, {{src}}) AS geom,
            int_area_valorizada.cd_int,
            int_area_valorizada.nm_int,
            int_area_valorizada.tp_int,
            int_area_valorizada.categoria,
            int_area_valorizada.ativo
           FROM geo_{{schema}}.int_area_valorizada) b_1 ON st_intersects(b_1.geom, a.geom_terreno)
WITH DATA;


CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_inep
TABLESPACE pg_default
AS SELECT ee.no_entidade,
    ee.tp_dependencia_descricao,
    ee.tp_categoria_escola_privada_descricao,
    ee.tp_situacao_funcionamento_descricao,
    ee.nm_mun,
    ee.nm_estado,
    ee.endereco_consulta,
    ee.latitude,
    ee.longitude,
    ee.latlong,
    ee.precisao_geocoding,
    ee.geom2,
    ee.endereco_formatado,
    ee.nu_ano_censo,
    ee.no_regiao,
    ee.co_regiao,
    ee.tp_estado,
    ee.cd_estado,
    ee.cd_mun,
    ee.no_mesorregiao,
    ee.co_mesoregiao,
    ee.no_microrregiao,
    ee.co_microrregiao,
    ee.co_distrito,
    ee.co_entidade,
    ee.tp_dependencia,
    ee.tp_categoria_escola_privada,
    ee.tp_localizacao,
    ee.tp_localizacao_diferente,
    ee.nm_logr,
    ee.cd_logr,
    ee.ds_complemento,
    ee.nm_bairro,
    ee.co_cep,
    ee.nu_ddd,
    ee.nu_telefone,
    ee.tp_situacao_funcionamento,
    ee.co_orgao_regional,
    ee.dt_ano_letivo_inicio,
    ee.dt_ano_letivo_termino,
    ee.in_vinculo_secretaria_educacao,
    ee.in_vinculo_seguranca_publica,
    ee.in_vinculo_secretaria_saude,
    ee.in_vinculo_outro_orgao,
    ee.in_poder_publico_parceria,
    ee.tp_poder_publico_parceria,
    ee.in_conveniada_pp,
    ee.tp_convenio_poder_publico,
    ee.in_forma_cont_termo_colabora,
    ee.in_forma_cont_termo_fomento,
    ee.in_forma_cont_acordo_coop,
    ee.in_forma_cont_prestacao_serv,
    ee.in_forma_cont_coop_tec_fin,
    ee.in_forma_cont_consorcio_pub,
    ee.in_tipo_atend_escolarizacao,
    ee.in_tipo_atend_ac,
    ee.in_tipo_atend_aee,
    ee.in_mant_escola_privada_emp,
    ee.in_mant_escola_privada_ong,
    ee.in_mant_escola_privada_oscip,
    ee.in_mant_escola_priv_ong_oscip,
    ee.in_mant_escola_privada_sind,
    ee.in_mant_escola_privada_sist_s,
    ee.in_mant_escola_privada_s_fins,
    ee.nu_cnpj_escola_privada,
    ee.nu_cnpj_mantenedora,
    ee.tp_regulamentacao,
    ee.tp_responsavel_regulamentacao,
    ee.co_escola_sede_vinculada,
    ee.co_ies_ofertante,
    ee.in_local_func_predio_escolar,
    ee.tp_ocupacao_predio_escolar,
    ee.in_local_func_salas_empresa,
    ee.in_local_func_socioeducativo,
    ee.in_local_func_unid_prisional,
    ee.in_local_func_prisional_socio,
    ee.in_local_func_templo_igreja,
    ee.in_local_func_casa_professor,
    ee.in_local_func_galpao,
    ee.tp_ocupacao_galpao,
    ee.in_local_func_salas_outra_esc,
    ee.in_local_func_outros,
    ee.in_predio_compartilhado,
    ee.in_agua_filtrada,
    ee.in_agua_potavel,
    ee.in_agua_rede_publica,
    ee.in_agua_poco_artesiano,
    ee.in_agua_cacimba,
    ee.in_agua_fonte_rio,
    ee.in_agua_inexistente,
    ee.in_energia_rede_publica,
    ee.in_energia_gerador,
    ee.in_energia_gerador_fossil,
    ee.in_energia_outros,
    ee.in_energia_renovavel,
    ee.in_energia_inexistente,
    ee.in_esgoto_rede_publica,
    ee.in_esgoto_fossa_septica,
    ee.in_esgoto_fossa_comum,
    ee.in_esgoto_fossa,
    ee.in_esgoto_inexistente,
    ee.in_lixo_servico_coleta,
    ee.in_lixo_queima,
    ee.in_lixo_enterra,
    ee.in_lixo_destino_final_publico,
    ee.in_lixo_descarta_outra_area,
    ee.in_lixo_joga_outra_area,
    ee.in_lixo_outros,
    ee.in_lixo_recicla,
    ee.in_tratamento_lixo_separacao,
    ee.in_tratamento_lixo_reutiliza,
    ee.in_tratamento_lixo_reciclagem,
    ee.in_tratamento_lixo_inexistente,
    ee.in_almoxarifado,
    ee.in_area_verde,
    ee.in_auditorio,
    ee.in_banheiro_fora_predio,
    ee.in_banheiro_dentro_predio,
    ee.in_banheiro,
    ee.in_banheiro_ei,
    ee.in_banheiro_pne,
    ee.in_banheiro_funcionarios,
    ee.in_banheiro_chuveiro,
    ee.in_bercario,
    ee.in_biblioteca,
    ee.in_biblioteca_sala_leitura,
    ee.in_cozinha,
    ee.in_despensa,
    ee.in_dormitorio_aluno,
    ee.in_dormitorio_professor,
    ee.in_laboratorio_ciencias,
    ee.in_laboratorio_informatica,
    ee.in_laboratorio_educ_prof,
    ee.in_patio_coberto,
    ee.in_patio_descoberto,
    ee.in_parque_infantil,
    ee.in_piscina,
    ee.in_quadra_esportes,
    ee.in_quadra_esportes_coberta,
    ee.in_quadra_esportes_descoberta,
    ee.in_refeitorio,
    ee.in_sala_atelie_artes,
    ee.in_sala_musica_coral,
    ee.in_sala_estudio_danca,
    ee.in_sala_multiuso,
    ee.in_sala_oficinas_educ_prof,
    ee.in_sala_diretoria,
    ee.in_sala_leitura,
    ee.in_sala_professor,
    ee.in_sala_repouso_aluno,
    ee.in_secretaria,
    ee.in_sala_atendimento_especial,
    ee.in_terreirao,
    ee.in_viveiro,
    ee.in_dependencias_pne,
    ee.in_lavanderia,
    ee.in_dependencias_outras,
    ee.in_acessibilidade_corrimao,
    ee.in_acessibilidade_elevador,
    ee.in_acessibilidade_pisos_tateis,
    ee.in_acessibilidade_vao_livre,
    ee.in_acessibilidade_rampas,
    ee.in_acessibilidade_sinal_sonoro,
    ee.in_acessibilidade_sinal_tatil,
    ee.in_acessibilidade_sinal_visual,
    ee.in_acessibilidade_inexistente,
    ee.qt_salas_existentes,
    ee.qt_salas_utilizadas_dentro,
    ee.qt_salas_utilizadas_fora,
    ee.qt_salas_utilizadas,
    ee.qt_salas_utiliza_climatizadas,
    ee.qt_salas_utilizadas_acessiveis,
    ee.in_equip_parabolica,
    ee.in_computador,
    ee.in_equip_copiadora,
    ee.in_equip_impressora,
    ee.in_equip_impressora_mult,
    ee.in_equip_scanner,
    ee.in_equip_nenhum,
    ee.in_equip_dvd,
    ee.qt_equip_dvd,
    ee.in_equip_som,
    ee.qt_equip_som,
    ee.in_equip_tv,
    ee.qt_equip_tv,
    ee.in_equip_lousa_digital,
    ee.qt_equip_lousa_digital,
    ee.in_equip_multimidia,
    ee.qt_equip_multimidia,
    ee.in_equip_videocassete,
    ee.in_equip_retroprojetor,
    ee.in_equip_fax,
    ee.in_equip_foto,
    ee.qt_equip_videocassete,
    ee.qt_equip_parabolica,
    ee.qt_equip_copiadora,
    ee.qt_equip_retroprojetor,
    ee.qt_equip_impressora,
    ee.qt_equip_impressora_mult,
    ee.qt_equip_fax,
    ee.qt_equip_foto,
    ee.qt_comp_aluno,
    ee.in_desktop_aluno,
    ee.qt_desktop_aluno,
    ee.in_comp_portatil_aluno,
    ee.qt_comp_portatil_aluno,
    ee.in_tablet_aluno,
    ee.qt_tablet_aluno,
    ee.qt_computador,
    ee.qt_comp_administrativo,
    ee.in_internet,
    ee.in_internet_alunos,
    ee.in_internet_administrativo,
    ee.in_internet_aprendizagem,
    ee.in_internet_comunidade,
    ee.in_acesso_internet_computador,
    ee.in_aces_internet_disp_pessoais,
    ee.tp_rede_local,
    ee.in_banda_larga,
    ee.qt_funcionarios,
    ee.in_prof_administrativos,
    ee.qt_prof_administrativos,
    ee.in_prof_servicos_gerais,
    ee.qt_prof_servicos_gerais,
    ee.in_prof_bibliotecario,
    ee.qt_prof_bibliotecario,
    ee.in_prof_saude,
    ee.qt_prof_saude,
    ee.in_prof_coordenador,
    ee.qt_prof_coordenador,
    ee.in_prof_fonaudiologo,
    ee.qt_prof_fonaudiologo,
    ee.in_prof_nutricionista,
    ee.qt_prof_nutricionista,
    ee.in_prof_psicologo,
    ee.qt_prof_psicologo,
    ee.in_prof_alimentacao,
    ee.qt_prof_alimentacao,
    ee.in_prof_pedagogia,
    ee.qt_prof_pedagogia,
    ee.in_prof_secretario,
    ee.qt_prof_secretario,
    ee.in_prof_seguranca,
    ee.qt_prof_seguranca,
    ee.in_prof_monitores,
    ee.qt_prof_monitores,
    ee.in_prof_gestao,
    ee.qt_prof_gestao,
    ee.in_prof_assist_social,
    ee.qt_prof_assist_social,
    ee.in_alimentacao,
    ee.in_serie_ano,
    ee.in_periodos_semestrais,
    ee.in_fundamental_ciclos,
    ee.in_grupos_nao_seriados,
    ee.in_modulos,
    ee.in_formacao_alternancia,
    ee.in_material_ped_multimidia,
    ee.in_material_ped_infantil,
    ee.in_material_ped_cientifico,
    ee.in_material_ped_difusao,
    ee.in_material_ped_musical,
    ee.in_material_ped_jogos,
    ee.in_material_ped_artisticas,
    ee.in_material_ped_profissional,
    ee.in_material_ped_desportiva,
    ee.in_material_ped_indigena,
    ee.in_material_ped_etnico,
    ee.in_material_ped_campo,
    ee.in_material_ped_nenhum,
    ee.in_material_esp_quilombola,
    ee.in_material_esp_indigena,
    ee.in_material_esp_nao_utiliza,
    ee.in_educacao_indigena,
    ee.tp_indigena_lingua,
    ee.co_lingua_indigena_1,
    ee.co_lingua_indigena_2,
    ee.co_lingua_indigena_3,
    ee.in_brasil_alfabetizado,
    ee.in_final_semana,
    ee.in_exame_selecao,
    ee.in_reserva_ppi,
    ee.in_reserva_renda,
    ee.in_reserva_publica,
    ee.in_reserva_pcd,
    ee.in_reserva_outros,
    ee.in_reserva_nenhuma,
    ee.in_redes_sociais,
    ee.in_espaco_atividade,
    ee.in_espaco_equipamento,
    ee.in_orgao_ass_pais,
    ee.in_orgao_ass_pais_mestres,
    ee.in_orgao_conselho_escolar,
    ee.in_orgao_gremio_estudantil,
    ee.in_orgao_outros,
    ee.in_orgao_nenhum,
    ee.tp_proposta_pedagogica,
    ee.tp_aee,
    ee.tp_atividade_complementar,
    ee.in_escolarizacao,
    ee.in_mediacao_presencial,
    ee.in_mediacao_semipresencial,
    ee.in_mediacao_ead,
    ee.in_regular,
    ee.in_diurno,
    ee.in_noturno,
    ee.in_ead,
    ee.in_bas,
    ee.in_inf,
    ee.in_inf_cre,
    ee.in_inf_pre,
    ee.in_fund,
    ee.in_fund_ai,
    ee.in_fund_af,
    ee.in_med,
    ee.in_prof,
    ee.in_prof_tec,
    ee.in_eja,
    ee.in_eja_fund,
    ee.in_eja_med,
    ee.in_esp,
    ee.in_esp_cc,
    ee.in_esp_ce,
    ee.qt_mat_bas,
    ee.qt_mat_inf,
    ee.qt_mat_inf_cre,
    ee.qt_mat_inf_pre,
    ee.qt_mat_fund,
    ee.qt_mat_fund_ai,
    ee.qt_mat_fund_af,
    ee.qt_mat_med,
    ee.qt_mat_prof,
    ee.qt_mat_prof_tec,
    ee.qt_mat_eja,
    ee.qt_mat_eja_fund,
    ee.qt_mat_eja_med,
    ee.qt_mat_esp,
    ee.qt_mat_esp_cc,
    ee.qt_mat_esp_ce,
    ee.qt_mat_bas_fem,
    ee.qt_mat_bas_masc,
    ee.qt_mat_bas_nd,
    ee.qt_mat_bas_branca,
    ee.qt_mat_bas_preta,
    ee.qt_mat_bas_parda,
    ee.qt_mat_bas_amarela,
    ee.qt_mat_bas_indigena,
    ee.qt_mat_bas_0_3,
    ee.qt_mat_bas_4_5,
    ee.qt_mat_bas_6_10,
    ee.qt_mat_bas_11_14,
    ee.qt_mat_bas_15_17,
    ee.qt_mat_bas_18_mais,
    ee.qt_mat_bas_d,
    ee.qt_mat_bas_n,
    ee.qt_mat_bas_ead,
    ee.qt_mat_inf_int,
    ee.qt_mat_inf_cre_int,
    ee.qt_mat_inf_pre_int,
    ee.qt_mat_fund_int,
    ee.qt_mat_fund_ai_int,
    ee.qt_mat_fund_af_int,
    ee.qt_mat_med_int,
    ee.qt_doc_bas,
    ee.qt_doc_inf,
    ee.qt_doc_inf_cre,
    ee.qt_doc_inf_pre,
    ee.qt_doc_fund,
    ee.qt_doc_fund_ai,
    ee.qt_doc_fund_af,
    ee.qt_doc_med,
    ee.qt_doc_prof,
    ee.qt_doc_prof_tec,
    ee.qt_doc_eja,
    ee.qt_doc_eja_fund,
    ee.qt_doc_eja_med,
    ee.qt_doc_esp,
    ee.qt_doc_esp_cc,
    ee.qt_doc_esp_ce,
    ee.qt_tur_bas,
    ee.qt_tur_inf,
    ee.qt_tur_inf_cre,
    ee.qt_tur_inf_pre,
    ee.qt_tur_fund,
    ee.qt_tur_fund_ai,
    ee.qt_tur_fund_af,
    ee.qt_tur_med,
    ee.qt_tur_prof,
    ee.qt_tur_prof_tec,
    ee.qt_tur_eja,
    ee.qt_tur_eja_fund,
    ee.qt_tur_eja_med,
    ee.qt_tur_esp,
    ee.qt_tur_esp_cc,
    ee.qt_tur_esp_ce,
    ef.gid_cliente,
    ef.ponto,
    ef.cidade,
    ef.uf,
    ef.latlonglote,
    st_distance(ef.ponto::geography, ee.geom2::geography, true) AS st_distance
   FROM ( SELECT DISTINCT ON (aa.no_entidade) aa.no_entidade,
            ae.descricao AS tp_dependencia_descricao,
            ac.descricao AS tp_categoria_escola_privada_descricao,
            ad.descricao AS tp_situacao_funcionamento_descricao,
            aa.no_municipio AS nm_mun,
            aa.no_uf AS nm_estado,
            (((((((((aa.ds_endereco::text || ', '::text) || aa.nu_endereco::text) || ' - '::text) || aa.no_bairro::text) || ', '::text) || aa.no_municipio::text) || ' - '::text) || aa.sg_uf::text) || ', '::text) || aa.co_cep::text AS endereco_consulta,
            af.latitude,
            af.longitude,
            (af.latitude || ','::text) || af.longitude::text AS latlong,
            af.precisao_geocoding,
            st_makepoint(af.longitude::double precision, af.latitude::double precision) AS geom2,
            af.endereco_formatado,
            aa.nu_ano_censo::numeric AS nu_ano_censo,
            aa.no_regiao,
            aa.co_regiao::numeric AS co_regiao,
            aa.sg_uf AS tp_estado,
            aa.co_uf::numeric AS cd_estado,
            aa.co_municipio AS cd_mun,
            aa.no_mesorregiao,
            aa.co_mesorregiao::numeric AS co_mesoregiao,
            aa.no_microrregiao,
            aa.co_microrregiao::numeric AS co_microrregiao,
            aa.co_distrito::numeric AS co_distrito,
            aa.co_entidade::numeric AS co_entidade,
            aa.tp_dependencia::numeric AS tp_dependencia,
            NULLIF(aa.tp_categoria_escola_privada::text, ''::text)::numeric AS tp_categoria_escola_privada,
            aa.tp_localizacao::numeric AS tp_localizacao,
            NULLIF(aa.tp_localizacao_diferenciada::text, ''::text)::numeric AS tp_localizacao_diferente,
            initcap(aa.ds_endereco::text) AS nm_logr,
            aa.nu_endereco AS cd_logr,
            aa.ds_complemento,
            initcap(aa.no_bairro::text) AS nm_bairro,
            aa.co_cep,
            aa.nu_ddd,
            aa.nu_telefone,
            aa.tp_situacao_funcionamento,
            aa.co_orgao_regional,
            aa.dt_ano_letivo_inicio,
            aa.dt_ano_letivo_termino,
            aa.in_vinculo_secretaria_educacao,
            aa.in_vinculo_seguranca_publica,
            aa.in_vinculo_secretaria_saude,
            aa.in_vinculo_outro_orgao,
            aa.in_poder_publico_parceria,
            aa.tp_poder_publico_parceria,
            aa.in_conveniada_pp,
            aa.tp_convenio_poder_publico,
            aa.in_forma_cont_termo_colabora,
            aa.in_forma_cont_termo_fomento,
            aa.in_forma_cont_acordo_coop,
            aa.in_forma_cont_prestacao_serv,
            aa.in_forma_cont_coop_tec_fin,
            aa.in_forma_cont_consorcio_pub,
            aa.in_tipo_atend_escolarizacao,
            aa.in_tipo_atend_ac,
            aa.in_tipo_atend_aee,
            aa.in_mant_escola_privada_emp,
            aa.in_mant_escola_privada_ong,
            aa.in_mant_escola_privada_oscip,
            aa.in_mant_escola_priv_ong_oscip,
            aa.in_mant_escola_privada_sind,
            aa.in_mant_escola_privada_sist_s,
            aa.in_mant_escola_privada_s_fins,
            aa.nu_cnpj_escola_privada,
            aa.nu_cnpj_mantenedora,
            aa.tp_regulamentacao,
            aa.tp_responsavel_regulamentacao,
            aa.co_escola_sede_vinculada,
            aa.co_ies_ofertante,
            aa.in_local_func_predio_escolar,
            aa.tp_ocupacao_predio_escolar,
            aa.in_local_func_salas_empresa,
            aa.in_local_func_socioeducativo,
            aa.in_local_func_unid_prisional,
            aa.in_local_func_prisional_socio,
            aa.in_local_func_templo_igreja,
            aa.in_local_func_casa_professor,
            aa.in_local_func_galpao,
            aa.tp_ocupacao_galpao,
            aa.in_local_func_salas_outra_esc,
            aa.in_local_func_outros,
            aa.in_predio_compartilhado,
            aa.in_agua_filtrada,
            aa.in_agua_potavel,
            aa.in_agua_rede_publica,
            aa.in_agua_poco_artesiano,
            aa.in_agua_cacimba,
            aa.in_agua_fonte_rio,
            aa.in_agua_inexistente,
            aa.in_energia_rede_publica,
            aa.in_energia_gerador,
            aa.in_energia_gerador_fossil,
            aa.in_energia_outros,
            aa.in_energia_renovavel,
            aa.in_energia_inexistente,
            aa.in_esgoto_rede_publica,
            aa.in_esgoto_fossa_septica,
            aa.in_esgoto_fossa_comum,
            aa.in_esgoto_fossa,
            aa.in_esgoto_inexistente,
            aa.in_lixo_servico_coleta,
            aa.in_lixo_queima,
            aa.in_lixo_enterra,
            aa.in_lixo_destino_final_publico,
            aa.in_lixo_descarta_outra_area,
            aa.in_lixo_joga_outra_area,
            aa.in_lixo_outros,
            aa.in_lixo_recicla,
            aa.in_tratamento_lixo_separacao,
            aa.in_tratamento_lixo_reutiliza,
            aa.in_tratamento_lixo_reciclagem,
            aa.in_tratamento_lixo_inexistente,
            aa.in_almoxarifado,
            aa.in_area_verde,
            aa.in_auditorio,
            aa.in_banheiro_fora_predio,
            aa.in_banheiro_dentro_predio,
            aa.in_banheiro,
            aa.in_banheiro_ei,
            aa.in_banheiro_pne,
            aa.in_banheiro_funcionarios,
            aa.in_banheiro_chuveiro,
            aa.in_bercario,
            aa.in_biblioteca,
            aa.in_biblioteca_sala_leitura,
            aa.in_cozinha,
            aa.in_despensa,
            aa.in_dormitorio_aluno,
            aa.in_dormitorio_professor,
            aa.in_laboratorio_ciencias,
            aa.in_laboratorio_informatica,
            aa.in_laboratorio_educ_prof,
            aa.in_patio_coberto,
            aa.in_patio_descoberto,
            aa.in_parque_infantil,
            aa.in_piscina,
            aa.in_quadra_esportes,
            aa.in_quadra_esportes_coberta,
            aa.in_quadra_esportes_descoberta,
            aa.in_refeitorio,
            aa.in_sala_atelie_artes,
            aa.in_sala_musica_coral,
            aa.in_sala_estudio_danca,
            aa.in_sala_multiuso,
            aa.in_sala_oficinas_educ_prof,
            aa.in_sala_diretoria,
            aa.in_sala_leitura,
            aa.in_sala_professor,
            aa.in_sala_repouso_aluno,
            aa.in_secretaria,
            aa.in_sala_atendimento_especial,
            aa.in_terreirao,
            aa.in_viveiro,
            aa.in_dependencias_pne,
            aa.in_lavanderia,
            aa.in_dependencias_outras,
            aa.in_acessibilidade_corrimao,
            aa.in_acessibilidade_elevador,
            aa.in_acessibilidade_pisos_tateis,
            aa.in_acessibilidade_vao_livre,
            aa.in_acessibilidade_rampas,
            aa.in_acessibilidade_sinal_sonoro,
            aa.in_acessibilidade_sinal_tatil,
            aa.in_acessibilidade_sinal_visual,
            aa.in_acessibilidade_inexistente,
            aa.qt_salas_existentes,
            aa.qt_salas_utilizadas_dentro,
            aa.qt_salas_utilizadas_fora,
            aa.qt_salas_utilizadas,
            aa.qt_salas_utiliza_climatizadas,
            aa.qt_salas_utilizadas_acessiveis,
            aa.in_equip_parabolica,
            aa.in_computador,
            aa.in_equip_copiadora,
            aa.in_equip_impressora,
            aa.in_equip_impressora_mult,
            aa.in_equip_scanner,
            aa.in_equip_nenhum,
            aa.in_equip_dvd,
            aa.qt_equip_dvd,
            aa.in_equip_som,
            aa.qt_equip_som,
            aa.in_equip_tv,
            aa.qt_equip_tv,
            aa.in_equip_lousa_digital,
            aa.qt_equip_lousa_digital,
            aa.in_equip_multimidia,
            aa.qt_equip_multimidia,
            aa.in_equip_videocassete,
            aa.in_equip_retroprojetor,
            aa.in_equip_fax,
            aa.in_equip_foto,
            aa.qt_equip_videocassete,
            aa.qt_equip_parabolica,
            aa.qt_equip_copiadora,
            aa.qt_equip_retroprojetor,
            aa.qt_equip_impressora,
            aa.qt_equip_impressora_mult,
            aa.qt_equip_fax,
            aa.qt_equip_foto,
            aa.qt_comp_aluno,
            aa.in_desktop_aluno,
            aa.qt_desktop_aluno,
            aa.in_comp_portatil_aluno,
            aa.qt_comp_portatil_aluno,
            aa.in_tablet_aluno,
            aa.qt_tablet_aluno,
            aa.qt_computador,
            aa.qt_comp_administrativo,
            aa.in_internet,
            aa.in_internet_alunos,
            aa.in_internet_administrativo,
            aa.in_internet_aprendizagem,
            aa.in_internet_comunidade,
            aa.in_acesso_internet_computador,
            aa.in_aces_internet_disp_pessoais,
            aa.tp_rede_local,
            aa.in_banda_larga,
            aa.qt_funcionarios,
            aa.in_prof_administrativos,
            aa.qt_prof_administrativos,
            aa.in_prof_servicos_gerais,
            aa.qt_prof_servicos_gerais,
            aa.in_prof_bibliotecario,
            aa.qt_prof_bibliotecario,
            aa.in_prof_saude,
            aa.qt_prof_saude,
            aa.in_prof_coordenador,
            aa.qt_prof_coordenador,
            aa.in_prof_fonaudiologo,
            aa.qt_prof_fonaudiologo,
            aa.in_prof_nutricionista,
            aa.qt_prof_nutricionista,
            aa.in_prof_psicologo,
            aa.qt_prof_psicologo,
            aa.in_prof_alimentacao,
            aa.qt_prof_alimentacao,
            aa.in_prof_pedagogia,
            aa.qt_prof_pedagogia,
            aa.in_prof_secretario,
            aa.qt_prof_secretario,
            aa.in_prof_seguranca,
            aa.qt_prof_seguranca,
            aa.in_prof_monitores,
            aa.qt_prof_monitores,
            aa.in_prof_gestao,
            aa.qt_prof_gestao,
            aa.in_prof_assist_social,
            aa.qt_prof_assist_social,
            aa.in_alimentacao,
            aa.in_serie_ano,
            aa.in_periodos_semestrais,
            aa.in_fundamental_ciclos,
            aa.in_grupos_nao_seriados,
            aa.in_modulos,
            aa.in_formacao_alternancia,
            aa.in_material_ped_multimidia,
            aa.in_material_ped_infantil,
            aa.in_material_ped_cientifico,
            aa.in_material_ped_difusao,
            aa.in_material_ped_musical,
            aa.in_material_ped_jogos,
            aa.in_material_ped_artisticas,
            aa.in_material_ped_profissional,
            aa.in_material_ped_desportiva,
            aa.in_material_ped_indigena,
            aa.in_material_ped_etnico,
            aa.in_material_ped_campo,
            aa.in_material_ped_nenhum,
            aa.in_material_esp_quilombola,
            aa.in_material_esp_indigena,
            aa.in_material_esp_nao_utiliza,
            aa.in_educacao_indigena,
            aa.tp_indigena_lingua,
            aa.co_lingua_indigena_1,
            aa.co_lingua_indigena_2,
            aa.co_lingua_indigena_3,
            aa.in_brasil_alfabetizado,
            aa.in_final_semana,
            aa.in_exame_selecao,
            aa.in_reserva_ppi,
            aa.in_reserva_renda,
            aa.in_reserva_publica,
            aa.in_reserva_pcd,
            aa.in_reserva_outros,
            aa.in_reserva_nenhuma,
            aa.in_redes_sociais,
            aa.in_espaco_atividade,
            aa.in_espaco_equipamento,
            aa.in_orgao_ass_pais,
            aa.in_orgao_ass_pais_mestres,
            aa.in_orgao_conselho_escolar,
            aa.in_orgao_gremio_estudantil,
            aa.in_orgao_outros,
            aa.in_orgao_nenhum,
            aa.tp_proposta_pedagogica,
            aa.tp_aee,
            aa.tp_atividade_complementar,
            aa.in_escolarizacao,
            aa.in_mediacao_presencial,
            aa.in_mediacao_semipresencial,
            aa.in_mediacao_ead,
            aa.in_regular,
            aa.in_diurno,
            aa.in_noturno,
            aa.in_ead,
            aa.in_bas,
            aa.in_inf,
            aa.in_inf_cre,
            aa.in_inf_pre,
            aa.in_fund,
            aa.in_fund_ai,
            aa.in_fund_af,
            aa.in_med,
            aa.in_prof,
            aa.in_prof_tec,
            aa.in_eja,
            aa.in_eja_fund,
            aa.in_eja_med,
            aa.in_esp,
            aa.in_esp_cc,
            aa.in_esp_ce,
            aa.qt_mat_bas,
            aa.qt_mat_inf,
            aa.qt_mat_inf_cre,
            aa.qt_mat_inf_pre,
            aa.qt_mat_fund,
            aa.qt_mat_fund_ai,
            aa.qt_mat_fund_af,
            aa.qt_mat_med,
            aa.qt_mat_prof,
            aa.qt_mat_prof_tec,
            aa.qt_mat_eja,
            aa.qt_mat_eja_fund,
            aa.qt_mat_eja_med,
            aa.qt_mat_esp,
            aa.qt_mat_esp_cc,
            aa.qt_mat_esp_ce,
            aa.qt_mat_bas_fem,
            aa.qt_mat_bas_masc,
            aa.qt_mat_bas_nd,
            aa.qt_mat_bas_branca,
            aa.qt_mat_bas_preta,
            aa.qt_mat_bas_parda,
            aa.qt_mat_bas_amarela,
            aa.qt_mat_bas_indigena,
            aa.qt_mat_bas_0_3,
            aa.qt_mat_bas_4_5,
            aa.qt_mat_bas_6_10,
            aa.qt_mat_bas_11_14,
            aa.qt_mat_bas_15_17,
            aa.qt_mat_bas_18_mais,
            aa.qt_mat_bas_d,
            aa.qt_mat_bas_n,
            aa.qt_mat_bas_ead,
            aa.qt_mat_inf_int,
            aa.qt_mat_inf_cre_int,
            aa.qt_mat_inf_pre_int,
            aa.qt_mat_fund_int,
            aa.qt_mat_fund_ai_int,
            aa.qt_mat_fund_af_int,
            aa.qt_mat_med_int,
            aa.qt_doc_bas,
            aa.qt_doc_inf,
            aa.qt_doc_inf_cre,
            aa.qt_doc_inf_pre,
            aa.qt_doc_fund,
            aa.qt_doc_fund_ai,
            aa.qt_doc_fund_af,
            aa.qt_doc_med,
            aa.qt_doc_prof,
            aa.qt_doc_prof_tec,
            aa.qt_doc_eja,
            aa.qt_doc_eja_fund,
            aa.qt_doc_eja_med,
            aa.qt_doc_esp,
            aa.qt_doc_esp_cc,
            aa.qt_doc_esp_ce,
            aa.qt_tur_bas,
            aa.qt_tur_inf,
            aa.qt_tur_inf_cre,
            aa.qt_tur_inf_pre,
            aa.qt_tur_fund,
            aa.qt_tur_fund_ai,
            aa.qt_tur_fund_af,
            aa.qt_tur_med,
            aa.qt_tur_prof,
            aa.qt_tur_prof_tec,
            aa.qt_tur_eja,
            aa.qt_tur_eja_fund,
            aa.qt_tur_eja_med,
            aa.qt_tur_esp,
            aa.qt_tur_esp_cc,
            aa.qt_tur_esp_ce
           FROM inep.microdados_ed_basica aa
             LEFT JOIN inep.dic_tp_categoria_escola_privada ac ON aa.tp_categoria_escola_privada::text = ac.atributo::text
             LEFT JOIN inep.dic_tp_situacao_funcionamento ad ON aa.tp_situacao_funcionamento::text = ad.atributo::text
             LEFT JOIN inep.dic_tp_dependencia ae ON aa.tp_dependencia::text = ae.atributo::text
             LEFT JOIN inep.tb_localizacao af ON aa.no_entidade::text = af.no_entidade::text
          WHERE (aa.no_municipio::text = ANY (ARRAY['{{nm_mun}}'::text])) AND aa.sg_uf::text = '{{nm_uf}}'::text) ee,
    ( SELECT DISTINCT ON (imoveis.gid) imoveis.gid AS gid_cliente,
            st_centroid(imoveis.geom) AS ponto,
            imoveis.cidade,
            imoveis.uf,
            (st_y(st_centroid(imoveis.geom)) || ','::text) || st_x(st_centroid(imoveis.geom)) AS latlonglote
           FROM esteira.imoveis) ef
  WHERE st_dwithin(ef.ponto::geography, ee.geom2::geography, {{st_distance}}::double precision, true) AND ef.cidade::text = '{{nm_mun}}'::text AND ef.uf::text = '{{nm_uf}}'::text
WITH DATA;


CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_cnes
AS SELECT ee.id,
    ee.cnpj_mantenedora,
    ee.nm_mun,
    ee.nm_estado,
    ee.tp_gestao_descricao,
    ee.tp_unidade_descricao,
    ee.co_turno_atendimento_descricao,
    ee.co_natureza_jur_descicao,
    ee.co_atividade_descricao,
    ee.no_razao_social,
    ee.no_fantasia,
    ee.co_unidade,
    ee.cd_mun,
    ee.cd_estado,
    ee.tp_gestao,
    ee.tp_unidade,
    ee.co_turno_atendimento,
    ee.co_natureza_organizacao,
    ee.ds_natureza_organizacao,
    ee.co_nivel_hierarquia,
    ee.ds_nivel_hierarquia,
    ee.co_esfera_administrativa,
    ee.co_atividade,
    ee.co_cep,
    ee.nm_logr,
    ee.cd_logr,
    ee.nm_bairro,
    ee.nu_telefone,
    ee.latitude,
    ee.longitude,
    ee.latlong,
    ee.geom2,
    ee.ds_turno_atendimento,
    ee.nu_cnpj,
    ee.no_email,
    ee.co_natureza_jur,
    ee.st_centro_cirurgico,
    ee.st_centro_obstetrico,
    ee.st_centro_neonatal,
    ee.st_atend_hospitalar,
    ee.st_servico_apoio,
    ee.st_atend_ambulatorial,
    ee.co_motivo_desab,
    ee.co_ambulatorial_sus,
    ef.gid_cliente,
    ef.ponto,
    ef.cidade,
    ef.uf,
    ef.latlonglote,
    st_distance(ef.ponto::geography, ee.geom2::geography, true) AS st_distance
   FROM ( SELECT DISTINCT ON (aa.co_cnes) lpad(row_number() OVER ()::text, 13, '0'::text)::numeric AS id,
            NULLIF(aa.nu_cnpj_mantenedora::text, ''::text)::numeric AS cnpj_mantenedora,
            ab.descricao AS nm_mun,
            ac.descricao AS nm_estado,
            ad.descricao AS tp_gestao_descricao,
            initcap(ae.descricao::text) AS tp_unidade_descricao,
            af.descricao AS co_turno_atendimento_descricao,
            ag.descricao AS co_natureza_jur_descicao,
            initcap(ah.descricao::text) AS co_atividade_descricao,
            initcap(aa.no_razao_social) AS no_razao_social,
            initcap(aa.no_fantasia) AS no_fantasia,
            aa.co_unidade,
            aa.co_ibge::numeric AS cd_mun,
            aa.co_uf::numeric AS cd_estado,
            aa.tp_gestao,
            aa.tp_unidade::numeric AS tp_unidade,
            NULLIF(aa.co_turno_atendimento::text, ''::text)::numeric AS co_turno_atendimento,
            aa.co_natureza_organizacao,
            initcap(aa.ds_natureza_organizacao::text) AS ds_natureza_organizacao,
            NULLIF(aa.co_nivel_hierarquia::text, ''::text)::numeric AS co_nivel_hierarquia,
            aa.ds_nivel_hierarquia,
            NULLIF(aa.co_esfera_administrativa::text, ''::text)::numeric AS co_esfera_administrativa,
            NULLIF(aa.co_atividade::text, ''::text)::numeric AS co_atividade,
            NULLIF(aa.co_cep::text, ''::text)::numeric AS co_cep,
            initcap(aa.no_logradouro) AS nm_logr,
            aa.nu_endereco AS cd_logr,
            initcap(aa.no_bairro) AS nm_bairro,
            aa.nu_telefone,
            NULLIF(aa.nu_latitude::text, ''::text)::numeric AS latitude,
            NULLIF(aa.nu_longitude::text, ''::text)::numeric AS longitude,
            (aa.nu_latitude::text || ','::text) || aa.nu_longitude::text AS latlong,
            st_makepoint(NULLIF(aa.nu_longitude::text, ''::text)::numeric::double precision, NULLIF(aa.nu_latitude::text, ''::text)::numeric::double precision) AS geom2,
            initcap(aa.ds_turno_atendimento) AS ds_turno_atendimento,
            NULLIF(aa.nu_cnpj::text, ''::text)::numeric AS nu_cnpj,
            lower(aa.no_email) AS no_email,
            NULLIF(aa.co_natureza_jur::text, ''::text)::numeric AS co_natureza_jur,
            NULLIF(aa.st_centro_cirurgico::text, ''::text)::numeric AS st_centro_cirurgico,
            NULLIF(aa.st_centro_obstetrico::text, ''::text)::numeric AS st_centro_obstetrico,
            NULLIF(aa.st_centro_neonatal::text, ''::text)::numeric AS st_centro_neonatal,
            NULLIF(aa.st_atend_hospitalar::text, ''::text)::numeric AS st_atend_hospitalar,
            NULLIF(aa.st_servico_apoio::text, ''::text)::numeric AS st_servico_apoio,
            NULLIF(aa.st_atend_ambulatorial::text, ''::text)::numeric AS st_atend_ambulatorial,
            NULLIF(aa.co_motivo_desab::text, ''::text)::numeric AS co_motivo_desab,
            initcap(aa.co_ambulatorial_sus) AS co_ambulatorial_sus
           FROM cnes.cnes_estabelecimentos aa
             LEFT JOIN cnes.dic_co_ibge ab ON aa.co_ibge::text = ab.atributo::text
             LEFT JOIN cnes.dic_co_uf ac ON aa.co_uf::text = ac.atributo::text
             LEFT JOIN cnes.dic_tp_gestao ad ON aa.tp_gestao = ad.atributo::text
             LEFT JOIN cnes.dic_tp_unidade ae ON aa.tp_unidade::text = ae.atributo::text
             LEFT JOIN cnes.dic_turno_atendimento af ON NULLIF(aa.co_turno_atendimento::text, ''::text)::numeric = af.atributo
             LEFT JOIN cnes.dic_natureza_juridica ag ON NULLIF(aa.co_natureza_jur::text, ''::text) = ag.atributo::text
             LEFT JOIN cnes.dic_co_atividade ah ON aa.co_atividade::numeric = ah.atributo::numeric
          WHERE (ab.descricao::text ~~* ANY (ARRAY['{{nm_mun}}'::text])) AND ac.descricao::text = '{{nm_uf_extenso}}'::text) ee,
    ( SELECT DISTINCT ON (imoveis.gid) imoveis.gid AS gid_cliente,
            st_centroid(imoveis.geom) AS ponto,
            imoveis.cidade,
            imoveis.uf,
            (st_y(st_centroid(imoveis.geom)) || ','::text) || st_x(st_centroid(imoveis.geom)) AS latlonglote
           FROM esteira.imoveis) ef
  WHERE st_dwithin(ef.ponto::geography, ee.geom2::geography, {{st_distance}}::double precision, true) AND ef.cidade::text = '{{nm_mun}}'::text AND ef.uf::text = '{{nm_uf}}'::text
WITH DATA;


CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_pgt
TABLESPACE pg_default
AS SELECT a.gid_cliente,
    a.cliente,
    pgt.categoria,
    pgt.cluster_id,
    pgt.poligono_envolvente AS geom,
    round(st_distance(pgt.poligono_envolvente, a.geom_c)) AS st_distance,
    (st_y(st_transform(pgt.poligono_envolvente, 4326)) || ','::text) || st_x(st_transform(pgt.poligono_envolvente, 4326)) AS latlong
   FROM ( SELECT imoveis.gid AS gid_cliente,
            imoveis.cliente,
            imoveis.cidade,
            imoveis.uf,
            st_transform(imoveis.geom, {{src}}) AS geom_c
           FROM esteira.imoveis) a,
    ( SELECT sc3.categoria,
            sc3.cluster_id,
            st_centroid(st_convexhull(st_collect(sc3.geom))) AS poligono_envolvente
           FROM ( SELECT sc2.nome_fantasia,
                    sc2.valor_chave,
                    sc2.categoria,
                    sc2.geom,
                    st_clusterdbscan(sc2.geom, eps => 50::double precision, minpoints => 1) OVER () AS cluster_id
                   FROM ( SELECT sc1.nome_fantasia,
                            sc1.valor_chave,
                            sc1.categoria,
                            st_buffer(st_transform(sc1.geom, {{src}}), 50::double precision) AS geom
                           FROM ( SELECT efcs.name AS nome_fantasia,
                                    efcs.valor_chave,
                                    'Universidade'::text AS categoria,
                                    st_centroid(st_setsrid(efcs.geometria, 4326)) AS geom
                                   FROM apiosm.tb_elemento efcs
                                  WHERE efcs.valor_chave::text = 'university'::text) sc1) sc2) sc3
          GROUP BY sc3.cluster_id, sc3.categoria
        UNION
         SELECT sc3.categoria,
            sc3.cluster_id,
            st_centroid(st_convexhull(st_collect(sc3.geom))) AS poligono_envolvente
           FROM ( SELECT sc2.nome_fantasia,
                    sc2.valor_chave,
                    sc2.categoria,
                    sc2.geom,
                    st_clusterdbscan(sc2.geom, eps => 50::double precision, minpoints => 1) OVER () AS cluster_id
                   FROM ( SELECT sc1.nome_fantasia,
                            sc1.valor_chave,
                            sc1.categoria,
                            st_buffer(st_transform(sc1.geom, {{src}}), 50::double precision) AS geom
                           FROM ( SELECT efcs.name AS nome_fantasia,
                                    efcs.valor_chave,
                                    'Shopping'::text AS categoria,
                                    st_centroid(st_setsrid(efcs.geometria, 4326)) AS geom
                                   FROM apiosm.tb_elemento efcs
                                  WHERE efcs.valor_chave::text = ANY (ARRAY['mall'::text, 'department_store'::text, 'shopping_center'::text])) sc1) sc2) sc3
          GROUP BY sc3.cluster_id, sc3.categoria
        UNION
         SELECT sc3.categoria,
            sc3.cluster_id,
            st_centroid(st_convexhull(st_collect(sc3.geom))) AS poligono_envolvente
           FROM ( SELECT sc2.nome_fantasia,
                    sc2.valor_chave,
                    sc2.categoria,
                    sc2.geom,
                    st_clusterdbscan(sc2.geom, eps => 50::double precision, minpoints => 1) OVER () AS cluster_id
                   FROM ( SELECT sc1.nome_fantasia,
                            sc1.valor_chave,
                            sc1.categoria,
                            st_buffer(st_transform(sc1.geom, {{src}}), 50::double precision) AS geom
                           FROM ( SELECT efcs.name AS nome_fantasia,
                                    efcs.valor_chave,
                                    'Praia'::text AS categoria,
                                    st_centroid(st_setsrid(efcs.geometria, 4326)) AS geom
                                   FROM apiosm.tb_elemento efcs
                                  WHERE efcs.valor_chave::text = 'beach'::text) sc1) sc2) sc3
          GROUP BY sc3.cluster_id, sc3.categoria
        UNION
         SELECT sc3.categoria,
            sc3.cluster_id,
            st_centroid(st_convexhull(st_collect(sc3.geom))) AS poligono_envolvente
           FROM ( SELECT sc2.nome_fantasia,
                    sc2.valor_chave,
                    sc2.categoria,
                    sc2.geom,
                    st_clusterdbscan(sc2.geom, eps => 50::double precision, minpoints => 1) OVER () AS cluster_id
                   FROM ( SELECT sc1.nome_fantasia,
                            sc1.valor_chave,
                            sc1.categoria,
                            st_buffer(st_transform(sc1.geom, {{src}}), 50::double precision) AS geom
                           FROM ( SELECT efcs.name AS nome_fantasia,
                                    efcs.valor_chave,
                                    'Estádio'::text AS categoria,
                                    st_centroid(st_setsrid(efcs.geometria, 4326)) AS geom
                                   FROM apiosm.tb_elemento efcs
                                  WHERE efcs.valor_chave::text = 'stadium'::text) sc1) sc2) sc3
          GROUP BY sc3.cluster_id, sc3.categoria
        UNION
         SELECT sc3.categoria,
            sc3.cluster_id,
            st_centroid(st_convexhull(st_collect(sc3.geom))) AS poligono_envolvente
           FROM ( SELECT sc2.nome_fantasia,
                    sc2.valor_chave,
                    sc2.categoria,
                    sc2.geom,
                    st_clusterdbscan(sc2.geom, eps => 50::double precision, minpoints => 1) OVER () AS cluster_id
                   FROM ( SELECT sc1.nome_fantasia,
                            sc1.valor_chave,
                            sc1.categoria,
                            st_buffer(st_transform(sc1.geom, {{src}}), 50::double precision) AS geom
                           FROM ( SELECT efcs.name AS nome_fantasia,
                                    efcs.valor_chave,
                                    'Aeroporto'::text AS categoria,
                                    st_centroid(st_setsrid(efcs.geometria, 4326)) AS geom
                                   FROM apiosm.tb_elemento efcs
                                  WHERE efcs.valor_chave::text = 'aerodrome'::text) sc1) sc2) sc3
          GROUP BY sc3.cluster_id, sc3.categoria
        UNION
         SELECT sc3.categoria,
            sc3.cluster_id,
            st_centroid(st_convexhull(st_collect(sc3.geom))) AS poligono_envolvente
           FROM ( SELECT sc2.nome_fantasia,
                    sc2.valor_chave,
                    sc2.categoria,
                    sc2.geom,
                    st_clusterdbscan(sc2.geom, eps => 50::double precision, minpoints => 1) OVER () AS cluster_id
                   FROM ( SELECT sc1.nome_fantasia,
                            sc1.valor_chave,
                            sc1.categoria,
                            st_buffer(st_transform(sc1.geom, {{src}}), 50::double precision) AS geom
                           FROM ( SELECT efcs.name AS nome_fantasia,
                                    efcs.valor_chave,
                                    'Hospital'::text AS categoria,
                                    st_centroid(st_setsrid(efcs.geometria, 4326)) AS geom
                                   FROM apiosm.tb_elemento efcs
                                  WHERE efcs.valor_chave::text = 'hospital'::text) sc1) sc2) sc3
          GROUP BY sc3.cluster_id, sc3.categoria
        UNION
         SELECT sc3.categoria,
            sc3.cluster_id,
            st_centroid(st_convexhull(st_collect(sc3.geom))) AS poligono_envolvente
           FROM ( SELECT sc2.nome_fantasia,
                    sc2.valor_chave,
                    sc2.categoria,
                    sc2.geom,
                    st_clusterdbscan(sc2.geom, eps => 50::double precision, minpoints => 1) OVER () AS cluster_id
                   FROM ( SELECT sc1.nome_fantasia,
                            sc1.valor_chave,
                            sc1.categoria,
                            st_buffer(st_transform(sc1.geom, {{src}}), 50::double precision) AS geom
                           FROM ( SELECT efcs.name AS nome_fantasia,
                                    efcs.valor_chave,
                                    'Terminal Rodoviário ou Ferroviário'::text AS categoria,
                                    st_centroid(st_setsrid(efcs.geometria, 4326)) AS geom
                                   FROM apiosm.tb_elemento efcs
                                  WHERE efcs.valor_chave::text = ANY (ARRAY['station'::text, 'subway_entrance'::text, 'terminal'::text])) sc1) sc2) sc3
          GROUP BY sc3.cluster_id, sc3.categoria
        UNION
         SELECT sc3.categoria,
            sc3.cluster_id,
            st_centroid(st_convexhull(st_collect(sc3.geom))) AS poligono_envolvente
           FROM ( SELECT sc2.nome_fantasia,
                    sc2.valor_chave,
                    sc2.categoria,
                    sc2.geom,
                    st_clusterdbscan(sc2.geom, eps => 50::double precision, minpoints => 1) OVER () AS cluster_id
                   FROM ( SELECT sc1.nome_fantasia,
                            sc1.valor_chave,
                            sc1.categoria,
                            st_buffer(st_transform(sc1.geom, {{src}}), 50::double precision) AS geom
                           FROM ( SELECT efcs.name AS nome_fantasia,
                                    efcs.valor_chave,
                                    'Parque Diversão ou Zoológico'::text AS categoria,
                                    st_centroid(st_setsrid(efcs.geometria, 4326)) AS geom
                                   FROM apiosm.tb_elemento efcs
                                  WHERE efcs.valor_chave::text = ANY (ARRAY['amusement_park'::text, 'zoo'::text])) sc1) sc2) sc3
          GROUP BY sc3.cluster_id, sc3.categoria
        UNION
         SELECT sc3.categoria,
            sc3.cluster_id,
            st_centroid(st_convexhull(st_collect(sc3.geom))) AS poligono_envolvente
           FROM ( SELECT sc2.nome_fantasia,
                    sc2.valor_chave,
                    sc2.categoria,
                    sc2.geom,
                    st_clusterdbscan(sc2.geom, eps => 50::double precision, minpoints => 1) OVER () AS cluster_id
                   FROM ( SELECT sc1.nome_fantasia,
                            sc1.valor_chave,
                            sc1.categoria,
                            st_buffer(st_transform(sc1.geom, {{src}}), 50::double precision) AS geom
                           FROM ( SELECT efcs.name AS nome_fantasia,
                                    efcs.valor_chave,
                                    'Centros de Convenção'::text AS categoria,
                                    st_centroid(st_setsrid(efcs.geometria, 4326)) AS geom
                                   FROM apiosm.tb_elemento efcs
                                  WHERE efcs.valor_chave::text = 'conference_centre'::text) sc1) sc2) sc3
          GROUP BY sc3.cluster_id, sc3.categoria
        UNION
         SELECT sc3.categoria,
            sc3.cluster_id,
            st_centroid(st_convexhull(st_collect(sc3.geom))) AS poligono_envolvente
           FROM ( SELECT sc2.nome_fantasia,
                    sc2.valor_chave,
                    sc2.categoria,
                    sc2.geom,
                    st_clusterdbscan(sc2.geom, eps => 50::double precision, minpoints => 1) OVER () AS cluster_id
                   FROM ( SELECT sc1.nome_fantasia,
                            sc1.valor_chave,
                            sc1.categoria,
                            st_buffer(st_transform(sc1.geom, {{src}}), 50::double precision) AS geom
                           FROM ( SELECT efcs.name AS nome_fantasia,
                                    efcs.valor_chave,
                                    'Teatro, Cinema ou Museu'::text AS categoria,
                                    st_centroid(st_setsrid(efcs.geometria, 4326)) AS geom
                                   FROM apiosm.tb_elemento efcs
                                  WHERE efcs.valor_chave::text = ANY (ARRAY['theatre'::text, 'art_centre'::text, 'museum'::text, 'cinema'::text, 'gallery'::text, 'museum'::text])) sc1) sc2) sc3
          GROUP BY sc3.cluster_id, sc3.categoria
        UNION
         SELECT sc3.categoria,
            sc3.cluster_id,
            st_centroid(st_convexhull(st_collect(sc3.geom))) AS poligono_envolvente
           FROM ( SELECT sc2.nome_fantasia,
                    sc2.valor_chave,
                    sc2.categoria,
                    sc2.geom,
                    st_clusterdbscan(sc2.geom, eps => 50::double precision, minpoints => 1) OVER () AS cluster_id
                   FROM ( SELECT sc1.nome_fantasia,
                            sc1.valor_chave,
                            sc1.categoria,
                            st_buffer(st_transform(sc1.geom, {{src}}), 50::double precision) AS geom
                           FROM ( SELECT efcs.name AS nome_fantasia,
                                    efcs.valor_chave,
                                    'Parque ou Marina'::text AS categoria,
                                    st_centroid(st_setsrid(efcs.geometria, 4326)) AS geom
                                   FROM apiosm.tb_elemento efcs
                                  WHERE efcs.valor_chave::text = ANY (ARRAY['marina'::text, 'park'::text])) sc1) sc2) sc3
          GROUP BY sc3.cluster_id, sc3.categoria) pgt
  WHERE st_distance(a.geom_c, pgt.poligono_envolvente) <= {{st_distance}}::double precision AND (a.cidade::text = ANY (ARRAY['{{nm_mun}}'::text])) AND a.uf::text = '{{nm_uf}}'::text
WITH DATA;

CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_poi_osm
TABLESPACE pg_default
AS SELECT a.gid_cliente,
    a.cliente,
    pontosdeinteresse.geom,
    pontosdeinteresse.nome_fantasia,
    pontosdeinteresse.categoria,
    pontosdeinteresse.valor_chave,
    round(st_distance(pontosdeinteresse.geom::geography, a.geom_c::geography, true)::numeric, 2) AS st_distance,
    (st_y(pontosdeinteresse.geom) || ','::text) || st_x(pontosdeinteresse.geom) AS latlong
   FROM ( SELECT imoveis.gid AS gid_cliente,
            imoveis.cliente,
            imoveis.cidade,
            imoveis.uf,
            imoveis.geom AS geom_c
           FROM esteira.imoveis) a,
    ( SELECT efcs.name AS nome_fantasia,
            efcs.valor_chave,
            'Mercados'::text AS categoria,
            st_centroid(st_setsrid(efcs.geometria, 4326)) AS geom
           FROM apiosm.tb_elemento efcs
          WHERE efcs.valor_chave::text = 'supermarket'::text
        UNION
         SELECT efcs.name AS nome_fantasia,
            efcs.valor_chave,
            'Restaurantes'::text AS categoria,
            st_centroid(st_setsrid(efcs.geometria, 4326)) AS geom
           FROM apiosm.tb_elemento efcs
          WHERE efcs.valor_chave::text = 'restaurant'::text
        UNION
         SELECT efcs.name AS nome_fantasia,
            efcs.valor_chave,
            'Fast foods'::text AS categoria,
            st_centroid(st_setsrid(efcs.geometria, 4326)) AS geom
           FROM apiosm.tb_elemento efcs
          WHERE efcs.valor_chave::text = 'fast_food'::text
        UNION
         SELECT efcs.name AS nome_fantasia,
            efcs.valor_chave,
            'Padarias'::text AS categoria,
            st_centroid(st_setsrid(efcs.geometria, 4326)) AS geom
           FROM apiosm.tb_elemento efcs
          WHERE efcs.valor_chave::text = 'bakery'::text OR efcs.valor_chave::text = 'cafe'::text
        UNION
         SELECT efcs.name AS nome_fantasia,
            efcs.valor_chave,
            'Bancos'::text AS categoria,
            st_centroid(st_setsrid(efcs.geometria, 4326)) AS geom
           FROM apiosm.tb_elemento efcs
          WHERE efcs.valor_chave::text = 'bank'::text OR efcs.valor_chave::text = 'cafe'::text
        UNION
         SELECT efcs.name AS nome_fantasia,
            efcs.valor_chave,
            'Bar'::text AS categoria,
            st_centroid(st_setsrid(efcs.geometria, 4326)) AS geom
           FROM apiosm.tb_elemento efcs
          WHERE efcs.valor_chave::text = 'bar'::text
        UNION
         SELECT efcs.name AS nome_fantasia,
            efcs.valor_chave,
            'Farmácias'::text AS categoria,
            st_centroid(st_setsrid(efcs.geometria, 4326)) AS geom
           FROM apiosm.tb_elemento efcs
          WHERE efcs.valor_chave::text = 'pharmacy'::text
        UNION
         SELECT efcs.name AS nome_fantasia,
            efcs.valor_chave,
            'Postos de Gasolina'::text AS categoria,
            st_centroid(st_setsrid(efcs.geometria, 4326)) AS geom
           FROM apiosm.tb_elemento efcs
          WHERE efcs.valor_chave::text = 'fuel'::text
        UNION
         SELECT efcs.name AS nome_fantasia,
            efcs.valor_chave,
            'Igrejas'::text AS categoria,
            st_centroid(st_setsrid(efcs.geometria, 4326)) AS geom
           FROM apiosm.tb_elemento efcs
          WHERE efcs.valor_chave::text = 'place_of_worship'::text
        UNION
         SELECT efcs.name AS nome_fantasia,
            efcs.valor_chave,
            'Hotels'::text AS categoria,
            st_centroid(st_setsrid(efcs.geometria, 4326)) AS geom
           FROM apiosm.tb_elemento efcs
          WHERE efcs.valor_chave::text = 'hotel'::text
        UNION
         SELECT efcs.name AS nome_fantasia,
            efcs.valor_chave,
            'Hostels'::text AS categoria,
            st_centroid(st_setsrid(efcs.geometria, 4326)) AS geom
           FROM apiosm.tb_elemento efcs
          WHERE efcs.valor_chave::text = 'hostel'::text) pontosdeinteresse
  WHERE st_dwithin(a.geom_c::geography, pontosdeinteresse.geom::geography, {{st_distance}}::double precision, true) AND (a.cidade::text = ANY (ARRAY['{{nm_mun}}'::text])) AND a.uf::text = '{{nm_uf}}'::text
WITH DATA;


CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_cno
TABLESPACE pg_default
AS SELECT ee.id,
    ee.cno,
    ee.cnae,
    ee.cno_cnae_descricao,
    ee.destinacao,
    ee.categoria,
    ee.tipo_area,
    ee.area_total,
    ee.situacao,
    ee.situacao_descricao,
    ee.data_inicio,
    ee.data_situacao,
    ee.nome_empresarial,
    ee.endereco_consulta,
    ee.data_registro,
    ee.latitude,
    ee.longitude,
    ee.latlong,
    ee.geom2,
    ee.precisao_geocoding,
    ee.endereco_formatado,
    ee.ni_responsavel_vinculo,
    ee.cd_pais,
    ee.nm_pais,
    ee.data_inicio_responsabilidade,
    ee.cno_vinculado,
    ee.cep,
    ee.ni_responsavel,
    ee.qualificacao_responsavel,
    ee.qualificacao_responsavel_descricao,
    ee.cd_mun,
    ee.nm_mun,
    ee.tp_logr,
    ee.nm_logr,
    ee.cd_logr,
    ee.nm_bairro,
    ee.nm_estado,
    ee.caixa_postal,
    ee.complemento,
    ee.unidade_medida,
    ee.nome,
    ee.codigo_localizacao,
    ee.metragem,
    ee.tipo_area_complementar,
    ee.data_registro_cnae,
    ee.data_inicio_vinculo,
    ee.data_fim_vinculo,
    ee.data_registro_vinculo,
    ee.qualificacao_contribuinte,
    ee.qualificacao_contribuinte_descricao,
    ef.gid_cliente,
    ef.ponto,
    ef.cidade,
    ef.uf,
    ef.latlonglote,
    st_distance(ef.ponto::geography, ee.geom2::geography, true) AS st_distance
   FROM ( SELECT DISTINCT ON (aa.cno) lpad(row_number() OVER ()::text, 6, '0'::text)::numeric AS id,
            aa.cno::numeric(12,0) AS cno,
            ac.cnae::numeric(7,0) AS cnae,
            ah.descricao AS cno_cnae_descricao,
            ab."Destinação" AS destinacao,
            ab.categoria,
            ab."Tipo de Área" AS tipo_area,
            aa."Área total"::numeric(11,2) AS area_total,
            aa."situação"::numeric(2,0) AS situacao,
            ae.descricao AS situacao_descricao,
            to_date(aa."Data de início"::text, 'YYYY-MM-DD'::text) AS data_inicio,
            to_date(aa."Data da situação"::text, 'YYYY-MM-DD'::text) AS data_situacao,
            aa."Nome empresarial" AS nome_empresarial,
            (((((((((((aa."Tipo de logradouro"::text || ' '::text) || aa.logradouro::text) || ', '::text) || aa."Número do logradouro"::text) || ' - '::text) || aa.bairro::text) || ', '::text) || aa."Nome do município"::text) || ' - '::text) || aa.estado::text) || ', '::text) || aa.cep::text AS endereco_consulta,
            to_date(aa."Data de registro"::text, 'YYYY-MM-DD'::text) AS data_registro,
            ai.latitude,
            ai.longitude,
            (ai.latitude || ','::text) || ai.longitude AS latlong,
            st_makepoint(ai.longitude::double precision, ai.latitude::double precision) AS geom2,
            ai.precisao_geocoding,
            ai.endereco_formatado,
            ad."NI do responsável" AS ni_responsavel_vinculo,
            aa."Código do Pais"::text AS cd_pais,
            aa."Nome do pais" AS nm_pais,
            to_date(aa."Data de inicio da responsabilidade"::text, 'YYYY-MM-DD'::text) AS data_inicio_responsabilidade,
            aa."CNO vinculado" AS cno_vinculado,
            aa.cep,
            aa."NI do responsável" AS ni_responsavel,
            aa."Qualificação do responsavel"::numeric(4,0) AS qualificacao_responsavel,
            ag.descricao AS qualificacao_responsavel_descricao,
            aa."Código do municipio"::numeric(4,0) AS cd_mun,
            aa."Nome do município" AS nm_mun,
            aa."Tipo de logradouro" AS tp_logr,
            aa.logradouro AS nm_logr,
            aa."Número do logradouro" AS cd_logr,
            aa.bairro AS nm_bairro,
            aa.estado AS nm_estado,
            aa."Caixa Postal" AS caixa_postal,
            aa.complemento,
            aa."Unidade de medida" AS unidade_medida,
            aa.nome,
            aa."Código de localização" AS codigo_localizacao,
            ab.metragem::numeric(22,0) AS metragem,
            ab."Tipo de Área Complementar" AS tipo_area_complementar,
            to_date(ac."Data de registro"::text, 'YYYY-MM-DD'::text) AS data_registro_cnae,
            to_date(ad."Data de início"::text, 'YYYY-MM-DD'::text) AS data_inicio_vinculo,
            to_date(ad."Data de fim"::text, 'YYYY-MM-DD'::text) AS data_fim_vinculo,
            to_date(ad."Data de registro"::text, 'YYYY-MM-DD'::text) AS data_registro_vinculo,
            ad."Qualificação do contribuinte"::numeric(4,0) AS qualificacao_contribuinte,
            af.descricao AS qualificacao_contribuinte_descricao
           FROM cno.cno aa
             LEFT JOIN cno.cno_areas ab ON aa.cno::text = ab.cno::text
             LEFT JOIN cno.cno_cnaes ac ON ab.cno::text = ac.cno::text
             LEFT JOIN cno.cno_vinculos ad ON ac.cno::text = ad.cno::text
             LEFT JOIN cno.dic_cno_situacao ae ON aa."situação"::numeric = ae.atributo
             LEFT JOIN cno.dic_cno_qualificacao_contribuinte af ON ad."Qualificação do contribuinte"::text = af.atributo
             LEFT JOIN cno.dic_cno_qualificacao_responsavel ag ON aa."Qualificação do responsavel"::text = ag.atributo
             LEFT JOIN cno.dic_cno_cnaes ah ON ac.cnae::text = ah.atributo::text
             LEFT JOIN cno.tb_localizacao ai ON aa.cno::text = ai.cno::text
          WHERE (aa."Nome do município"::text = ANY (ARRAY['{{nm_mun_maiusculocomacento}}'::text])) AND ai.ativo = true) ee,
    ( SELECT DISTINCT ON (imoveis.gid) imoveis.gid AS gid_cliente,
            st_centroid(imoveis.geom) AS ponto,
            imoveis.cidade,
            imoveis.uf,
            (st_y(st_centroid(imoveis.geom)) || ','::text) || st_x(st_centroid(imoveis.geom)) AS latlonglote
           FROM esteira.imoveis) ef
  WHERE st_dwithin(ef.ponto::geography, ee.geom2::geography, {{st_distance}}::double precision, true) AND ef.cidade::text = '{{nm_mun}}'::text AND ef.uf::text = '{{nm_uf}}'::text
WITH DATA;


CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_sociodemografico
TABLESPACE pg_default
AS WITH setores_entorno AS (
         WITH imovel_buffer AS (
                 SELECT ib.gid AS gid_cliente,
                    ib.cidade,
                    st_transform(ib.geom, {{src}}) AS geom_imovel,
                    st_buffer(st_transform(ib.geom, {{src}}), {{st_distance}}::double precision) AS geom_imovel_buffer
                   FROM esteira.imoveis ib
                  WHERE ib.cidade::text ~~* '{{nm_mun}}'::text
                ), setor_atingimento AS (
                 SELECT ib.gid_cliente,
                    ib.cidade,
                    sg.cd_geocodi,
                    ib.geom_imovel,
                    st_intersection(ib.geom_imovel_buffer, st_transform(sg.geom, {{src}})) AS geom_setor_atingimento,
                    st_transform(sg.geom, {{src}}) AS geom_setor,
                    ib.geom_imovel_buffer,
                    st_area(st_transform(sg.geom, {{src}})) AS area_setor,
                    st_area(st_intersection(ib.geom_imovel_buffer, st_transform(sg.geom, {{src}}))) AS area_setor_atingimento,
                    st_area(st_intersection(ib.geom_imovel_buffer, st_transform(sg.geom, {{src}}))) * 100::double precision / st_area(st_transform(sg.geom, {{src}})) AS area_atingimento
                   FROM imovel_buffer ib,
                    ibgegrande.setores_geom sg
                  WHERE sg.cd_geocodi::text ~~* '4216602%'::text AND ib.geom_imovel_buffer && st_transform(sg.geom, {{src}}) AND (st_area(st_intersection(ib.geom_imovel_buffer, st_transform(sg.geom, {{src}}))) * 100::double precision / st_area(st_transform(sg.geom, {{src}}))) >= 25::double precision
                ), setor_area AS (
                 SELECT sa.gid_cliente,
                    sa.cd_geocodi AS cd_setor_entorno,
                    sa.cidade,
                    concat(st_y(st_centroid(st_transform(sa.geom_setor_atingimento, 4326))), ', ', st_x(st_centroid(st_transform(sa.geom_setor_atingimento, 4326)))) AS latlong,
                    st_distance(sa.geom_imovel, sa.geom_setor_atingimento) AS st_distance,
                    '2010'::text AS ano_censo
                   FROM setor_atingimento sa
                )
         SELECT setor_area.gid_cliente,
            setor_area.cd_setor_entorno,
            setor_area.cidade,
            setor_area.latlong,
            setor_area.st_distance,
            setor_area.ano_censo
           FROM setor_area
        )
 SELECT setores_entorno.gid_cliente,
    setores_entorno.cd_setor_entorno AS cd_setor_imovel,
    setores_entorno.cd_setor_entorno,
    setores_entorno.latlong,
    setores_entorno.st_distance,
    setores_entorno.cidade,
    setores_entorno.ano_censo,
    view_mor_total.mor_total,
    view_mor_homul.mor_homem,
    view_mor_homul.mor_mulhe,
    view_mor_fxeta.mor_infan,
    view_mor_fxeta.mor_jovem,
    view_mor_fxeta.mor_adult,
    view_mor_fxeta.mor_idoso,
    view_dom_total.dom_total,
    view_dom_total.situacao,
    view_mor_dom.mor_1,
    view_mor_dom.mor_2,
    view_mor_dom.mor_3,
    view_mor_dom.mor_4,
    view_mor_dom.mor_5,
    view_mor_piramide.h_0_a_4,
    view_mor_piramide.h_5_a_9,
    view_mor_piramide.h_10_a_14,
    view_mor_piramide.h_15_a_19,
    view_mor_piramide.h_20_a_24,
    view_mor_piramide.h_25_a_29,
    view_mor_piramide.h_30_a_34,
    view_mor_piramide.h_35_a_39,
    view_mor_piramide.h_40_a_44,
    view_mor_piramide.h_45_a_49,
    view_mor_piramide.h_50_a_54,
    view_mor_piramide.h_55_a_59,
    view_mor_piramide.h_60_a_64,
    view_mor_piramide.h_65_a_69,
    view_mor_piramide.h_70_a_74,
    view_mor_piramide.h_75_a_79,
    view_mor_piramide.h_80_mais,
    view_mor_piramide.m_0_a_4,
    view_mor_piramide.m_5_a_9,
    view_mor_piramide.m_10_a_14,
    view_mor_piramide.m_15_a_19,
    view_mor_piramide.m_20_a_24,
    view_mor_piramide.m_25_a_29,
    view_mor_piramide.m_30_a_34,
    view_mor_piramide.m_35_a_39,
    view_mor_piramide.m_40_a_44,
    view_mor_piramide.m_45_a_49,
    view_mor_piramide.m_50_a_54,
    view_mor_piramide.m_55_a_59,
    view_mor_piramide.m_60_a_64,
    view_mor_piramide.m_65_a_69,
    view_mor_piramide.m_70_a_74,
    view_mor_piramide.m_75_a_79,
    view_mor_piramide.m_80_mais,
    view_nucleo_familiar.chefe_familia_solteiro,
    view_nucleo_familiar.chefe_familia_casado,
    view_nucleo_familiar.casado_com_chefe,
    view_nucleo_familiar.filhos_do_chefe_ou_conjuge,
    view_nucleo_familiar.genros_e_noras,
    view_nucleo_familiar.pais_maes_do_chefe,
    view_nucleo_familiar.sogros_do_chefe_ou_conjuge,
    view_nucleo_familiar.netos_do_chefe_ou_conjuge,
    view_nucleo_familiar.bisnetos_do_chefe_ou_conjuge,
    view_nucleo_familiar.irmaos_do_chefe_ou_conjuge,
    view_nucleo_familiar.avos_do_chefe_ou_conjuge,
    view_nucleo_familiar.outros_parentes_do_chefe_ou_conjuge,
    view_nucleo_familiar.conviventes_sem_parentesco,
    view_pea_sexo.hpea,
    view_pea_sexo.mpea,
    view_pea_sexo.hdes,
    view_pea_sexo.mdes,
    view_ren_class_pessoas.classe_a,
    view_ren_class_pessoas.classe_b,
    view_ren_class_pessoas.classe_c,
    view_ren_class_pessoas.classe_d,
    view_ren_class_pessoas.classe_e,
    view_ren_totalpea_sexo.ren_homem,
    view_ren_totalpea_sexo.ren_mulhe,
    view_ren_totalpea_sexo.ren_h_pc,
    view_ren_totalpea_sexo.ren_m_pc,
    view_ren_class_sexo_renda.ren_h_cla,
    view_ren_class_sexo_renda.ren_h_clb,
    view_ren_class_sexo_renda.ren_h_clc,
    view_ren_class_sexo_renda.ren_h_cld,
    view_ren_class_sexo_renda.ren_h_cle,
    view_ren_class_sexo_renda.ren_m_cla,
    view_ren_class_sexo_renda.ren_m_clb,
    view_ren_class_sexo_renda.ren_m_clc,
    view_ren_class_sexo_renda.ren_m_cld,
    view_ren_class_sexo_renda.ren_m_cle,
    view_dom_tipo_situacao.casas,
    view_dom_tipo_situacao.apartamentos,
    view_dom_tipo_situacao.condominios,
    view_dom_tipo_situacao.proprios,
    view_dom_tipo_situacao.alugados,
    view_dom_tipo_situacao.em_aquisicao,
    view_dom_tipo_situacao.outras_ocupacoes,
    view_ren_class_pessoas_sexo.ttl_h_cla,
    view_ren_class_pessoas_sexo.ttl_h_clb,
    view_ren_class_pessoas_sexo.ttl_h_clc,
    view_ren_class_pessoas_sexo.ttl_h_cld,
    view_ren_class_pessoas_sexo.ttl_h_cle,
    view_ren_class_pessoas_sexo.ttl_m_cla,
    view_ren_class_pessoas_sexo.ttl_m_clb,
    view_ren_class_pessoas_sexo.ttl_m_clc,
    view_ren_class_pessoas_sexo.ttl_m_cld,
    view_ren_class_pessoas_sexo.ttl_m_cle
   FROM setores_entorno
     JOIN ( SELECT view_mor_total_1.cod_setor,
            view_mor_total_1.mor_total
           FROM ibgegrande.view_mor_total view_mor_total_1) view_mor_total ON setores_entorno.cd_setor_entorno::character varying::text = view_mor_total.cod_setor::text
     JOIN ( SELECT view_mor_homul_1.cod_setor,
            view_mor_homul_1.mor_homem,
            view_mor_homul_1.mor_mulhe
           FROM ibgegrande.view_mor_homul view_mor_homul_1) view_mor_homul ON setores_entorno.cd_setor_entorno::character varying::text = view_mor_homul.cod_setor::text
     JOIN ( SELECT view_mor_fxeta_1.cod_setor,
            view_mor_fxeta_1.mor_infan,
            view_mor_fxeta_1.mor_jovem,
            view_mor_fxeta_1.mor_adult,
            view_mor_fxeta_1.mor_idoso
           FROM ibgegrande.view_mor_fxeta view_mor_fxeta_1) view_mor_fxeta ON setores_entorno.cd_setor_entorno::character varying::text = view_mor_fxeta.cod_setor::text
     JOIN ( SELECT view_dom_total_1.cod_setor,
            view_dom_total_1.dom_total,
            view_dom_total_1.situacao
           FROM ibgegrande.view_dom_total view_dom_total_1) view_dom_total ON setores_entorno.cd_setor_entorno::character varying::text = view_dom_total.cod_setor::text
     JOIN ( SELECT view_mor_dom_1.cod_setor,
            view_mor_dom_1.mor_1,
            view_mor_dom_1.mor_2,
            view_mor_dom_1.mor_3,
            view_mor_dom_1.mor_4,
            view_mor_dom_1.mor_5
           FROM ibgegrande.view_mor_dom view_mor_dom_1) view_mor_dom ON setores_entorno.cd_setor_entorno::character varying::text = view_mor_dom.cod_setor::text
     JOIN ( SELECT view_mor_piramide_1.cod_setor,
            view_mor_piramide_1.h_0_a_4,
            view_mor_piramide_1.h_5_a_9,
            view_mor_piramide_1.h_10_a_14,
            view_mor_piramide_1.h_15_a_19,
            view_mor_piramide_1.h_20_a_24,
            view_mor_piramide_1.h_25_a_29,
            view_mor_piramide_1.h_30_a_34,
            view_mor_piramide_1.h_35_a_39,
            view_mor_piramide_1.h_40_a_44,
            view_mor_piramide_1.h_45_a_49,
            view_mor_piramide_1.h_50_a_54,
            view_mor_piramide_1.h_55_a_59,
            view_mor_piramide_1.h_60_a_64,
            view_mor_piramide_1.h_65_a_69,
            view_mor_piramide_1.h_70_a_74,
            view_mor_piramide_1.h_75_a_79,
            view_mor_piramide_1.h_80_mais,
            view_mor_piramide_1.m_0_a_4,
            view_mor_piramide_1.m_5_a_9,
            view_mor_piramide_1.m_10_a_14,
            view_mor_piramide_1.m_15_a_19,
            view_mor_piramide_1.m_20_a_24,
            view_mor_piramide_1.m_25_a_29,
            view_mor_piramide_1.m_30_a_34,
            view_mor_piramide_1.m_35_a_39,
            view_mor_piramide_1.m_40_a_44,
            view_mor_piramide_1.m_45_a_49,
            view_mor_piramide_1.m_50_a_54,
            view_mor_piramide_1.m_55_a_59,
            view_mor_piramide_1.m_60_a_64,
            view_mor_piramide_1.m_65_a_69,
            view_mor_piramide_1.m_70_a_74,
            view_mor_piramide_1.m_75_a_79,
            view_mor_piramide_1.m_80_mais
           FROM ibgegrande.view_mor_piramide view_mor_piramide_1) view_mor_piramide ON setores_entorno.cd_setor_entorno::character varying::text = view_mor_piramide.cod_setor::text
     JOIN ( SELECT view_nucleo_familiar_1.cod_setor,
            view_nucleo_familiar_1.chefe_familia_solteiro,
            view_nucleo_familiar_1.chefe_familia_casado,
            view_nucleo_familiar_1.casado_com_chefe,
            view_nucleo_familiar_1.filhos_do_chefe_ou_conjuge,
            view_nucleo_familiar_1.genros_e_noras,
            view_nucleo_familiar_1.pais_maes_do_chefe,
            view_nucleo_familiar_1.sogros_do_chefe_ou_conjuge,
            view_nucleo_familiar_1.netos_do_chefe_ou_conjuge,
            view_nucleo_familiar_1.bisnetos_do_chefe_ou_conjuge,
            view_nucleo_familiar_1.irmaos_do_chefe_ou_conjuge,
            view_nucleo_familiar_1.avos_do_chefe_ou_conjuge,
            view_nucleo_familiar_1.outros_parentes_do_chefe_ou_conjuge,
            view_nucleo_familiar_1.conviventes_sem_parentesco
           FROM ibgegrande.view_nucleo_familiar view_nucleo_familiar_1) view_nucleo_familiar ON setores_entorno.cd_setor_entorno::character varying::text = view_nucleo_familiar.cod_setor::text
     JOIN ( SELECT view_pea_sexo_1.cod_setor,
            view_pea_sexo_1.hpea,
            view_pea_sexo_1.mpea,
            view_pea_sexo_1.hdes,
            view_pea_sexo_1.mdes
           FROM ibgegrande.view_pea_sexo view_pea_sexo_1) view_pea_sexo ON setores_entorno.cd_setor_entorno::character varying::text = view_pea_sexo.cod_setor::text
     JOIN ( SELECT view_ren_class_pessoas_1.cod_setor,
            view_ren_class_pessoas_1.classe_a,
            view_ren_class_pessoas_1.classe_b,
            view_ren_class_pessoas_1.classe_c,
            view_ren_class_pessoas_1.classe_d,
            view_ren_class_pessoas_1.classe_e
           FROM ibgegrande.view_ren_class_pessoas view_ren_class_pessoas_1) view_ren_class_pessoas ON setores_entorno.cd_setor_entorno::character varying::text = view_ren_class_pessoas.cod_setor::text
     JOIN ( SELECT view_ren_totalpea_sexo_1.cod_setor,
            view_ren_totalpea_sexo_1.ren_homem,
            view_ren_totalpea_sexo_1.ren_mulhe,
            view_ren_totalpea_sexo_1.ren_h_pc,
            view_ren_totalpea_sexo_1.ren_m_pc
           FROM ibgegrande.view_ren_totalpea_sexo view_ren_totalpea_sexo_1) view_ren_totalpea_sexo ON setores_entorno.cd_setor_entorno::character varying::text = view_ren_totalpea_sexo.cod_setor::text
     JOIN ( SELECT view_ren_class_sexo_renda_1.cod_setor,
            view_ren_class_sexo_renda_1.ren_h_cla,
            view_ren_class_sexo_renda_1.ren_h_clb,
            view_ren_class_sexo_renda_1.ren_h_clc,
            view_ren_class_sexo_renda_1.ren_h_cld,
            view_ren_class_sexo_renda_1.ren_h_cle,
            view_ren_class_sexo_renda_1.ren_m_cla,
            view_ren_class_sexo_renda_1.ren_m_clb,
            view_ren_class_sexo_renda_1.ren_m_clc,
            view_ren_class_sexo_renda_1.ren_m_cld,
            view_ren_class_sexo_renda_1.ren_m_cle
           FROM ibgegrande.view_ren_class_sexo_renda view_ren_class_sexo_renda_1) view_ren_class_sexo_renda ON setores_entorno.cd_setor_entorno::character varying::text = view_ren_class_sexo_renda.cod_setor::text
     JOIN ( SELECT view_dom_tipo_situacao_1.cod_setor,
            view_dom_tipo_situacao_1.casas,
            view_dom_tipo_situacao_1.apartamentos,
            view_dom_tipo_situacao_1.condominios,
            view_dom_tipo_situacao_1.proprios,
            view_dom_tipo_situacao_1.alugados,
            view_dom_tipo_situacao_1.em_aquisicao,
            view_dom_tipo_situacao_1.outras_ocupacoes
           FROM ibgegrande.view_dom_tipo_situacao view_dom_tipo_situacao_1) view_dom_tipo_situacao ON setores_entorno.cd_setor_entorno::character varying::text = view_dom_tipo_situacao.cod_setor::text
     JOIN ( SELECT view_ren_class_pessoas_sexo_1.cod_setor,
            view_ren_class_pessoas_sexo_1.ttl_h_cla,
            view_ren_class_pessoas_sexo_1.ttl_h_clb,
            view_ren_class_pessoas_sexo_1.ttl_h_clc,
            view_ren_class_pessoas_sexo_1.ttl_h_cld,
            view_ren_class_pessoas_sexo_1.ttl_h_cle,
            view_ren_class_pessoas_sexo_1.ttl_m_cla,
            view_ren_class_pessoas_sexo_1.ttl_m_clb,
            view_ren_class_pessoas_sexo_1.ttl_m_clc,
            view_ren_class_pessoas_sexo_1.ttl_m_cld,
            view_ren_class_pessoas_sexo_1.ttl_m_cle
           FROM ibgegrande.view_ren_class_pessoas_sexo view_ren_class_pessoas_sexo_1) view_ren_class_pessoas_sexo ON setores_entorno.cd_setor_entorno::character varying::text = view_ren_class_pessoas_sexo.cod_setor::text
WITH DATA;

CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_imoveis_bi
TABLESPACE pg_default
AS SELECT monit_geral.id,
    monit_geral.titulo,
    monit_geral.descricao,
    monit_geral.area,
    monit_geral.data_anuncio,
    monit_geral.id_fonte,
    monit_geral.num_andares,
    monit_geral.num_vagas_garagem,
    monit_geral.num_suites,
    monit_geral.num_banheiros,
    monit_geral.num_quartos,
    monit_geral.valor,
    monit_geral.iptu,
    monit_geral.taxa_condominial,
    monit_geral.contato,
    monit_geral.link_anuncio,
    monit_geral.fonte,
    monit_geral.tipo_imovel,
    monit_geral.tipo_negocio,
    monit_geral.tipo_uso,
    monit_geral.estado_construcao,
        CASE
            WHEN (monit_geral.id_fonte::text IN ( SELECT rl_id_fonte_lancamentos.id_fonte
               FROM observatorio.rl_id_fonte_lancamentos)) THEN true
            ELSE false
        END AS imovel_lancamento,
    monit_geral.bl_temporada,
    monit_geral.data_raspagem,
    monit_geral.hash,
    monit_geral.bl_ativo,
    monit_geral.estado_sigla,
    monit_geral.cidade,
    monit_geral.bairro_tratado,
    monit_geral.cep,
    monit_geral.complemento,
    monit_geral.logradouro,
    monit_geral.numero,
    monit_geral.precisao,
    monit_geral.ponto,
    monit_geral.lat,
    monit_geral.lon,
    monit_geral.data_tabela,
    monit_geral.is_outlier,
    (st_y(monit_geral.ponto) || ','::text) || st_x(monit_geral.ponto) AS latlong,
    (date_part('year'::text, monit_geral.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral.data_tabela)::text, 2, '0'::text) AS date_part
   FROM observatorio.monit_geral
  WHERE monit_geral.cidade::text = '{{nm_mun}}'::text AND (((date_part('year'::text, monit_geral.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral.data_tabela)::text, 2, '0'::text))::numeric IN ( SELECT max(((date_part('year'::text, monit_geral_1.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral_1.data_tabela)::text, 2, '0'::text))::numeric) AS data_tabela
           FROM observatorio.monit_geral monit_geral_1
          WHERE monit_geral_1.cidade::text = '{{nm_mun}}'::text
          GROUP BY monit_geral_1.data_tabela
         HAVING count(monit_geral_1.id) > 300
          ORDER BY (((date_part('year'::text, monit_geral_1.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral_1.data_tabela)::text, 2, '0'::text))::numeric) DESC
         LIMIT 1))
WITH DATA;

CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_imoveis_bi_cidade
TABLESPACE pg_default
AS WITH anuncios_com_bairro AS (
         SELECT monit_geral.id,
            monit_geral.titulo,
            monit_geral.descricao,
            monit_geral.area,
            monit_geral.data_anuncio,
            monit_geral.id_fonte,
            monit_geral.num_andares,
            monit_geral.num_vagas_garagem,
            monit_geral.num_suites,
            monit_geral.num_banheiros,
            monit_geral.num_quartos,
            monit_geral.valor,
            monit_geral.iptu,
            monit_geral.taxa_condominial,
            monit_geral.contato,
            monit_geral.link_anuncio,
            monit_geral.fonte,
            monit_geral.tipo_imovel,
            monit_geral.tipo_negocio,
            monit_geral.tipo_uso,
            monit_geral.estado_construcao,
                CASE
                    WHEN (monit_geral.id_fonte::text IN ( SELECT rl_id_fonte_lancamentos.id_fonte
                       FROM observatorio.rl_id_fonte_lancamentos)) THEN true
                    ELSE false
                END AS imovel_lancamento,
            monit_geral.bl_temporada,
            monit_geral.data_raspagem,
            monit_geral.hash,
            monit_geral.bl_ativo,
            monit_geral.estado_sigla,
            monit_geral.cidade,
            monit_geral.bairro_tratado,
            ba.nm_bairro AS bairro_geometrico,
            monit_geral.cep,
            monit_geral.complemento,
            monit_geral.logradouro,
            monit_geral.numero,
            monit_geral.precisao,
            monit_geral.ponto,
            monit_geral.lat,
            monit_geral.lon,
            monit_geral.data_tabela,
            monit_geral.is_outlier,
            (st_y(monit_geral.ponto) || ','::text) || st_x(monit_geral.ponto) AS latlong,
            (date_part('year'::text, monit_geral.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral.data_tabela)::text, 2, '0'::text) AS date_part
           FROM observatorio.monit_geral
             LEFT JOIN geo_{{schema}}.cad_bairro ba ON st_contains(ba.geom, st_transform(st_setsrid(monit_geral.ponto, 4326), {{src}}))
          WHERE monit_geral.cidade::text = '{{nm_mun}}'::text AND monit_geral.ponto IS NOT NULL AND (((date_part('year'::text, monit_geral.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral.data_tabela)::text, 2, '0'::text))::numeric IN ( SELECT max(((date_part('year'::text, monit_geral_1.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral_1.data_tabela)::text, 2, '0'::text))::numeric) AS data_tabela
                   FROM observatorio.monit_geral monit_geral_1
                  WHERE monit_geral_1.cidade::text = '{{nm_mun}}'::text
                  GROUP BY monit_geral_1.data_tabela
                 HAVING count(monit_geral_1.id) > 300
                  ORDER BY (((date_part('year'::text, monit_geral_1.data_tabela) || ''::text) || lpad(date_part('month'::text, monit_geral_1.data_tabela)::text, 2, '0'::text))::numeric) DESC
                 LIMIT 1))
        )
 SELECT row_number() OVER () AS row_id,
    anuncios_com_bairro.id,
    anuncios_com_bairro.titulo,
    anuncios_com_bairro.descricao,
    anuncios_com_bairro.area,
    anuncios_com_bairro.data_anuncio,
    anuncios_com_bairro.id_fonte,
    anuncios_com_bairro.num_andares,
    anuncios_com_bairro.num_vagas_garagem,
    anuncios_com_bairro.num_suites,
    anuncios_com_bairro.num_banheiros,
    anuncios_com_bairro.num_quartos,
    anuncios_com_bairro.valor,
    anuncios_com_bairro.iptu,
    anuncios_com_bairro.taxa_condominial,
    anuncios_com_bairro.contato,
    anuncios_com_bairro.link_anuncio,
    anuncios_com_bairro.fonte,
    anuncios_com_bairro.tipo_imovel,
    anuncios_com_bairro.tipo_negocio,
    anuncios_com_bairro.tipo_uso,
    anuncios_com_bairro.estado_construcao,
    anuncios_com_bairro.imovel_lancamento,
    anuncios_com_bairro.bl_temporada,
    anuncios_com_bairro.data_raspagem,
    anuncios_com_bairro.hash,
    anuncios_com_bairro.bl_ativo,
    anuncios_com_bairro.estado_sigla,
    anuncios_com_bairro.cidade,
    anuncios_com_bairro.bairro_tratado,
    anuncios_com_bairro.bairro_geometrico,
    anuncios_com_bairro.cep,
    anuncios_com_bairro.complemento,
    anuncios_com_bairro.logradouro,
    anuncios_com_bairro.numero,
    anuncios_com_bairro.precisao,
    anuncios_com_bairro.ponto,
    anuncios_com_bairro.lat,
    anuncios_com_bairro.lon,
    anuncios_com_bairro.data_tabela,
    anuncios_com_bairro.is_outlier,
    anuncios_com_bairro.latlong,
    anuncios_com_bairro.date_part
   FROM anuncios_com_bairro
WITH DATA;

CREATE INDEX IF NOT EXISTS idx_viewmat_imoveis_bi_bairro_geometrico_cidade ON geo_{{schema}}.viewmat_imoveis_bi_cidade USING btree (bairro_geometrico);
CREATE INDEX IF NOT EXISTS idx_viewmat_imoveis_bi_cidade_cidade ON geo_{{schema}}.viewmat_imoveis_bi_cidade USING btree (cidade);
CREATE INDEX IF NOT EXISTS idx_viewmat_imoveis_bi_id_fonte_cidade ON geo_{{schema}}.viewmat_imoveis_bi_cidade USING btree (id_fonte);


CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_imoveis_bi_bairro_lake
AS WITH imovel AS (
         SELECT a.gid_cliente,
            b.bairro_tratado,
            b.cidade
           FROM ( SELECT imoveis.gid AS gid_cliente,
                    st_setsrid(st_centroid(imoveis.geom), 4326) AS geoms,
                    imoveis.geom,
                    imoveis.cidade,
                    imoveis.uf,
                    imoveis.cliente
                   FROM esteira.imoveis
                  WHERE imoveis.cidade::text = '{{nm_mun}}'::text AND imoveis.gid > 1) a
             CROSS JOIN LATERAL ( SELECT x.id,
                    x.bairro_tratado,
                    x.cidade,
                    x.geoms
                   FROM ( SELECT viewmat_imoveis_bi.id,
                            viewmat_imoveis_bi.bairro_tratado,
                            viewmat_imoveis_bi.cidade,
                            st_setsrid(viewmat_imoveis_bi.ponto, 4326) AS geoms
                           FROM geo_{{schema}}.viewmat_imoveis_bi
                          WHERE viewmat_imoveis_bi.cidade::text = '{{nm_mun}}'::text AND viewmat_imoveis_bi.ponto IS NOT NULL) x
                  ORDER BY (x.geoms <-> a.geoms)
                 LIMIT 5) b
          GROUP BY a.gid_cliente, b.bairro_tratado, b.cidade
        )
 SELECT row_number() OVER () AS row_id,
    imovel.gid_cliente,
    vib.date_part,
    vib.id,
    vib.titulo,
    vib.descricao,
    vib.area,
    vib.data_anuncio,
    vib.id_fonte,
    vib.num_andares,
    vib.num_vagas_garagem,
    vib.num_suites,
    vib.num_banheiros,
    vib.num_quartos,
    vib.valor,
    vib.iptu,
    vib.taxa_condominial,
    vib.contato,
    vib.link_anuncio,
    vib.fonte,
    vib.tipo_imovel,
    vib.tipo_negocio,
    vib.tipo_uso,
    vib.estado_construcao,
    vib.imovel_lancamento,
    vib.bl_temporada,
    vib.data_raspagem,
    vib.hash,
    vib.bl_ativo,
    vib.estado_sigla,
    vib.cidade,
    vib.bairro_tratado,
    vib.cep,
    vib.complemento,
    vib.logradouro,
    vib.numero,
    vib.precisao,
    vib.ponto,
    vib.lat,
    vib.lon,
    vib.data_tabela,
    vib.is_outlier,
    vib.latlong
   FROM imovel
     LEFT JOIN ( SELECT viewmat_imoveis_bi.date_part,
            viewmat_imoveis_bi.id,
            viewmat_imoveis_bi.titulo,
            viewmat_imoveis_bi.descricao,
            viewmat_imoveis_bi.area,
            viewmat_imoveis_bi.data_anuncio,
            viewmat_imoveis_bi.id_fonte,
            viewmat_imoveis_bi.num_andares,
            viewmat_imoveis_bi.num_vagas_garagem,
            viewmat_imoveis_bi.num_suites,
            viewmat_imoveis_bi.num_banheiros,
            viewmat_imoveis_bi.num_quartos,
            viewmat_imoveis_bi.valor,
            viewmat_imoveis_bi.iptu,
            viewmat_imoveis_bi.taxa_condominial,
            viewmat_imoveis_bi.contato,
            viewmat_imoveis_bi.link_anuncio,
            viewmat_imoveis_bi.fonte,
            viewmat_imoveis_bi.tipo_imovel,
            viewmat_imoveis_bi.tipo_negocio,
            viewmat_imoveis_bi.tipo_uso,
            viewmat_imoveis_bi.estado_construcao,
            viewmat_imoveis_bi.imovel_lancamento,
            viewmat_imoveis_bi.bl_temporada,
            viewmat_imoveis_bi.data_raspagem,
            viewmat_imoveis_bi.hash,
            viewmat_imoveis_bi.bl_ativo,
            viewmat_imoveis_bi.estado_sigla,
            viewmat_imoveis_bi.cidade,
            viewmat_imoveis_bi.bairro_tratado,
            viewmat_imoveis_bi.cep,
            viewmat_imoveis_bi.complemento,
            viewmat_imoveis_bi.logradouro,
            viewmat_imoveis_bi.numero,
            viewmat_imoveis_bi.precisao,
            viewmat_imoveis_bi.ponto,
            viewmat_imoveis_bi.lat,
            viewmat_imoveis_bi.lon,
            viewmat_imoveis_bi.data_tabela,
            viewmat_imoveis_bi.is_outlier,
            viewmat_imoveis_bi.latlong
           FROM geo_{{schema}}.viewmat_imoveis_bi
          WHERE viewmat_imoveis_bi.cidade::text = '{{nm_mun}}'::text AND viewmat_imoveis_bi.estado_sigla::text = '{{nm_uf}}'::text) vib ON imovel.bairro_tratado::text = vib.bairro_tratado::text AND imovel.cidade::text = vib.cidade::text
WITH DATA;








-- COPIARRRR
CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_imoveis_bi_raio_lancamentos
AS SELECT im.titulo,
    im.descricao,
    im.area,
    im.data_anuncio,
    im.id_fonte,
    im.num_andares,
    im.num_vagas_garagem,
    im.num_suites,
    im.num_banheiros,
    im.num_quartos,
    im.valor,
    im.iptu,
    im.taxa_condominial,
    im.contato,
    im.link_anuncio,
    im.fonte,
    im.tipo_imovel,
    im.tipo_negocio,
    im.tipo_uso,
    im.estado_construcao,
    im.imovel_lancamento,
    im.bl_temporada,
    im.data_raspagem,
    im.hash,
    im.bl_ativo,
    im.estado_sigla,
    im.cidade,
    im.bairro_tratado,
    im.cep,
    im.complemento,
    im.logradouro,
    im.numero,
    im.precisao,
    im.ponto,
    im.lat,
    im.lon,
    im.data_tabela,
    im.is_outlier,
    im.latlong,
    im.controle1,
    im.controle2,
    im.incorporadora,
    im.empreendimento,
    im.data_lancamento,
    im.status,
    im.estoque,
    ef.latlonglote,
    st_distance(im.ponto::geography, ef.ponto_imovel::geography, true) AS st_distance,
    ef.ponto_imovel,
    ef.gid_cliente
   FROM ( SELECT DISTINCT ON ((((((lancamentos.bairro_tratado::text || ''::text) || lancamentos.logradouro::text) || ''::text) || lancamentos.numero::text) || lancamentos.titulo::text)) lancamentos.id,
            lancamentos.titulo,
            lancamentos.descricao,
            lancamentos.area,
            lancamentos.data_anuncio,
            lancamentos.id_fonte,
            lancamentos.num_andares,
            lancamentos.num_vagas_garagem,
            lancamentos.num_suites,
            lancamentos.num_banheiros,
            lancamentos.num_quartos,
            lancamentos.valor,
            lancamentos.iptu,
            lancamentos.taxa_condominial,
            lancamentos.contato,
            lancamentos.link_anuncio,
            lancamentos.fonte,
            lancamentos.tipo_imovel,
            lancamentos.tipo_negocio,
            lancamentos.tipo_uso,
            lancamentos.estado_construcao,
            lancamentos.imovel_lancamento,
            lancamentos.bl_temporada,
            lancamentos.data_raspagem,
            lancamentos.hash,
            lancamentos.bl_ativo,
            lancamentos.estado_sigla,
            lancamentos.cidade,
            lancamentos.bairro_tratado,
            lancamentos.cep,
            lancamentos.complemento,
            lancamentos.logradouro,
            lancamentos.numero,
            lancamentos.precisao,
            lancamentos.ponto,
            lancamentos.lat,
            lancamentos.lon,
            lancamentos.data_tabela,
            lancamentos.is_outlier,
            (lancamentos.lat::text || ','::text) || lancamentos.lon::text AS latlong,
            lancamentos.controle1,
            lancamentos.controle2,
            lancamentos.incorporadora,
            lancamentos.empreendimento,
            lancamentos.data_lancamento,
            lancamentos.status,
            lancamentos.estoque
           FROM observatorio.lancamentos lancamentos
          WHERE lancamentos.tipo_negocio::text = ANY (ARRAY['Venda'::text, 'Aluguel'::text])) im,
    ( SELECT DISTINCT ON (imoveis.gid) imoveis.gid AS gid_cliente,
            imoveis.cidade,
            imoveis.uf,
            st_centroid(imoveis.geom) AS ponto_imovel,
            (st_y(st_centroid(st_transform(imoveis.geom, 4326))) || ','::text) || st_x(st_centroid(st_transform(imoveis.geom, 4326))) AS latlonglote
           FROM esteira.imoveis) ef
  WHERE st_dwithin(ef.ponto_imovel::geography, im.ponto::geography, {{st_distance}}::double precision, true) AND (ef.cidade::text = ANY (ARRAY['{{nm_mun}}'::text])) AND ef.uf::text = '{{nm_uf}}'::text
WITH DATA;

CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_imoveis_bi_shortstay_raio
TABLESPACE pg_default
AS WITH airbnb_point AS (
         SELECT a.gid,
            a.airbnb_property_id,
            a.vrbo_property_id,
            a.listing_type,
            a.bedrooms,
            a.bathrooms,
            a.accommodates,
            a.rating,
            a.reviews,
            a.title,
            a.revenue_ltm,
            a.revenue_potential_ltm,
            a.occupancy_rate_ltm,
            a.average_daily_rate_ltm,
            a.days_available_ltm,
            a.lat,
            a.lon,
            a.data_raspagem,
            a.ativo,
            st_transform(st_setsrid(st_makepoint(a.lon::double precision, a.lat::double precision), 4326), {{src}}) AS geom_sirgas{{st_distance}}_22s
           FROM airbnb.airdna_geral a
        ), esteira_point AS (
         SELECT DISTINCT ON (imoveis.gid) imoveis.gid AS gid_cliente,
            imoveis.cidade,
            imoveis.uf,
            st_transform(imoveis.geom, {{src}}) AS ponto_imovel_sirgas{{st_distance}}_22s
           FROM esteira.imoveis
          WHERE imoveis.cidade::text = '{{nm_mun}}'::text AND imoveis.uf::text = '{{nm_uf}}'::text
        )
 SELECT ap.gid,
    ap.airbnb_property_id,
    ap.vrbo_property_id,
    ap.listing_type,
    ap.bedrooms,
    ap.bathrooms,
    ap.accommodates,
    ap.rating,
    ap.reviews,
    ap.title,
    ap.revenue_ltm,
    ap.revenue_potential_ltm,
    ap.occupancy_rate_ltm,
    ap.average_daily_rate_ltm,
    ap.days_available_ltm,
    ap.lat,
    ap.lon,
    ap.data_raspagem,
    ap.ativo,
    concat(ap.lat, ',', ap.lon) AS latlon,
    ap.geom_sirgas{{st_distance}}_22s AS geom_airbnb,
    round(st_distance(ap.geom_sirgas{{st_distance}}_22s, ep.ponto_imovel_sirgas{{st_distance}}_22s)::numeric, 2) AS st_distance,
    ep.ponto_imovel_sirgas{{st_distance}}_22s AS ponto_imovel,
    ep.gid_cliente,
    ep.cidade,
    ep.uf
   FROM airbnb_point ap
     JOIN esteira_point ep ON st_dwithin(ap.geom_sirgas{{st_distance}}_22s, ep.ponto_imovel_sirgas{{st_distance}}_22s, {{st_distance}}::double precision)
     JOIN geo_{{schema}}.cad_mun mun ON st_contains(mun.geom, ap.geom_sirgas{{st_distance}}_22s)
  WHERE mun.nm_mun::text = '{{nm_mun}}'::text
WITH DATA;


CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_imoveis_bi_raio_lake
TABLESPACE pg_default
AS SELECT im.date_part,
    im.titulo,
    im.descricao,
    im.area,
    im.data_anuncio,
    im.id_fonte,
    im.num_andares,
    im.num_vagas_garagem,
    im.num_suites,
    im.num_banheiros,
    im.num_quartos,
    im.valor,
    im.iptu,
    im.taxa_condominial,
    im.contato,
    im.link_anuncio,
    im.fonte,
    im.tipo_imovel,
    im.tipo_negocio,
    im.tipo_uso,
    im.estado_construcao,
    im.imovel_lancamento,
    im.bl_temporada,
    im.data_raspagem,
    im.hash,
    im.bl_ativo,
    im.estado_sigla,
    im.cidade,
    im.bairro_tratado,
    im.cep,
    im.complemento,
    im.logradouro,
    im.numero,
    im.precisao,
    im.ponto,
    im.lat,
    im.lon,
    im.data_tabela,
    im.is_outlier,
    im.latlong,
    ef.latlonglote,
    st_distance(im.ponto::geography, ef.ponto_imovel::geography, true) AS st_distance,
    ef.ponto_imovel,
    ef.gid_cliente
   FROM ( SELECT DISTINCT ON (((((viewmat_imoveis_bi.bairro_tratado::text || ''::text) || viewmat_imoveis_bi.logradouro::text) || ''::text) || viewmat_imoveis_bi.numero::text)) viewmat_imoveis_bi.date_part,
            viewmat_imoveis_bi.id,
            viewmat_imoveis_bi.titulo,
            viewmat_imoveis_bi.descricao,
            viewmat_imoveis_bi.area,
            viewmat_imoveis_bi.data_anuncio,
            viewmat_imoveis_bi.id_fonte,
            viewmat_imoveis_bi.num_andares,
            viewmat_imoveis_bi.num_vagas_garagem,
            viewmat_imoveis_bi.num_suites,
            viewmat_imoveis_bi.num_banheiros,
            viewmat_imoveis_bi.num_quartos,
            viewmat_imoveis_bi.valor,
            viewmat_imoveis_bi.iptu,
            viewmat_imoveis_bi.taxa_condominial,
            viewmat_imoveis_bi.contato,
            viewmat_imoveis_bi.link_anuncio,
            viewmat_imoveis_bi.fonte,
            viewmat_imoveis_bi.tipo_imovel,
            viewmat_imoveis_bi.tipo_negocio,
            viewmat_imoveis_bi.tipo_uso,
            viewmat_imoveis_bi.estado_construcao,
            viewmat_imoveis_bi.imovel_lancamento,
            viewmat_imoveis_bi.bl_temporada,
            viewmat_imoveis_bi.data_raspagem,
            viewmat_imoveis_bi.hash,
            viewmat_imoveis_bi.bl_ativo,
            viewmat_imoveis_bi.estado_sigla,
            viewmat_imoveis_bi.cidade,
            viewmat_imoveis_bi.bairro_tratado,
            viewmat_imoveis_bi.cep,
            viewmat_imoveis_bi.complemento,
            viewmat_imoveis_bi.logradouro,
            viewmat_imoveis_bi.numero,
            viewmat_imoveis_bi.precisao,
            viewmat_imoveis_bi.ponto,
            viewmat_imoveis_bi.lat,
            viewmat_imoveis_bi.lon,
            viewmat_imoveis_bi.data_tabela,
            viewmat_imoveis_bi.is_outlier,
            viewmat_imoveis_bi.latlong
           FROM geo_{{schema}}.viewmat_imoveis_bi
          WHERE (viewmat_imoveis_bi.tipo_negocio::text = ANY (ARRAY['Venda'::text, 'Aluguel'::text])) AND viewmat_imoveis_bi.bl_ativo IS TRUE AND (viewmat_imoveis_bi.precisao = ANY (ARRAY[3, 4]))) im,
    ( SELECT DISTINCT ON (imoveis.gid) imoveis.gid AS gid_cliente,
            imoveis.cidade,
            imoveis.uf,
            st_centroid(imoveis.geom) AS ponto_imovel,
            (st_y(st_centroid(st_transform(imoveis.geom, 4326))) || ','::text) || st_x(st_centroid(st_transform(imoveis.geom, 4326))) AS latlonglote
           FROM esteira.imoveis) ef
  WHERE st_dwithin(ef.ponto_imovel::geography, im.ponto::geography, {{st_distance}}::double precision, true) AND (ef.cidade::text = ANY (ARRAY['{{nm_mun}}'::text])) AND ef.uf::text = '{{nm_uf}}'::text
WITH DATA;



CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.view_score
TABLESPACE pg_default
AS WITH intervals AS (
         SELECT foo.classe,
            foo.categoria,
            esteira.cdb_jenksbins(array_agg(foo.pc_setor), 5, 1, true) AS intervals
           FROM ( SELECT view_mor_fxeta.cod_setor,
                    'Demográfico'::text AS categoria,
                    'Infância'::text AS classe,
                    view_mor_fxeta.mor_infan AS valor_classe,
                    view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso AS valor_todos,
                        CASE
                            WHEN round(view_mor_fxeta.mor_infan * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2) = 0::numeric THEN 1::numeric
                            ELSE round(view_mor_fxeta.mor_infan * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2)
                        END AS pc_setor
                   FROM ibgegrande.view_mor_fxeta
                  WHERE round(view_mor_fxeta.mor_adult * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2) IS NOT NULL AND view_mor_fxeta.cod_setor::text ~~* '4216602%'::text
                UNION
                 SELECT view_mor_fxeta.cod_setor,
                    'Demográfico'::text AS categoria,
                    'Jovens'::text AS classe,
                    view_mor_fxeta.mor_jovem AS valor_classe,
                    view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso AS valor_todos,
                        CASE
                            WHEN round(view_mor_fxeta.mor_jovem * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2) = 0::numeric THEN 1::numeric
                            ELSE round(view_mor_fxeta.mor_jovem * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2)
                        END AS pc_setor
                   FROM ibgegrande.view_mor_fxeta
                  WHERE round(view_mor_fxeta.mor_adult * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2) IS NOT NULL AND view_mor_fxeta.cod_setor::text ~~* '4216602%'::text
                UNION
                 SELECT view_mor_fxeta.cod_setor,
                    'Demográfico'::text AS categoria,
                    'Adultos'::text AS classe,
                    view_mor_fxeta.mor_adult AS valor_classe,
                    view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso AS valor_todos,
                        CASE
                            WHEN round(view_mor_fxeta.mor_adult * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2) = 0::numeric THEN 1::numeric
                            ELSE round(view_mor_fxeta.mor_adult * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2)
                        END AS pc_setor
                   FROM ibgegrande.view_mor_fxeta
                  WHERE round(view_mor_fxeta.mor_adult * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2) IS NOT NULL AND view_mor_fxeta.cod_setor::text ~~* '4216602%'::text
                UNION
                 SELECT view_mor_fxeta.cod_setor,
                    'Demográfico'::text AS categoria,
                    'Idosos'::text AS classe,
                    view_mor_fxeta.mor_idoso AS valor_classe,
                    view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso AS valor_todos,
                        CASE
                            WHEN round(view_mor_fxeta.mor_idoso * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2) = 0::numeric THEN 1::numeric
                            ELSE round(view_mor_fxeta.mor_idoso * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2)
                        END AS pc_setor
                   FROM ibgegrande.view_mor_fxeta
                  WHERE round(view_mor_fxeta.mor_adult * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2) IS NOT NULL AND view_mor_fxeta.cod_setor::text ~~* '4216602%'::text
                UNION
                 SELECT view_ren_class_pessoas.cod_setor,
                    'Sociodemográfico'::text AS categoria,
                    'Classe A'::text AS classe,
                    view_ren_class_pessoas.classe_a AS valor_classe,
                    view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e AS valor_todos,
                        CASE
                            WHEN round(view_ren_class_pessoas.classe_a * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2) = 0::numeric THEN 1::numeric
                            ELSE round(view_ren_class_pessoas.classe_a * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2)
                        END AS pc_setor
                   FROM ibgegrande.view_ren_class_pessoas
                  WHERE round(view_ren_class_pessoas.classe_a * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2) IS NOT NULL AND view_ren_class_pessoas.cod_setor::text ~~* '4216602%'::text
                UNION
                 SELECT view_ren_class_pessoas.cod_setor,
                    'Sociodemográfico'::text AS categoria,
                    'Classe B'::text AS classe,
                    view_ren_class_pessoas.classe_b AS valor_classe,
                    view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e AS valor_todos,
                        CASE
                            WHEN round(view_ren_class_pessoas.classe_b * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2) = 0::numeric THEN 1::numeric
                            ELSE round(view_ren_class_pessoas.classe_b * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2)
                        END AS pc_setor
                   FROM ibgegrande.view_ren_class_pessoas
                  WHERE round(view_ren_class_pessoas.classe_b * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2) IS NOT NULL AND view_ren_class_pessoas.cod_setor::text ~~* '4216602%'::text
                UNION
                 SELECT view_ren_class_pessoas.cod_setor,
                    'Sociodemográfico'::text AS categoria,
                    'Classe C'::text AS classe,
                    view_ren_class_pessoas.classe_c AS valor_classe,
                    view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e AS valor_todos,
                        CASE
                            WHEN round(view_ren_class_pessoas.classe_c * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2) = 0::numeric THEN 1::numeric
                            ELSE round(view_ren_class_pessoas.classe_c * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2)
                        END AS pc_setor
                   FROM ibgegrande.view_ren_class_pessoas
                  WHERE round(view_ren_class_pessoas.classe_c * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2) IS NOT NULL AND view_ren_class_pessoas.cod_setor::text ~~* '4216602%'::text
                UNION
                 SELECT view_ren_class_pessoas.cod_setor,
                    'Sociodemográfico'::text AS categoria,
                    'Classe D'::text AS classe,
                    view_ren_class_pessoas.classe_d AS valor_classe,
                    view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e AS valor_todos,
                        CASE
                            WHEN round(view_ren_class_pessoas.classe_d * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2) = 0::numeric THEN 1::numeric
                            ELSE round(view_ren_class_pessoas.classe_d * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2)
                        END AS pc_setor
                   FROM ibgegrande.view_ren_class_pessoas
                  WHERE round(view_ren_class_pessoas.classe_d * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2) IS NOT NULL AND view_ren_class_pessoas.cod_setor::text ~~* '4216602%'::text
                UNION
                 SELECT view_ren_class_pessoas.cod_setor,
                    'Sociodemográfico'::text AS categoria,
                    'Classe E'::text AS classe,
                    view_ren_class_pessoas.classe_e AS valor_classe,
                    view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e AS valor_todos,
                        CASE
                            WHEN round(view_ren_class_pessoas.classe_e * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2) = 0::numeric THEN 1::numeric
                            ELSE round(view_ren_class_pessoas.classe_e * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2)
                        END AS pc_setor
                   FROM ibgegrande.view_ren_class_pessoas
                  WHERE round(view_ren_class_pessoas.classe_e * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2) IS NOT NULL AND view_ren_class_pessoas.cod_setor::text ~~* '4216602%'::text
                UNION
                 SELECT view_nucleo_familiar.cod_setor,
                    'Demográfico'::text AS categoria,
                    'Casados'::text AS classe,
                    view_nucleo_familiar.chefe_familia_casado AS valor_classe,
                    view_nucleo_familiar.chefe_familia_casado + view_nucleo_familiar.chefe_familia_solteiro AS valor_todos,
                        CASE
                            WHEN round(view_nucleo_familiar.chefe_familia_casado::numeric * 100::numeric / NULLIF(view_nucleo_familiar.chefe_familia_casado + view_nucleo_familiar.chefe_familia_solteiro, 0)::numeric, 2) = 0::numeric THEN 1::numeric
                            ELSE round(view_nucleo_familiar.chefe_familia_casado::numeric * 100::numeric / NULLIF(view_nucleo_familiar.chefe_familia_casado + view_nucleo_familiar.chefe_familia_solteiro, 0)::numeric, 2)
                        END AS pc_setor
                   FROM ibgegrande.view_nucleo_familiar
                  WHERE round(view_nucleo_familiar.chefe_familia_casado::numeric * 100::numeric / NULLIF(view_nucleo_familiar.chefe_familia_casado + view_nucleo_familiar.chefe_familia_solteiro, 0)::numeric, 2) IS NOT NULL AND view_nucleo_familiar.cod_setor::text ~~* '4216602%'::text
                UNION
                 SELECT view_nucleo_familiar.cod_setor,
                    'Demográfico'::text AS categoria,
                    'Solteiros'::text AS classe,
                    view_nucleo_familiar.chefe_familia_solteiro AS valor_classe,
                    view_nucleo_familiar.chefe_familia_solteiro + view_nucleo_familiar.chefe_familia_casado AS valor_todos,
                        CASE
                            WHEN round(view_nucleo_familiar.chefe_familia_solteiro::numeric * 100::numeric / NULLIF(view_nucleo_familiar.chefe_familia_solteiro + view_nucleo_familiar.chefe_familia_casado, 0)::numeric, 2) = 0::numeric THEN 1::numeric
                            ELSE round(view_nucleo_familiar.chefe_familia_solteiro::numeric * 100::numeric / NULLIF(view_nucleo_familiar.chefe_familia_solteiro + view_nucleo_familiar.chefe_familia_casado, 0)::numeric, 2)
                        END AS pc_setor
                   FROM ibgegrande.view_nucleo_familiar
                  WHERE round(view_nucleo_familiar.chefe_familia_solteiro::numeric * 100::numeric / NULLIF(view_nucleo_familiar.chefe_familia_solteiro + view_nucleo_familiar.chefe_familia_casado, 0)::numeric, 2) IS NOT NULL AND view_nucleo_familiar.cod_setor::text ~~* '4216602%'::text) foo
          GROUP BY foo.classe, foo.categoria
        ), data AS (
         SELECT foo.cod_setor,
            foo.categoria,
            foo.pc_setor,
            foo.classe
           FROM ( SELECT view_mor_fxeta.cod_setor,
                    'Demográfico'::text AS categoria,
                    'Infância'::text AS classe,
                    view_mor_fxeta.mor_infan AS valor_classe,
                    view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso AS valor_todos,
                        CASE
                            WHEN round(view_mor_fxeta.mor_infan * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2) = 0::numeric THEN 1::numeric
                            ELSE round(view_mor_fxeta.mor_infan * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2)
                        END AS pc_setor
                   FROM ibgegrande.view_mor_fxeta
                  WHERE round(view_mor_fxeta.mor_adult * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2) IS NOT NULL AND view_mor_fxeta.cod_setor::text ~~* '4216602%'::text
                UNION
                 SELECT view_mor_fxeta.cod_setor,
                    'Demográfico'::text AS categoria,
                    'Jovens'::text AS classe,
                    view_mor_fxeta.mor_jovem AS valor_classe,
                    view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso AS valor_todos,
                        CASE
                            WHEN round(view_mor_fxeta.mor_jovem * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2) = 0::numeric THEN 1::numeric
                            ELSE round(view_mor_fxeta.mor_jovem * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2)
                        END AS pc_setor
                   FROM ibgegrande.view_mor_fxeta
                  WHERE round(view_mor_fxeta.mor_adult * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2) IS NOT NULL AND view_mor_fxeta.cod_setor::text ~~* '4216602%'::text
                UNION
                 SELECT view_mor_fxeta.cod_setor,
                    'Demográfico'::text AS categoria,
                    'Adultos'::text AS classe,
                    view_mor_fxeta.mor_adult AS valor_classe,
                    view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso AS valor_todos,
                        CASE
                            WHEN round(view_mor_fxeta.mor_adult * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2) = 0::numeric THEN 1::numeric
                            ELSE round(view_mor_fxeta.mor_adult * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2)
                        END AS pc_setor
                   FROM ibgegrande.view_mor_fxeta
                  WHERE round(view_mor_fxeta.mor_adult * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2) IS NOT NULL AND view_mor_fxeta.cod_setor::text ~~* '4216602%'::text
                UNION
                 SELECT view_mor_fxeta.cod_setor,
                    'Demográfico'::text AS categoria,
                    'Idosos'::text AS classe,
                    view_mor_fxeta.mor_idoso AS valor_classe,
                    view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso AS valor_todos,
                        CASE
                            WHEN round(view_mor_fxeta.mor_idoso * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2) = 0::numeric THEN 1::numeric
                            ELSE round(view_mor_fxeta.mor_idoso * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2)
                        END AS pc_setor
                   FROM ibgegrande.view_mor_fxeta
                  WHERE round(view_mor_fxeta.mor_adult * 100::numeric / NULLIF(view_mor_fxeta.mor_infan + view_mor_fxeta.mor_jovem + view_mor_fxeta.mor_adult + view_mor_fxeta.mor_idoso, 0::numeric), 2) IS NOT NULL AND view_mor_fxeta.cod_setor::text ~~* '4216602%'::text
                UNION
                 SELECT view_ren_class_pessoas.cod_setor,
                    'Sociodemográfico'::text AS categoria,
                    'Classe A'::text AS classe,
                    view_ren_class_pessoas.classe_a AS valor_classe,
                    view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e AS valor_todos,
                        CASE
                            WHEN round(view_ren_class_pessoas.classe_a * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2) = 0::numeric THEN 1::numeric
                            ELSE round(view_ren_class_pessoas.classe_a * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2)
                        END AS pc_setor
                   FROM ibgegrande.view_ren_class_pessoas
                  WHERE round(view_ren_class_pessoas.classe_a * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2) IS NOT NULL AND view_ren_class_pessoas.cod_setor::text ~~* '4216602%'::text
                UNION
                 SELECT view_ren_class_pessoas.cod_setor,
                    'Sociodemográfico'::text AS categoria,
                    'Classe B'::text AS classe,
                    view_ren_class_pessoas.classe_b AS valor_classe,
                    view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e AS valor_todos,
                        CASE
                            WHEN round(view_ren_class_pessoas.classe_b * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2) = 0::numeric THEN 1::numeric
                            ELSE round(view_ren_class_pessoas.classe_b * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2)
                        END AS pc_setor
                   FROM ibgegrande.view_ren_class_pessoas
                  WHERE round(view_ren_class_pessoas.classe_b * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2) IS NOT NULL AND view_ren_class_pessoas.cod_setor::text ~~* '4216602%'::text
                UNION
                 SELECT view_ren_class_pessoas.cod_setor,
                    'Sociodemográfico'::text AS categoria,
                    'Classe C'::text AS classe,
                    view_ren_class_pessoas.classe_c AS valor_classe,
                    view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e AS valor_todos,
                        CASE
                            WHEN round(view_ren_class_pessoas.classe_c * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2) = 0::numeric THEN 1::numeric
                            ELSE round(view_ren_class_pessoas.classe_c * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2)
                        END AS pc_setor
                   FROM ibgegrande.view_ren_class_pessoas
                  WHERE round(view_ren_class_pessoas.classe_c * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2) IS NOT NULL AND view_ren_class_pessoas.cod_setor::text ~~* '4216602%'::text
                UNION
                 SELECT view_ren_class_pessoas.cod_setor,
                    'Sociodemográfico'::text AS categoria,
                    'Classe D'::text AS classe,
                    view_ren_class_pessoas.classe_d AS valor_classe,
                    view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e AS valor_todos,
                        CASE
                            WHEN round(view_ren_class_pessoas.classe_d * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2) = 0::numeric THEN 1::numeric
                            ELSE round(view_ren_class_pessoas.classe_d * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2)
                        END AS pc_setor
                   FROM ibgegrande.view_ren_class_pessoas
                  WHERE round(view_ren_class_pessoas.classe_d * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2) IS NOT NULL AND view_ren_class_pessoas.cod_setor::text ~~* '4216602%'::text
                UNION
                 SELECT view_ren_class_pessoas.cod_setor,
                    'Sociodemográfico'::text AS categoria,
                    'Classe E'::text AS classe,
                    view_ren_class_pessoas.classe_e AS valor_classe,
                    view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e AS valor_todos,
                        CASE
                            WHEN round(view_ren_class_pessoas.classe_e * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2) = 0::numeric THEN 1::numeric
                            ELSE round(view_ren_class_pessoas.classe_e * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2)
                        END AS pc_setor
                   FROM ibgegrande.view_ren_class_pessoas
                  WHERE round(view_ren_class_pessoas.classe_e * 100::numeric / NULLIF(view_ren_class_pessoas.classe_a + view_ren_class_pessoas.classe_b + view_ren_class_pessoas.classe_c + view_ren_class_pessoas.classe_d + view_ren_class_pessoas.classe_e, 0::numeric), 2) IS NOT NULL AND view_ren_class_pessoas.cod_setor::text ~~* '4216602%'::text
                UNION
                 SELECT view_nucleo_familiar.cod_setor,
                    'Demográfico'::text AS categoria,
                    'Casados'::text AS classe,
                    view_nucleo_familiar.chefe_familia_casado AS valor_classe,
                    view_nucleo_familiar.chefe_familia_casado + view_nucleo_familiar.chefe_familia_solteiro AS valor_todos,
                        CASE
                            WHEN round(view_nucleo_familiar.chefe_familia_casado::numeric * 100::numeric / NULLIF(view_nucleo_familiar.chefe_familia_casado + view_nucleo_familiar.chefe_familia_solteiro, 0)::numeric, 2) = 0::numeric THEN 1::numeric
                            ELSE round(view_nucleo_familiar.chefe_familia_casado::numeric * 100::numeric / NULLIF(view_nucleo_familiar.chefe_familia_casado + view_nucleo_familiar.chefe_familia_solteiro, 0)::numeric, 2)
                        END AS pc_setor
                   FROM ibgegrande.view_nucleo_familiar
                  WHERE round(view_nucleo_familiar.chefe_familia_casado::numeric * 100::numeric / NULLIF(view_nucleo_familiar.chefe_familia_casado + view_nucleo_familiar.chefe_familia_solteiro, 0)::numeric, 2) IS NOT NULL AND view_nucleo_familiar.cod_setor::text ~~* '4216602%'::text
                UNION
                 SELECT view_nucleo_familiar.cod_setor,
                    'Demográfico'::text AS categoria,
                    'Solteiros'::text AS classe,
                    view_nucleo_familiar.chefe_familia_solteiro AS valor_classe,
                    view_nucleo_familiar.chefe_familia_solteiro + view_nucleo_familiar.chefe_familia_casado AS valor_todos,
                        CASE
                            WHEN round(view_nucleo_familiar.chefe_familia_solteiro::numeric * 100::numeric / NULLIF(view_nucleo_familiar.chefe_familia_solteiro + view_nucleo_familiar.chefe_familia_casado, 0)::numeric, 2) = 0::numeric THEN 1::numeric
                            ELSE round(view_nucleo_familiar.chefe_familia_solteiro::numeric * 100::numeric / NULLIF(view_nucleo_familiar.chefe_familia_solteiro + view_nucleo_familiar.chefe_familia_casado, 0)::numeric, 2)
                        END AS pc_setor
                   FROM ibgegrande.view_nucleo_familiar
                  WHERE round(view_nucleo_familiar.chefe_familia_solteiro::numeric * 100::numeric / NULLIF(view_nucleo_familiar.chefe_familia_solteiro + view_nucleo_familiar.chefe_familia_casado, 0)::numeric, 2) IS NOT NULL AND view_nucleo_familiar.cod_setor::text ~~* '4216602%'::text) foo
        )
 SELECT data.cod_setor,
    data.categoria,
    data.pc_setor,
    intervals.classe,
    ( SELECT arr.i
           FROM unnest(intervals.intervals) WITH ORDINALITY arr("interval", i)
          WHERE data.pc_setor >= arr."interval"
          ORDER BY arr."interval" DESC
         LIMIT 1) AS jenks_interval
   FROM data
     JOIN intervals ON data.classe = intervals.classe
WITH DATA;


CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_demografico_raio
TABLESPACE pg_default
AS SELECT un.gid_cliente,
    un.cidade,
    un.cod_setor,
    un.mor_total,
    un.dom_total,
    un.ano_censo,
    un.data_censo,
    un.st_distance,
    un.latlong
   FROM ( SELECT st.gid_cliente,
            st.cidade,
            st.mor_total,
            st.dom_total,
            st.cod_setor,
            '2010'::text AS ano_censo,
            to_date('2010-01-01'::text, 'YYYY-MM-DD'::text) AS data_censo,
            st.area_atingimento,
            st.centroide_atingimento,
            st.geom_atingimento,
            st.geom_setor,
            st.geom_terreno_buffer,
            st_distance(st.geom_terreno, st.geom_atingimento) AS st_distance,
            concat(st_y(st_transform(st.centroide_atingimento, 4326)), ', ', st_x(st_transform(st.centroide_atingimento, 4326))) AS latlong
           FROM ( SELECT ei.gid AS gid_cliente,
                    ei.cidade,
                    ei.geom_terreno,
                    ei.geom_terreno_buffer,
                    ib10.geom AS geom_setor,
                    st_area(ib10.geom) AS area_geom,
                    st_intersection(ei.geom_terreno_buffer, ib10.geom) AS geom_atingimento,
                    st_centroid(st_intersection(ei.geom_terreno_buffer, ib10.geom)) AS centroide_atingimento,
                    st_area(st_intersection(ei.geom_terreno_buffer, ib10.geom)) / st_area(ib10.geom) * 100::double precision AS area_atingimento,
                    ib10.cod_setor,
                    ib10.mor_total,
                    ib10.dom_total
                   FROM ( SELECT imoveis.gid,
                            imoveis.cidade,
                            st_transform(imoveis.geom, {{src}}) AS geom_terreno,
                            st_buffer(st_transform(imoveis.geom, {{src}}), {{st_distance}}::double precision) AS geom_terreno_buffer
                           FROM esteira.imoveis
                          WHERE imoveis.cidade::text ~~* '{{nm_mun}}'::text AND imoveis.uf::text ~~* '{{nm_uf}}'::text) ei,
                    ( SELECT view_mor_total.cod_setor,
                            view_mor_total.mor_total,
                            st_transform(view_mor_total.geom, {{src}}) AS geom,
                            view_dom_total.dom_total
                           FROM ibgegrande.view_mor_total
                             JOIN ibgegrande.view_dom_total ON view_mor_total.cod_setor::text = view_dom_total.cod_setor::text
                          WHERE view_mor_total.cod_setor::text ~~* '4216602%'::text) ib10) st
          WHERE st.geom_terreno_buffer && st.geom_setor AND st.area_atingimento > 25::double precision
        UNION
         SELECT st.gid_cliente,
            st.cidade,
            st.mor_total,
            st.dom_total,
            st.cod_setor,
            '2022'::text AS ano_censo,
            to_date('2022-01-01'::text, 'YYYY-MM-DD'::text) AS data_censo,
            st.area_atingimento,
            st.centroide_atingimento,
            st.geom_atingimento,
            st.geom_setor,
            st.geom_terreno_buffer,
            st_distance(st.geom_terreno, st.geom_atingimento) AS st_distance,
            concat(st_y(st_transform(st.centroide_atingimento, 4326)), ', ', st_x(st_transform(st.centroide_atingimento, 4326))) AS latlong
           FROM ( SELECT ei.gid AS gid_cliente,
                    ei.cidade,
                    ei.geom_terreno,
                    ei.geom_terreno_buffer,
                    ib22.geom AS geom_setor,
                    st_area(ib22.geom) AS area_geom,
                    st_intersection(ei.geom_terreno_buffer, ib22.geom) AS geom_atingimento,
                    st_centroid(st_intersection(ei.geom_terreno_buffer, ib22.geom)) AS centroide_atingimento,
                    st_area(st_intersection(ei.geom_terreno_buffer, ib22.geom)) / st_area(ib22.geom) * 100::double precision AS area_atingimento,
                    ib22.cod_setor,
                    ib22.mor_total,
                    ib22.dom_total
                   FROM ( SELECT imoveis.gid,
                            imoveis.cidade,
                            st_transform(imoveis.geom, {{src}}) AS geom_terreno,
                            st_buffer(st_transform(imoveis.geom, {{src}}), {{st_distance}}::double precision) AS geom_terreno_buffer
                           FROM esteira.imoveis
                          WHERE imoveis.cidade::text ~~* '{{nm_mun}}'::text AND imoveis.uf::text ~~* '{{nm_uf}}'::text) ei,
                    ( SELECT view_mor_total.cod_setor,
                            view_mor_total.mor_total,
                            st_transform(view_mor_total.geom, {{src}}) AS geom,
                            view_dom_total.dom_total
                           FROM ibge22.view_mor_total
                             JOIN ibge22.view_dom_total ON view_mor_total.cod_setor = view_dom_total.cod_setor
                          WHERE view_mor_total.cod_setor ~~* '4216602%'::text) ib22) st
          WHERE st.geom_terreno_buffer && st.geom_setor AND st.area_atingimento > 25::double precision) un
WITH DATA;




CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.monit_estatistica_media_trimestre
TABLESPACE pg_default
AS WITH bairro_do_anuncio_mais_proximo_do_imovel AS (
         SELECT a.gid,
            b.bairro_tratado,
            b.cidade
           FROM ( SELECT st_transform(st_centroid(imoveis.geom), 4326) AS geoms,
                    imoveis.gid,
                    imoveis.geom,
                    imoveis.cliente
                   FROM esteira.imoveis
                  WHERE imoveis.cidade::text = '{{nm_mun}}'::text AND imoveis.gid > 138) a
             CROSS JOIN LATERAL ( SELECT x.id,
                    x.bairro_tratado,
                    x.cidade,
                    x.geoms
                   FROM ( SELECT viewmat_imoveis_bi.id,
                            viewmat_imoveis_bi.bairro_tratado,
                            viewmat_imoveis_bi.cidade,
                            st_setsrid(viewmat_imoveis_bi.ponto, 4326) AS geoms
                           FROM geo_{{schema}}.viewmat_imoveis_bi
                          WHERE viewmat_imoveis_bi.cidade::text = '{{nm_mun}}'::text AND viewmat_imoveis_bi.ponto IS NOT NULL) x
                  ORDER BY (x.geoms <-> a.geom)
                 LIMIT 1) b
        ), view_imoveis_gidcliente AS (
         SELECT bairro_do_anuncio_mais_proximo_do_imovel.gid AS gid_cliente,
            monit_estatistica_media.valor_media,
            monit_estatistica_media.min,
            monit_estatistica_media.max,
            monit_estatistica_media.estado_sigla,
            monit_estatistica_media.cidade,
            monit_estatistica_media.bairro_tratado,
            monit_estatistica_media.tipo_imovel,
            monit_estatistica_media.tipo_negocio,
            monit_estatistica_media.num_quartos,
            to_date(to_char(monit_estatistica_media.data_tabela::timestamp with time zone, 'YYYY-DD-MM'::text), 'YYYY-MM-DD'::text) AS data_tabela
           FROM observatorio.monit_estatistica_media
             JOIN bairro_do_anuncio_mais_proximo_do_imovel ON monit_estatistica_media.bairro_tratado::text = bairro_do_anuncio_mais_proximo_do_imovel.bairro_tratado::text AND monit_estatistica_media.cidade::text = bairro_do_anuncio_mais_proximo_do_imovel.cidade::text
        )
 SELECT row_number() OVER () AS row_id,
    view_imoveis_gidcliente.gid_cliente,
    date_part('year'::text, view_imoveis_gidcliente.data_tabela)::integer AS ano,
    date_part('quarter'::text, view_imoveis_gidcliente.data_tabela)::integer AS trimestre,
    round(avg(view_imoveis_gidcliente.valor_media), 0) AS media_valor,
    view_imoveis_gidcliente.tipo_imovel,
    view_imoveis_gidcliente.tipo_negocio,
    view_imoveis_gidcliente.num_quartos,
    view_imoveis_gidcliente.cidade,
    view_imoveis_gidcliente.bairro_tratado,
    view_imoveis_gidcliente.estado_sigla
   FROM view_imoveis_gidcliente
  WHERE view_imoveis_gidcliente.cidade::text = '{{nm_mun}}'::text
  GROUP BY view_imoveis_gidcliente.gid_cliente, (date_part('year'::text, view_imoveis_gidcliente.data_tabela)), (date_part('quarter'::text, view_imoveis_gidcliente.data_tabela)), view_imoveis_gidcliente.tipo_imovel, view_imoveis_gidcliente.tipo_negocio, view_imoveis_gidcliente.bairro_tratado, view_imoveis_gidcliente.num_quartos, view_imoveis_gidcliente.estado_sigla, view_imoveis_gidcliente.cidade
WITH DATA;

CREATE INDEX IF NOT EXISTS idx_monit_estatistica ON geo_{{schema}}.monit_estatistica_media_trimestre USING btree (tipo_imovel, tipo_negocio, num_quartos, bairro_tratado, gid_cliente);
CREATE UNIQUE INDEX IF NOT EXISTS idx_monit_estatistica_row_id ON geo_{{schema}}.monit_estatistica_media_trimestre USING btree (row_id);


CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_cno_cidade
TABLESPACE pg_default
AS SELECT ee.id,
    ee.cno,
    ee.cnae,
    ee.cno_cnae_descricao,
    ee.destinacao,
    ee.categoria,
    ee.tipo_area,
    ee.area_total,
    ee.situacao,
    ee.situacao_descricao,
    ee.data_inicio,
    ee.data_situacao,
    ee.nome_empresarial,
    ee.endereco_consulta,
    ee.data_registro,
    ee.latitude,
    ee.longitude,
    ee.latlong,
    ee.geom2,
    ee.precisao_geocoding,
    ee.endereco_formatado,
    ee.ni_responsavel_vinculo,
    ee.cd_pais,
    ee.nm_pais,
    ee.data_inicio_responsabilidade,
    ee.cno_vinculado,
    ee.cep,
    ee.ni_responsavel,
    ee.qualificacao_responsavel,
    ee.qualificacao_responsavel_descricao,
    ee.cd_mun,
    ee.nm_mun,
    ee.tp_logr,
    ee.nm_logr,
    ee.cd_logr,
    ee.nm_bairro,
    ee.nm_estado,
    ee.caixa_postal,
    ee.complemento,
    ee.unidade_medida,
    ee.nome,
    ee.codigo_localizacao,
    ee.metragem,
    ee.tipo_area_complementar,
    ee.data_registro_cnae,
    ee.data_inicio_vinculo,
    ee.data_fim_vinculo,
    ee.data_registro_vinculo,
    ee.qualificacao_contribuinte,
    ee.qualificacao_contribuinte_descricao
   FROM ( SELECT DISTINCT ON (aa.cno) lpad(row_number() OVER ()::text, 6, '0'::text)::numeric AS id,
            aa.cno::numeric(12,0) AS cno,
            ac.cnae::numeric(7,0) AS cnae,
            ah.descricao AS cno_cnae_descricao,
            ab."Destinação" AS destinacao,
            ab.categoria,
            ab."Tipo de Área" AS tipo_area,
            aa."Área total"::numeric(11,2) AS area_total,
            aa."situação"::numeric(2,0) AS situacao,
            ae.descricao AS situacao_descricao,
            to_date(aa."Data de início"::text, 'YYYY-MM-DD'::text) AS data_inicio,
            to_date(aa."Data da situação"::text, 'YYYY-MM-DD'::text) AS data_situacao,
            aa."Nome empresarial" AS nome_empresarial,
            (((((((((((aa."Tipo de logradouro"::text || ' '::text) || aa.logradouro::text) || ', '::text) || aa."Número do logradouro"::text) || ' - '::text) || aa.bairro::text) || ', '::text) || aa."Nome do município"::text) || ' - '::text) || aa.estado::text) || ', '::text) || aa.cep::text AS endereco_consulta,
            to_date(aa."Data de registro"::text, 'YYYY-MM-DD'::text) AS data_registro,
            ai.latitude,
            ai.longitude,
            (ai.latitude || ','::text) || ai.longitude AS latlong,
            st_transform(st_setsrid(st_makepoint(ai.longitude::numeric::double precision, ai.latitude::numeric::double precision), 4326), {{src}}) AS geom2,
            ai.precisao_geocoding,
            ai.endereco_formatado,
            ad."NI do responsável" AS ni_responsavel_vinculo,
            aa."Código do Pais"::text AS cd_pais,
            aa."Nome do pais" AS nm_pais,
            to_date(aa."Data de inicio da responsabilidade"::text, 'YYYY-MM-DD'::text) AS data_inicio_responsabilidade,
            aa."CNO vinculado" AS cno_vinculado,
            aa.cep,
            aa."NI do responsável" AS ni_responsavel,
            aa."Qualificação do responsavel"::numeric(4,0) AS qualificacao_responsavel,
            ag.descricao AS qualificacao_responsavel_descricao,
            aa."Código do municipio"::numeric(4,0) AS cd_mun,
            aa."Nome do município" AS nm_mun,
            aa."Tipo de logradouro" AS tp_logr,
            aa.logradouro AS nm_logr,
            aa."Número do logradouro" AS cd_logr,
            aa.bairro AS nm_bairro,
            aa.estado AS nm_estado,
            aa."Caixa Postal" AS caixa_postal,
            aa.complemento,
            aa."Unidade de medida" AS unidade_medida,
            aa.nome,
            aa."Código de localização" AS codigo_localizacao,
            ab.metragem::numeric(22,0) AS metragem,
            ab."Tipo de Área Complementar" AS tipo_area_complementar,
            to_date(ac."Data de registro"::text, 'YYYY-MM-DD'::text) AS data_registro_cnae,
            to_date(ad."Data de início"::text, 'YYYY-MM-DD'::text) AS data_inicio_vinculo,
            to_date(ad."Data de fim"::text, 'YYYY-MM-DD'::text) AS data_fim_vinculo,
            to_date(ad."Data de registro"::text, 'YYYY-MM-DD'::text) AS data_registro_vinculo,
            ad."Qualificação do contribuinte"::numeric(4,0) AS qualificacao_contribuinte,
            af.descricao AS qualificacao_contribuinte_descricao
           FROM cno.cno aa
             LEFT JOIN cno.cno_areas ab ON aa.cno::text = ab.cno::text
             LEFT JOIN cno.cno_cnaes ac ON ab.cno::text = ac.cno::text
             LEFT JOIN cno.cno_vinculos ad ON ac.cno::text = ad.cno::text
             LEFT JOIN cno.dic_cno_situacao ae ON aa."situação"::numeric = ae.atributo
             LEFT JOIN cno.dic_cno_qualificacao_contribuinte af ON ad."Qualificação do contribuinte"::text = af.atributo
             LEFT JOIN cno.dic_cno_qualificacao_responsavel ag ON aa."Qualificação do responsavel"::text = ag.atributo
             LEFT JOIN cno.dic_cno_cnaes ah ON ac.cnae::text = ah.atributo::text
             LEFT JOIN cno.tb_localizacao ai ON aa.cno::text = ai.cno::text
          WHERE aa."Nome do município"::text = '{{nm_mun_maiusculocomacento}}'::text) ee,
    ( SELECT cad_mun.nm_mun,
            st_transform(cad_mun.geom, {{src}}) AS geom
           FROM geo_{{schema}}.cad_mun) ef
  WHERE ef.geom && ee.geom2 AND st_contains(ef.geom, ee.geom2)
WITH DATA;


CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_imoveis_bi_shortstay_cidade
TABLESPACE pg_default
AS SELECT a.gid,
    a.airbnb_property_id,
    a.vrbo_property_id,
    a.listing_type,
    a.bedrooms,
    a.bathrooms,
    a.accommodates,
    a.rating,
    a.reviews,
    a.title,
    a.revenue_ltm,
    a.revenue_potential_ltm,
    a.occupancy_rate_ltm,
    a.average_daily_rate_ltm,
    a.days_available_ltm,
    a.lat,
    a.lon,
    a.data_raspagem,
    a.ativo,
    concat(a.lat, ',', a.lon) AS latlon,
    a.geom_airbnb,
    ef.nm_mun,
    initcap(uep.nm_bairro::text) AS nm_bairro
   FROM ( SELECT airdna_geral.gid,
            airdna_geral.airbnb_property_id,
            airdna_geral.vrbo_property_id,
            airdna_geral.listing_type,
            airdna_geral.bedrooms,
            airdna_geral.bathrooms,
            airdna_geral.accommodates,
            airdna_geral.rating,
            airdna_geral.reviews,
            airdna_geral.title,
            airdna_geral.revenue_ltm,
            airdna_geral.revenue_potential_ltm,
            airdna_geral.occupancy_rate_ltm,
            airdna_geral.average_daily_rate_ltm,
            airdna_geral.days_available_ltm,
            airdna_geral.lat,
            airdna_geral.lon,
            airdna_geral.data_raspagem,
            airdna_geral.ativo,
            st_transform(st_setsrid(st_makepoint(airdna_geral.lon::numeric::double precision, airdna_geral.lat::numeric::double precision), 4326), {{src}}) AS geom_airbnb
           FROM airbnb.airdna_geral) a,
    ( SELECT cad_mun.nm_mun,
            st_transform(cad_mun.geom, {{src}}) AS geom
           FROM geo_{{schema}}.cad_mun) ef,
    ( SELECT cad_bairro.nm_bairro,
            cad_bairro.geom
           FROM geo_{{schema}}.cad_bairro) uep
  WHERE ef.geom && a.geom_airbnb AND st_contains(ef.geom, a.geom_airbnb) AND uep.geom && a.geom_airbnb AND st_contains(uep.geom, a.geom_airbnb)
WITH DATA;

CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_sociodemografico_cross
TABLESPACE pg_default
AS SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.mor_homem IS NOT NULL THEN viewmat_sociodemografico.mor_homem
            ELSE NULL::numeric
        END AS valor,
    'Homens'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.mor_mulhe IS NOT NULL THEN viewmat_sociodemografico.mor_mulhe
            ELSE NULL::numeric
        END AS valor,
    'Mulheres'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.mor_infan IS NOT NULL THEN viewmat_sociodemografico.mor_infan
            ELSE NULL::numeric
        END AS valor,
    'Infância'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.mor_jovem IS NOT NULL THEN viewmat_sociodemografico.mor_jovem
            ELSE NULL::numeric
        END AS valor,
    'Jovens'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.mor_adult IS NOT NULL THEN viewmat_sociodemografico.mor_adult
            ELSE NULL::numeric
        END AS valor,
    'Adultos'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.mor_idoso IS NOT NULL THEN viewmat_sociodemografico.mor_idoso
            ELSE NULL::numeric
        END AS valor,
    'Idosos'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.classe_a IS NOT NULL THEN viewmat_sociodemografico.classe_a
            ELSE NULL::numeric
        END AS valor,
    'Classe A'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.classe_b IS NOT NULL THEN viewmat_sociodemografico.classe_b
            ELSE NULL::numeric
        END AS valor,
    'Classe B'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.classe_c IS NOT NULL THEN viewmat_sociodemografico.classe_c
            ELSE NULL::numeric
        END AS valor,
    'Classe C'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.classe_d IS NOT NULL THEN viewmat_sociodemografico.classe_d
            ELSE NULL::numeric
        END AS valor,
    'Classe D'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.classe_e IS NOT NULL THEN viewmat_sociodemografico.classe_e
            ELSE NULL::numeric
        END AS valor,
    'Classe E'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ren_h_cla IS NOT NULL THEN viewmat_sociodemografico.ren_m_cla + viewmat_sociodemografico.ren_h_cla
            ELSE NULL::numeric
        END AS valor,
    'Classe A - Renda Total'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ren_h_clb IS NOT NULL THEN viewmat_sociodemografico.ren_m_clb + viewmat_sociodemografico.ren_h_clb
            ELSE NULL::numeric
        END AS valor,
    'Classe B - Renda Total'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ren_h_clc IS NOT NULL THEN viewmat_sociodemografico.ren_m_clc + viewmat_sociodemografico.ren_h_clc
            ELSE NULL::numeric
        END AS valor,
    'Classe C - Renda Total'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ren_h_cld IS NOT NULL THEN viewmat_sociodemografico.ren_m_cld + viewmat_sociodemografico.ren_h_cld
            ELSE NULL::numeric
        END AS valor,
    'Classe D - Renda Total'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ren_h_cle IS NOT NULL THEN viewmat_sociodemografico.ren_m_cle + viewmat_sociodemografico.ren_h_cle
            ELSE NULL::numeric
        END AS valor,
    'Classe E - Renda Total'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ren_h_cla IS NOT NULL THEN viewmat_sociodemografico.ren_h_cla
            ELSE NULL::numeric
        END AS valor,
    'Classe A - Renda Total Homens'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ren_h_clb IS NOT NULL THEN viewmat_sociodemografico.ren_h_clb
            ELSE NULL::numeric
        END AS valor,
    'Classe B - Renda Total Homens'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ren_h_clc IS NOT NULL THEN viewmat_sociodemografico.ren_h_clc
            ELSE NULL::numeric
        END AS valor,
    'Classe C - Renda Total Homens'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ren_h_cld IS NOT NULL THEN viewmat_sociodemografico.ren_h_cld
            ELSE NULL::numeric
        END AS valor,
    'Classe D - Renda Total Homens'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ren_h_cle IS NOT NULL THEN viewmat_sociodemografico.ren_h_cle
            ELSE NULL::numeric
        END AS valor,
    'Classe E - Renda Total Homens'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ren_m_cla IS NOT NULL THEN viewmat_sociodemografico.ren_m_cla
            ELSE NULL::numeric
        END AS valor,
    'Classe A - Renda Total Mulheres'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ren_m_clb IS NOT NULL THEN viewmat_sociodemografico.ren_m_clb
            ELSE NULL::numeric
        END AS valor,
    'Classe B - Renda Total Mulheres'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ren_m_clc IS NOT NULL THEN viewmat_sociodemografico.ren_m_clc
            ELSE NULL::numeric
        END AS valor,
    'Classe C - Renda Total Mulheres'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ren_m_cld IS NOT NULL THEN viewmat_sociodemografico.ren_m_cld
            ELSE NULL::numeric
        END AS valor,
    'Classe D - Renda Total Mulheres'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ren_m_cle IS NOT NULL THEN viewmat_sociodemografico.ren_m_cle
            ELSE NULL::numeric
        END AS valor,
    'Classe E - Renda Total Mulheres'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ttl_m_cla IS NOT NULL THEN viewmat_sociodemografico.ttl_m_cla
            ELSE NULL::numeric
        END AS valor,
    'Classe A - Pessoas Total Mulheres'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ttl_m_clb IS NOT NULL THEN viewmat_sociodemografico.ttl_m_clb
            ELSE NULL::numeric
        END AS valor,
    'Classe B - Pessoas Total Mulheres'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ttl_m_clc IS NOT NULL THEN viewmat_sociodemografico.ttl_m_clc
            ELSE NULL::numeric
        END AS valor,
    'Classe C - Pessoas Total Mulheres'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ttl_m_cld IS NOT NULL THEN viewmat_sociodemografico.ttl_m_cld
            ELSE NULL::numeric
        END AS valor,
    'Classe D - Pessoas Total Mulheres'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ttl_m_cle IS NOT NULL THEN viewmat_sociodemografico.ttl_m_cle
            ELSE NULL::numeric
        END AS valor,
    'Classe E - Pessoas Total Mulheres'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ttl_h_cla IS NOT NULL THEN viewmat_sociodemografico.ttl_h_cla
            ELSE NULL::numeric
        END AS valor,
    'Classe A - Pessoas Total Homens'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ttl_h_clb IS NOT NULL THEN viewmat_sociodemografico.ttl_h_clb
            ELSE NULL::numeric
        END AS valor,
    'Classe B - Pessoas Total Homens'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ttl_h_clc IS NOT NULL THEN viewmat_sociodemografico.ttl_h_clc
            ELSE NULL::numeric
        END AS valor,
    'Classe C - Pessoas Total Homens'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ttl_h_cld IS NOT NULL THEN viewmat_sociodemografico.ttl_h_cld
            ELSE NULL::numeric
        END AS valor,
    'Classe D - Pessoas Total Homens'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
UNION
 SELECT viewmat_sociodemografico.gid_cliente,
    viewmat_sociodemografico.cd_setor_imovel,
    viewmat_sociodemografico.cd_setor_entorno,
    viewmat_sociodemografico.latlong,
    viewmat_sociodemografico.ano_censo,
    viewmat_sociodemografico.st_distance,
        CASE
            WHEN viewmat_sociodemografico.ttl_h_cle IS NOT NULL THEN viewmat_sociodemografico.ttl_h_cle
            ELSE NULL::numeric
        END AS valor,
    'Classe E - Pessoas Total Homens'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico
WITH DATA;


CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_sociodemografico_raio
TABLESPACE pg_default
AS WITH imoveis_filtrados AS (
         SELECT imoveis.gid,
            imoveis.cidade,
            st_transform(imoveis.geom, {{src}}) AS geom_terreno,
            st_buffer(st_snaptogrid(st_transform(imoveis.geom, {{src}}), 0.001::double precision), {{st_distance}}::double precision) AS geom_terreno_buffer
           FROM esteira.imoveis
          WHERE imoveis.cidade::text ~~* '{{nm_mun}}'::text AND imoveis.uf::text ~~* '{{nm_uf}}'::text AND st_isvalid(imoveis.geom)
        ), dados_ibge_2010 AS (
         SELECT vm.cod_setor,
            vm.mor_total,
            vdt.dom_total,
            st_snaptogrid(st_transform(st_makevalid(vm.geom), {{src}}), 0.001::double precision) AS geom,
            vd.casas::double precision AS casas,
            vd.apartamentos::double precision AS apartamentos,
            vd.condominios::double precision AS condominios,
            vmd.mor_1::double precision AS mor_1,
            vmd.mor_2::double precision AS mor_2,
            vmd.mor_3::double precision AS mor_3,
            vmd.mor_4::double precision AS mor_4,
            vmd.mor_5::double precision AS mor_5,
            vmfx.mor_infan::double precision AS mor_infan,
            vmfx.mor_jovem::double precision AS mor_jovem,
            vmfx.mor_adult::double precision AS mor_adult,
            vmfx.mor_idoso::double precision AS mor_idoso,
            vmh.mor_homem::double precision AS mor_homem,
            vmh.mor_mulhe::double precision AS mor_mulhe,
            0::double precision AS unipessoal,
            0::double precision AS nuclear,
            0::double precision AS estendida,
            0::double precision AS composta,
            0::double precision AS sexo_diferente,
            0::double precision AS sexo_igual,
            0::double precision AS sexo_diferente_igual,
            0::double precision AS sem_conjuge,
            0::double precision AS dom_res_conjuge_sem_filhos,
            0::double precision AS dom_res_conjuge_filho_ambos,
            0::double precision AS dom_res_conjuge_filho_alguem,
            0::double precision AS dom_res_semconjuge_com_filho,
            0::double precision AS dom_res_outracomposicao,
            0::double precision AS agua_rede,
            0::double precision AS agua_pocoprofundo,
            0::double precision AS agua_pocoraso,
            0::double precision AS agua_fonte,
            0::double precision AS agua_pipa,
            0::double precision AS agua_chuva,
            0::double precision AS agua_rios,
            0::double precision AS agua_outro,
            0::double precision AS lixo_coletado,
            0::double precision AS lixo_depositado,
            0::double precision AS lixo_queimado,
            0::double precision AS lixo_enterrado,
            0::double precision AS lixo_jogado,
            0::double precision AS lixo_outrodestino,
            0::double precision AS banheiro_um,
            0::double precision AS banheiro_dois,
            0::double precision AS banheiro_tres,
            0::double precision AS banheiro_quatromais,
            0::double precision AS banheiro_comum,
            0::double precision AS banheiro_buraco,
            0::double precision AS banheiro_sem,
            0::double precision AS branca,
            0::double precision AS preta,
            0::double precision AS amarela,
            0::double precision AS parda,
            0::double precision AS indigena,
            0::double precision AS alf_total,
            0::double precision AS alf_15_19,
            0::double precision AS alf_20_24,
            0::double precision AS alf_25_29,
            0::double precision AS alf_30_34,
            0::double precision AS alf_35_39,
            0::double precision AS alf_40_44,
            0::double precision AS alf_45_49,
            0::double precision AS alf_50_54,
            0::double precision AS alf_55_59,
            0::double precision AS alf_60_64,
            0::double precision AS alf_65_69,
            0::double precision AS alf_70_79,
            0::double precision AS alf_80mais,
            0::double precision AS h_0_a_4,
            0::double precision AS h_5_a_9,
            0::double precision AS h_10_a_14,
            0::double precision AS h_15_a_19,
            0::double precision AS h_20_a_24,
            0::double precision AS h_25_a_29,
            0::double precision AS h_30_a_39,
            0::double precision AS h_40_a_49,
            0::double precision AS h_50_a_59,
            0::double precision AS h_60_a_69,
            0::double precision AS h_70_mais,
            0::double precision AS m_0_a_4,
            0::double precision AS m_5_a_9,
            0::double precision AS m_10_a_14,
            0::double precision AS m_15_a_19,
            0::double precision AS m_20_a_24,
            0::double precision AS m_25_a_29,
            0::double precision AS m_30_a_39,
            0::double precision AS m_40_a_49,
            0::double precision AS m_50_a_59,
            0::double precision AS m_60_a_69,
            0::double precision AS m_70_mais,
            0::double precision AS casados_10_a_14,
            0::double precision AS casados_15_a_19,
            0::double precision AS casados_20_a_24,
            0::double precision AS casados_25_a_29,
            0::double precision AS casados_30_a_34,
            0::double precision AS casados_35_a_39,
            0::double precision AS casados_40_a_44,
            0::double precision AS casados_45_a_49,
            0::double precision AS casados_50_a_54,
            0::double precision AS casados_55_a_59,
            0::double precision AS casados_60_a_64,
            0::double precision AS casados_65_a_69,
            0::double precision AS casados_70_a_74,
            0::double precision AS casados_75_a_79,
            0::double precision AS casados_80_mais,
            0::double precision AS mor_total_permanentes,
            0::double precision AS mor_total_improvisados,
            0::double precision AS mor_total_coletivos,
            0::double precision AS dom_total_particulares,
            0::double precision AS dom_total_improvisados,
            0::double precision AS dom_total_coletivos,
            0::double precision AS domicilios_tipo_outros,
            0::double precision AS esgoto_rede_geral,
            0::double precision AS esgoto_fossa_septica_com_rede,
            0::double precision AS esgoto_fossa_septica_sem_rede,
            0::double precision AS esgoto_fossa_rudimentar,
            0::double precision AS esgoto_vala,
            0::double precision AS esgoto_rio,
            0::double precision AS esgoto_outra_forma,
            0::double precision AS esgoto_inexistente
           FROM ibgegrande.view_mor_total vm
             JOIN ibgegrande.view_dom_tipo_situacao vd ON vm.cod_setor::text = vd.cod_setor::text
             JOIN ibgegrande.view_dom_total vdt ON vm.cod_setor::text = vdt.cod_setor::text
             JOIN ibgegrande.view_mor_dom vmd ON vm.cod_setor::text = vmd.cod_setor::text
             JOIN ibgegrande.view_mor_fxeta vmfx ON vm.cod_setor::text = vmfx.cod_setor::text
             JOIN ibgegrande.view_mor_homul vmh ON vm.cod_setor::text = vmh.cod_setor::text
          WHERE vm.cod_setor::text ~~ '4216602%'::text AND st_isvalid(vm.geom)
        ), dados_ibge_2022 AS (
         SELECT vm.cod_setor,
            vm.mor_total,
            vdt.dom_total,
            st_snaptogrid(st_transform(st_makevalid(vm.geom), {{src}}), 0.001::double precision) AS geom,
            vd.casas::double precision AS casas,
            vd.apartamentos::double precision AS apartamentos,
            vd.condominios::double precision AS condominios,
            vmd.mor_1::double precision AS mor_1,
            vmd.mor_2::double precision AS mor_2,
            vmd.mor_3::double precision AS mor_3,
            vmd.mor_4::double precision AS mor_4,
            vmd.mor_5::double precision AS mor_5,
            vmfx.mor_infan::double precision AS mor_infan,
            vmfx.mor_jovem::double precision AS mor_jovem,
            vmfx.mor_adult::double precision AS mor_adult,
            vmfx.mor_idoso::double precision AS mor_idoso,
            vmh.mor_homem::double precision AS mor_homem,
            vmh.mor_mulhe::double precision AS mor_mulhe,
            vde.unipessoal::double precision AS unipessoal,
            vde.nuclear::double precision AS nuclear,
            vde.estendida::double precision AS estendida,
            vde.composta::double precision AS composta,
            vc.sexo_diferente::double precision AS sexo_diferente,
            vc.sexo_igual::double precision AS sexo_igual,
            vc.sexo_diferente_igual::double precision AS sexo_diferente_igual,
            vc.sem_conjuge::double precision AS sem_conjuge,
            vc.dom_res_conjuge_sem_filhos::double precision AS dom_res_conjuge_sem_filhos,
            vc.dom_res_conjuge_filho_ambos::double precision AS dom_res_conjuge_filho_ambos,
            vc.dom_res_conjuge_filho_alguem::double precision AS dom_res_conjuge_filho_alguem,
            vc.dom_res_semconjuge_com_filho::double precision AS dom_res_semconjuge_com_filho,
            vc.dom_res_outracomposicao::double precision AS dom_res_outracomposicao,
            vdi.agua_rede::double precision AS agua_rede,
            vdi.agua_pocoprofundo::double precision AS agua_pocoprofundo,
            vdi.agua_pocoraso::double precision AS agua_pocoraso,
            vdi.agua_fonte::double precision AS agua_fonte,
            vdi.agua_pipa::double precision AS agua_pipa,
            vdi.agua_chuva::double precision AS agua_chuva,
            vdi.agua_rios::double precision AS agua_rios,
            vdi.agua_outro::double precision AS agua_outro,
            vdi.lixo_coletado::double precision AS lixo_coletado,
            vdi.lixo_depositado::double precision AS lixo_depositado,
            vdi.lixo_queimado::double precision AS lixo_queimado,
            vdi.lixo_enterrado::double precision AS lixo_enterrado,
            vdi.lixo_jogado::double precision AS lixo_jogado,
            vdi.lixo_outrodestino::double precision AS lixo_outrodestino,
            vdi.banheiro_um::double precision AS banheiro_um,
            vdi.banheiro_dois::double precision AS banheiro_dois,
            vdi.banheiro_tres::double precision AS banheiro_tres,
            vdi.banheiro_quatromais::double precision AS banheiro_quatromais,
            vdi.banheiro_comum::double precision AS banheiro_comum,
            vdi.banheiro_buraco::double precision AS banheiro_buraco,
            vdi.banheiro_sem::double precision AS banheiro_sem,
            vdr.branca::double precision AS branca,
            vdr.preta::double precision AS preta,
            vdr.amarela::double precision AS amarela,
            vdr.parda::double precision AS parda,
            vdr.indigena::double precision AS indigena,
            valf.alf_total::double precision AS alf_total,
            valf.alf_15_19::double precision AS alf_15_19,
            valf.alf_20_24::double precision AS alf_20_24,
            valf.alf_25_29::double precision AS alf_25_29,
            valf.alf_30_34::double precision AS alf_30_34,
            valf.alf_35_39::double precision AS alf_35_39,
            valf.alf_40_44::double precision AS alf_40_44,
            valf.alf_45_49::double precision AS alf_45_49,
            valf.alf_50_54::double precision AS alf_50_54,
            valf.alf_55_59::double precision AS alf_55_59,
            valf.alf_60_64::double precision AS alf_60_64,
            valf.alf_65_69::double precision AS alf_65_69,
            valf.alf_70_79::double precision AS alf_70_79,
            valf.alf_80mais::double precision AS alf_80mais,
            vmp.h_0_a_4::double precision AS h_0_a_4,
            vmp.h_5_a_9::double precision AS h_5_a_9,
            vmp.h_10_a_14::double precision AS h_10_a_14,
            vmp.h_15_a_19::double precision AS h_15_a_19,
            vmp.h_20_a_24::double precision AS h_20_a_24,
            vmp.h_25_a_29::double precision AS h_25_a_29,
            vmp.h_30_a_39::double precision AS h_30_a_39,
            vmp.h_40_a_49::double precision AS h_40_a_49,
            vmp.h_50_a_59::double precision AS h_50_a_59,
            vmp.h_60_a_69::double precision AS h_60_a_69,
            vmp.h_70_mais::double precision AS h_70_mais,
            vmp.m_0_a_4::double precision AS m_0_a_4,
            vmp.m_5_a_9::double precision AS m_5_a_9,
            vmp.m_10_a_14::double precision AS m_10_a_14,
            vmp.m_15_a_19::double precision AS m_15_a_19,
            vmp.m_20_a_24::double precision AS m_20_a_24,
            vmp.m_25_a_29::double precision AS m_25_a_29,
            vmp.m_30_a_39::double precision AS m_30_a_39,
            vmp.m_40_a_49::double precision AS m_40_a_49,
            vmp.m_50_a_59::double precision AS m_50_a_59,
            vmp.m_60_a_69::double precision AS m_60_a_69,
            vmp.m_70_mais::double precision AS m_70_mais,
            vc.casados_10_a_14::double precision AS casados_10_a_14,
            vc.casados_15_a_19::double precision AS casados_15_a_19,
            vc.casados_20_a_24::double precision AS casados_20_a_24,
            vc.casados_25_a_29::double precision AS casados_25_a_29,
            vc.casados_30_a_34::double precision AS casados_30_a_34,
            vc.casados_35_a_39::double precision AS casados_35_a_39,
            vc.casados_40_a_44::double precision AS casados_40_a_44,
            vc.casados_45_a_49::double precision AS casados_45_a_49,
            vc.casados_50_a_54::double precision AS casados_50_a_54,
            vc.casados_55_a_59::double precision AS casados_55_a_59,
            vc.casados_60_a_64::double precision AS casados_60_a_64,
            vc.casados_65_a_69::double precision AS casados_65_a_69,
            vc.casados_70_a_74::double precision AS casados_70_a_74,
            vc.casados_75_a_79::double precision AS casados_75_a_79,
            vc.casados_80_mais::double precision AS casados_80_mais,
            vm.mor_total_permanentes::double precision AS mor_total_permanentes,
            vm.mor_total_improvisados::double precision AS mor_total_improvisados,
            vm.mor_total_coletivos::double precision AS mor_total_coletivos,
            vdt.dom_total_particulares::double precision AS dom_total_particulares,
            vdt.dom_total_improvisados::double precision AS dom_total_improvisados,
            vdt.dom_total_coletivos::double precision AS dom_total_coletivos,
            vd.domicilios_tipo_outros::double precision AS domicilios_tipo_outros,
            vdi.esgoto_rede_geral::double precision AS esgoto_rede_geral,
            vdi.esgoto_fossa_septica_com_rede::double precision AS esgoto_fossa_septica_com_rede,
            vdi.esgoto_fossa_septica_sem_rede::double precision AS esgoto_fossa_septica_sem_rede,
            vdi.esgoto_fossa_rudimentar::double precision AS esgoto_fossa_rudimentar,
            vdi.esgoto_vala::double precision AS esgoto_vala,
            vdi.esgoto_rio::double precision AS esgoto_rio,
            vdi.esgoto_outra_forma::double precision AS esgoto_outra_forma,
            vdi.esgoto_inexistente::double precision AS esgoto_inexistente
           FROM ibge22.view_mor_total22 vm
             JOIN ibge22.view_dom_tipo_situacao22 vd ON vm.cod_setor::text = vd.cod_setor::text
             JOIN ibge22.view_dom_total22 vdt ON vm.cod_setor::text = vdt.cod_setor::text
             JOIN ibge22.view_mor_dom22 vmd ON vm.cod_setor::text = vmd.cod_setor::text
             JOIN ibge22.view_mor_fxeta22 vmfx ON vm.cod_setor::text = vmfx.cod_setor::text
             JOIN ibge22.view_mor_homul22 vmh ON vm.cod_setor::text = vmh.cod_setor::text
             JOIN ibge22.view_dom_especie22 vde ON vm.cod_setor::text = vde.cod_setor::text
             JOIN ibge22.view_conjuges22 vc ON vm.cod_setor::text = vc.cod_setor::text
             JOIN ibge22.view_dom_infra22 vdi ON vm.cod_setor::text = vdi.cod_setor::text
             JOIN ibge22.view_dom_raca22 vdr ON vm.cod_setor::text = vdr.cod_setor::text
             JOIN ibge22.view_alfabetizados22 valf ON vm.cod_setor::text = valf.cod_setor::text
             JOIN ibge22.view_mor_piramide22 vmp ON vm.cod_setor::text = vmp.cod_setor::text
          WHERE vm.cod_setor::text ~~ '4216602%'::text AND st_isvalid(vm.geom)
        ), dados_combinados AS (
         SELECT ei.gid AS gid_cliente,
            ei.cidade,
            ei.geom_terreno,
            ei.geom_terreno_buffer,
            ib.geom AS geom_setor,
            st_area(ib.geom) AS area_geom,
            st_intersection(ei.geom_terreno_buffer, ib.geom) AS geom_atingimento,
            st_centroid(st_intersection(ei.geom_terreno_buffer, ib.geom)) AS centroide_atingimento,
            st_area(st_intersection(ei.geom_terreno_buffer, ib.geom)) / st_area(ib.geom) * 100::double precision AS area_atingimento,
            ib.cod_setor,
            ib.mor_total,
            ib.dom_total,
            ib.casas,
            ib.apartamentos,
            ib.condominios,
            ib.mor_1,
            ib.mor_2,
            ib.mor_3,
            ib.mor_4,
            ib.mor_5,
            ib.mor_infan,
            ib.mor_jovem,
            ib.mor_adult,
            ib.mor_idoso,
            ib.mor_homem,
            ib.mor_mulhe,
            ib.unipessoal,
            ib.nuclear,
            ib.estendida,
            ib.composta,
            ib.sexo_diferente,
            ib.sexo_igual,
            ib.sexo_diferente_igual,
            ib.sem_conjuge,
            ib.dom_res_conjuge_sem_filhos,
            ib.dom_res_conjuge_filho_ambos,
            ib.dom_res_conjuge_filho_alguem,
            ib.dom_res_semconjuge_com_filho,
            ib.dom_res_outracomposicao,
            ib.agua_rede,
            ib.agua_pocoprofundo,
            ib.agua_pocoraso,
            ib.agua_fonte,
            ib.agua_pipa,
            ib.agua_chuva,
            ib.agua_rios,
            ib.agua_outro,
            ib.lixo_coletado,
            ib.lixo_depositado,
            ib.lixo_queimado,
            ib.lixo_enterrado,
            ib.lixo_jogado,
            ib.lixo_outrodestino,
            ib.banheiro_um,
            ib.banheiro_dois,
            ib.banheiro_tres,
            ib.banheiro_quatromais,
            ib.banheiro_comum,
            ib.banheiro_buraco,
            ib.banheiro_sem,
            ib.branca,
            ib.preta,
            ib.amarela,
            ib.parda,
            ib.indigena,
            ib.alf_total,
            ib.alf_15_19,
            ib.alf_20_24,
            ib.alf_25_29,
            ib.alf_30_34,
            ib.alf_35_39,
            ib.alf_40_44,
            ib.alf_45_49,
            ib.alf_50_54,
            ib.alf_55_59,
            ib.alf_60_64,
            ib.alf_65_69,
            ib.alf_70_79,
            ib.alf_80mais,
            ib.h_0_a_4,
            ib.h_5_a_9,
            ib.h_10_a_14,
            ib.h_15_a_19,
            ib.h_20_a_24,
            ib.h_25_a_29,
            ib.h_30_a_39,
            ib.h_40_a_49,
            ib.h_50_a_59,
            ib.h_60_a_69,
            ib.h_70_mais,
            ib.m_0_a_4,
            ib.m_5_a_9,
            ib.m_10_a_14,
            ib.m_15_a_19,
            ib.m_20_a_24,
            ib.m_25_a_29,
            ib.m_30_a_39,
            ib.m_40_a_49,
            ib.m_50_a_59,
            ib.m_60_a_69,
            ib.m_70_mais,
            ib.casados_10_a_14,
            ib.casados_15_a_19,
            ib.casados_20_a_24,
            ib.casados_25_a_29,
            ib.casados_30_a_34,
            ib.casados_35_a_39,
            ib.casados_40_a_44,
            ib.casados_45_a_49,
            ib.casados_50_a_54,
            ib.casados_55_a_59,
            ib.casados_60_a_64,
            ib.casados_65_a_69,
            ib.casados_70_a_74,
            ib.casados_75_a_79,
            ib.casados_80_mais,
            ib.mor_total_permanentes,
            ib.mor_total_improvisados,
            ib.mor_total_coletivos,
            ib.dom_total_particulares,
            ib.dom_total_improvisados,
            ib.dom_total_coletivos,
            ib.domicilios_tipo_outros,
            ib.esgoto_rede_geral,
            ib.esgoto_fossa_septica_com_rede,
            ib.esgoto_fossa_septica_sem_rede,
            ib.esgoto_fossa_rudimentar,
            ib.esgoto_vala,
            ib.esgoto_rio,
            ib.esgoto_outra_forma,
            ib.esgoto_inexistente,
            '2010'::text AS ano_censo,
            to_date('2010-01-01'::text, 'YYYY-MM-DD'::text) AS data_censo
           FROM imoveis_filtrados ei
             JOIN dados_ibge_2010 ib ON st_intersects(ei.geom_terreno_buffer, ib.geom)
          WHERE (st_area(st_intersection(ei.geom_terreno_buffer, ib.geom)) / st_area(ib.geom) * 100::double precision) > 25::double precision AND st_isvalid(ei.geom_terreno_buffer) AND st_isvalid(ib.geom)
        UNION ALL
         SELECT ei.gid AS gid_cliente,
            ei.cidade,
            ei.geom_terreno,
            ei.geom_terreno_buffer,
            ib.geom AS geom_setor,
            st_area(ib.geom) AS area_geom,
            st_intersection(ei.geom_terreno_buffer, ib.geom) AS geom_atingimento,
            st_centroid(st_intersection(ei.geom_terreno_buffer, ib.geom)) AS centroide_atingimento,
            st_area(st_intersection(ei.geom_terreno_buffer, ib.geom)) / st_area(ib.geom) * 100::double precision AS area_atingimento,
            ib.cod_setor,
            ib.mor_total,
            ib.dom_total,
            ib.casas,
            ib.apartamentos,
            ib.condominios,
            ib.mor_1,
            ib.mor_2,
            ib.mor_3,
            ib.mor_4,
            ib.mor_5,
            ib.mor_infan,
            ib.mor_jovem,
            ib.mor_adult,
            ib.mor_idoso,
            ib.mor_homem,
            ib.mor_mulhe,
            ib.unipessoal,
            ib.nuclear,
            ib.estendida,
            ib.composta,
            ib.sexo_diferente,
            ib.sexo_igual,
            ib.sexo_diferente_igual,
            ib.sem_conjuge,
            ib.dom_res_conjuge_sem_filhos,
            ib.dom_res_conjuge_filho_ambos,
            ib.dom_res_conjuge_filho_alguem,
            ib.dom_res_semconjuge_com_filho,
            ib.dom_res_outracomposicao,
            ib.agua_rede,
            ib.agua_pocoprofundo,
            ib.agua_pocoraso,
            ib.agua_fonte,
            ib.agua_pipa,
            ib.agua_chuva,
            ib.agua_rios,
            ib.agua_outro,
            ib.lixo_coletado,
            ib.lixo_depositado,
            ib.lixo_queimado,
            ib.lixo_enterrado,
            ib.lixo_jogado,
            ib.lixo_outrodestino,
            ib.banheiro_um,
            ib.banheiro_dois,
            ib.banheiro_tres,
            ib.banheiro_quatromais,
            ib.banheiro_comum,
            ib.banheiro_buraco,
            ib.banheiro_sem,
            ib.branca,
            ib.preta,
            ib.amarela,
            ib.parda,
            ib.indigena,
            ib.alf_total,
            ib.alf_15_19,
            ib.alf_20_24,
            ib.alf_25_29,
            ib.alf_30_34,
            ib.alf_35_39,
            ib.alf_40_44,
            ib.alf_45_49,
            ib.alf_50_54,
            ib.alf_55_59,
            ib.alf_60_64,
            ib.alf_65_69,
            ib.alf_70_79,
            ib.alf_80mais,
            ib.h_0_a_4,
            ib.h_5_a_9,
            ib.h_10_a_14,
            ib.h_15_a_19,
            ib.h_20_a_24,
            ib.h_25_a_29,
            ib.h_30_a_39,
            ib.h_40_a_49,
            ib.h_50_a_59,
            ib.h_60_a_69,
            ib.h_70_mais,
            ib.m_0_a_4,
            ib.m_5_a_9,
            ib.m_10_a_14,
            ib.m_15_a_19,
            ib.m_20_a_24,
            ib.m_25_a_29,
            ib.m_30_a_39,
            ib.m_40_a_49,
            ib.m_50_a_59,
            ib.m_60_a_69,
            ib.m_70_mais,
            ib.casados_10_a_14,
            ib.casados_15_a_19,
            ib.casados_20_a_24,
            ib.casados_25_a_29,
            ib.casados_30_a_34,
            ib.casados_35_a_39,
            ib.casados_40_a_44,
            ib.casados_45_a_49,
            ib.casados_50_a_54,
            ib.casados_55_a_59,
            ib.casados_60_a_64,
            ib.casados_65_a_69,
            ib.casados_70_a_74,
            ib.casados_75_a_79,
            ib.casados_80_mais,
            ib.mor_total_permanentes,
            ib.mor_total_improvisados,
            ib.mor_total_coletivos,
            ib.dom_total_particulares,
            ib.dom_total_improvisados,
            ib.dom_total_coletivos,
            ib.domicilios_tipo_outros,
            ib.esgoto_rede_geral,
            ib.esgoto_fossa_septica_com_rede,
            ib.esgoto_fossa_septica_sem_rede,
            ib.esgoto_fossa_rudimentar,
            ib.esgoto_vala,
            ib.esgoto_rio,
            ib.esgoto_outra_forma,
            ib.esgoto_inexistente,
            '2022'::text AS ano_censo,
            to_date('2022-01-01'::text, 'YYYY-MM-DD'::text) AS data_censo
           FROM imoveis_filtrados ei
             JOIN dados_ibge_2022 ib ON st_intersects(ei.geom_terreno_buffer, ib.geom)
          WHERE (st_area(st_intersection(ei.geom_terreno_buffer, ib.geom)) / st_area(ib.geom) * 100::double precision) > 25::double precision AND st_isvalid(ei.geom_terreno_buffer) AND st_isvalid(ib.geom)
        )
 SELECT dados_combinados.gid_cliente,
    dados_combinados.cidade,
    dados_combinados.cod_setor,
    dados_combinados.mor_total,
    dados_combinados.dom_total,
    dados_combinados.casas,
    dados_combinados.apartamentos,
    dados_combinados.condominios,
    dados_combinados.mor_1,
    dados_combinados.mor_2,
    dados_combinados.mor_3,
    dados_combinados.mor_4,
    dados_combinados.mor_5,
    dados_combinados.mor_infan,
    dados_combinados.mor_jovem,
    dados_combinados.mor_adult,
    dados_combinados.mor_idoso,
    dados_combinados.mor_homem,
    dados_combinados.mor_mulhe,
    dados_combinados.unipessoal,
    dados_combinados.nuclear,
    dados_combinados.estendida,
    dados_combinados.composta,
    dados_combinados.sexo_diferente,
    dados_combinados.sexo_igual,
    dados_combinados.sexo_diferente_igual,
    dados_combinados.sem_conjuge,
    dados_combinados.dom_res_conjuge_sem_filhos,
    dados_combinados.dom_res_conjuge_filho_ambos,
    dados_combinados.dom_res_conjuge_filho_alguem,
    dados_combinados.dom_res_semconjuge_com_filho,
    dados_combinados.dom_res_outracomposicao,
    dados_combinados.agua_rede,
    dados_combinados.agua_pocoprofundo,
    dados_combinados.agua_pocoraso,
    dados_combinados.agua_fonte,
    dados_combinados.agua_pipa,
    dados_combinados.agua_chuva,
    dados_combinados.agua_rios,
    dados_combinados.agua_outro,
    dados_combinados.lixo_coletado,
    dados_combinados.lixo_depositado,
    dados_combinados.lixo_queimado,
    dados_combinados.lixo_enterrado,
    dados_combinados.lixo_jogado,
    dados_combinados.lixo_outrodestino,
    dados_combinados.banheiro_um,
    dados_combinados.banheiro_dois,
    dados_combinados.banheiro_tres,
    dados_combinados.banheiro_quatromais,
    dados_combinados.banheiro_comum,
    dados_combinados.banheiro_buraco,
    dados_combinados.banheiro_sem,
    dados_combinados.branca,
    dados_combinados.preta,
    dados_combinados.amarela,
    dados_combinados.parda,
    dados_combinados.indigena,
    dados_combinados.alf_total,
    dados_combinados.alf_15_19,
    dados_combinados.alf_20_24,
    dados_combinados.alf_25_29,
    dados_combinados.alf_30_34,
    dados_combinados.alf_35_39,
    dados_combinados.alf_40_44,
    dados_combinados.alf_45_49,
    dados_combinados.alf_50_54,
    dados_combinados.alf_55_59,
    dados_combinados.alf_60_64,
    dados_combinados.alf_65_69,
    dados_combinados.alf_70_79,
    dados_combinados.alf_80mais,
    dados_combinados.h_0_a_4,
    dados_combinados.h_5_a_9,
    dados_combinados.h_10_a_14,
    dados_combinados.h_15_a_19,
    dados_combinados.h_20_a_24,
    dados_combinados.h_25_a_29,
    dados_combinados.h_30_a_39,
    dados_combinados.h_40_a_49,
    dados_combinados.h_50_a_59,
    dados_combinados.h_60_a_69,
    dados_combinados.h_70_mais,
    dados_combinados.m_0_a_4,
    dados_combinados.m_5_a_9,
    dados_combinados.m_10_a_14,
    dados_combinados.m_15_a_19,
    dados_combinados.m_20_a_24,
    dados_combinados.m_25_a_29,
    dados_combinados.m_30_a_39,
    dados_combinados.m_40_a_49,
    dados_combinados.m_50_a_59,
    dados_combinados.m_60_a_69,
    dados_combinados.m_70_mais,
    dados_combinados.casados_10_a_14,
    dados_combinados.casados_15_a_19,
    dados_combinados.casados_20_a_24,
    dados_combinados.casados_25_a_29,
    dados_combinados.casados_30_a_34,
    dados_combinados.casados_35_a_39,
    dados_combinados.casados_40_a_44,
    dados_combinados.casados_45_a_49,
    dados_combinados.casados_50_a_54,
    dados_combinados.casados_55_a_59,
    dados_combinados.casados_60_a_64,
    dados_combinados.casados_65_a_69,
    dados_combinados.casados_70_a_74,
    dados_combinados.casados_75_a_79,
    dados_combinados.casados_80_mais,
    dados_combinados.mor_total_permanentes,
    dados_combinados.mor_total_improvisados,
    dados_combinados.mor_total_coletivos,
    dados_combinados.dom_total_particulares,
    dados_combinados.dom_total_improvisados,
    dados_combinados.dom_total_coletivos,
    dados_combinados.domicilios_tipo_outros,
    dados_combinados.esgoto_rede_geral,
    dados_combinados.esgoto_fossa_septica_com_rede,
    dados_combinados.esgoto_fossa_septica_sem_rede,
    dados_combinados.esgoto_fossa_rudimentar,
    dados_combinados.esgoto_vala,
    dados_combinados.esgoto_rio,
    dados_combinados.esgoto_outra_forma,
    dados_combinados.esgoto_inexistente,
    dados_combinados.ano_censo,
    dados_combinados.data_censo,
    st_distance(dados_combinados.geom_terreno, dados_combinados.geom_atingimento) AS st_distance,
    concat(st_y(st_transform(dados_combinados.centroide_atingimento, 4326)), ', ', st_x(st_transform(dados_combinados.centroide_atingimento, 4326))) AS latlong
   FROM dados_combinados
  WHERE st_isvalid(dados_combinados.geom_atingimento)
WITH DATA;

CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_sociodemografico_raio_cross
TABLESPACE pg_default
AS SELECT viewmat_sociodemografico_raio.gid_cliente,
    viewmat_sociodemografico_raio.latlong,
    viewmat_sociodemografico_raio.ano_censo,
    viewmat_sociodemografico_raio.st_distance,
        CASE
            WHEN viewmat_sociodemografico_raio.mor_homem IS NOT NULL THEN viewmat_sociodemografico_raio.mor_homem
            ELSE NULL::numeric::double precision
        END AS valor,
    'Homens'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico_raio
UNION
 SELECT viewmat_sociodemografico_raio.gid_cliente,
    viewmat_sociodemografico_raio.latlong,
    viewmat_sociodemografico_raio.ano_censo,
    viewmat_sociodemografico_raio.st_distance,
        CASE
            WHEN viewmat_sociodemografico_raio.mor_mulhe IS NOT NULL THEN viewmat_sociodemografico_raio.mor_mulhe
            ELSE NULL::numeric::double precision
        END AS valor,
    'Mulheres'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico_raio
UNION
 SELECT viewmat_sociodemografico_raio.gid_cliente,
    viewmat_sociodemografico_raio.latlong,
    viewmat_sociodemografico_raio.ano_censo,
    viewmat_sociodemografico_raio.st_distance,
        CASE
            WHEN viewmat_sociodemografico_raio.mor_infan IS NOT NULL THEN viewmat_sociodemografico_raio.mor_infan
            ELSE NULL::numeric::double precision
        END AS valor,
    'Infância'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico_raio
UNION
 SELECT viewmat_sociodemografico_raio.gid_cliente,
    viewmat_sociodemografico_raio.latlong,
    viewmat_sociodemografico_raio.ano_censo,
    viewmat_sociodemografico_raio.st_distance,
        CASE
            WHEN viewmat_sociodemografico_raio.mor_jovem IS NOT NULL THEN viewmat_sociodemografico_raio.mor_jovem
            ELSE NULL::numeric::double precision
        END AS valor,
    'Jovens'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico_raio
UNION
 SELECT viewmat_sociodemografico_raio.gid_cliente,
    viewmat_sociodemografico_raio.latlong,
    viewmat_sociodemografico_raio.ano_censo,
    viewmat_sociodemografico_raio.st_distance,
        CASE
            WHEN viewmat_sociodemografico_raio.mor_adult IS NOT NULL THEN viewmat_sociodemografico_raio.mor_adult
            ELSE NULL::numeric::double precision
        END AS valor,
    'Adultos'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico_raio
UNION
 SELECT viewmat_sociodemografico_raio.gid_cliente,
    viewmat_sociodemografico_raio.latlong,
    viewmat_sociodemografico_raio.ano_censo,
    viewmat_sociodemografico_raio.st_distance,
        CASE
            WHEN viewmat_sociodemografico_raio.mor_idoso IS NOT NULL THEN viewmat_sociodemografico_raio.mor_idoso
            ELSE NULL::numeric::double precision
        END AS valor,
    'Idosos'::text AS classe
   FROM geo_{{schema}}.viewmat_sociodemografico_raio
WITH DATA;

CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_equipamentos_urbanos
TABLESPACE pg_default
AS SELECT ee.no_entidade AS nm_classe,
    'Escolas'::text AS classe,
    ee.latlong,
    ee.geom2 AS ponto,
    ef.gid_cliente,
    ef.cidade,
    ef.uf,
    st_distance(ef.ponto::geography, ee.geom2::geography, true) AS st_distance
   FROM ( SELECT DISTINCT ON (aa.no_entidade) aa.no_entidade,
            (af.latitude || ','::text) || af.longitude::text AS latlong,
            st_makepoint(af.longitude::double precision, af.latitude::double precision) AS geom2
           FROM inep.microdados_ed_basica aa
             LEFT JOIN inep.tb_localizacao af ON aa.no_entidade::text = af.no_entidade::text
          WHERE (aa.no_municipio::text ~~* ANY (ARRAY['{{nm_mun}}'::text])) AND aa.sg_uf::text = '{{nm_uf}}'::text) ee,
    ( SELECT DISTINCT ON (imoveis.gid) imoveis.gid AS gid_cliente,
            st_centroid(imoveis.geom) AS ponto,
            imoveis.cidade,
            imoveis.uf
           FROM esteira.imoveis) ef
  WHERE st_dwithin(ef.ponto::geography, ee.geom2::geography, {{st_distance}}::double precision, true) AND ef.cidade::text = '{{nm_mun}}'::text AND ef.uf::text = '{{nm_uf}}'::text
UNION ALL
 SELECT ee.no_fantasia AS nm_classe,
    'Saúde'::text AS classe,
    ee.latlong,
    ee.geom2 AS ponto,
    ef.gid_cliente,
    ef.cidade,
    ef.uf,
    st_distance(ef.ponto::geography, ee.geom2::geography, true) AS st_distance
   FROM ( SELECT DISTINCT ON (aa.co_cnes) initcap(aa.no_fantasia) AS no_fantasia,
            (aa.nu_latitude::text || ','::text) || aa.nu_longitude::text AS latlong,
            st_makepoint(NULLIF(aa.nu_longitude::text, ''::text)::numeric::double precision, NULLIF(aa.nu_latitude::text, ''::text)::numeric::double precision) AS geom2
           FROM cnes.cnes_estabelecimentos aa
             LEFT JOIN cnes.dic_co_ibge ab ON aa.co_ibge::text = ab.atributo::text
             LEFT JOIN cnes.dic_co_uf ac ON aa.co_uf::text = ac.atributo::text
          WHERE (ab.descricao::text ~~* ANY (ARRAY['{{nm_mun}}'::text])) AND ac.descricao::text = '{{nm_uf_extenso}}'::text) ee,
    ( SELECT DISTINCT ON (imoveis.gid) imoveis.gid AS gid_cliente,
            st_centroid(imoveis.geom) AS ponto,
            imoveis.cidade,
            imoveis.uf
           FROM esteira.imoveis) ef
  WHERE st_dwithin(ef.ponto::geography, ee.geom2::geography, {{st_distance}}::double precision, true) AND ef.cidade::text = '{{nm_mun}}'::text AND ef.uf::text = '{{nm_uf}}'::text
WITH DATA;
-- TIRAR WITH DATA SE DER ERRO

CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_indice_variacao_renda
TABLESPACE pg_default
AS WITH base AS (
         SELECT r.gid,
            r.nm_bairro,
            r.nm_mun,
            r.nm_uf,
            r.cd_setor,
            r.dom_total_par_pes_resp,
            r.mor_total_dom_par,
            r.mor_total_dom_par_variancia,
            r.renda_media_pes_resp,
            r.renda_media_pes_resp_variancia,
            r.geom,
            sqrt(r.renda_media_pes_resp_variancia) AS desvio_padrao_renda,
                CASE
                    WHEN r.renda_media_pes_resp > 0::numeric AND r.renda_media_pes_resp_variancia >= 0::numeric THEN sqrt(r.renda_media_pes_resp_variancia) / r.renda_media_pes_resp * 100::numeric
                    ELSE NULL::numeric
                END AS coeficiente_variacao_renda
           FROM ibge22.view_ren22 r
          WHERE r.renda_media_pes_resp IS NOT NULL AND r.renda_media_pes_resp_variancia IS NOT NULL AND r.nm_mun::text = '{{nm_mun}}'::text
        ), percentis AS (
         SELECT percentile_cont(0.33::double precision) WITHIN GROUP (ORDER BY (base.coeficiente_variacao_renda::double precision)) AS p33,
            percentile_cont(0.66::double precision) WITHIN GROUP (ORDER BY (base.coeficiente_variacao_renda::double precision)) AS p66
           FROM base
        ), renda_categorizada AS (
         SELECT b.gid,
            b.nm_bairro,
            b.nm_mun,
            b.nm_uf,
            b.cd_setor,
            b.dom_total_par_pes_resp,
            b.mor_total_dom_par,
            b.mor_total_dom_par_variancia,
            b.renda_media_pes_resp,
            b.renda_media_pes_resp_variancia,
            b.desvio_padrao_renda,
            b.coeficiente_variacao_renda,
                CASE
                    WHEN b.coeficiente_variacao_renda::double precision <= p.p33 THEN 1
                    WHEN b.coeficiente_variacao_renda::double precision <= p.p66 THEN 2
                    ELSE 3
                END AS score_variacao_renda,
                CASE
                    WHEN b.coeficiente_variacao_renda::double precision <= p.p33 THEN 'Baixa Variação de Renda'::text
                    WHEN b.coeficiente_variacao_renda::double precision <= p.p66 THEN 'Média Variação de Renda'::text
                    ELSE 'Alta Variação de Renda'::text
                END AS interpretacao_variacao_renda,
            b.geom,
            (st_y(st_centroid(b.geom)) || ','::text) || st_x(st_centroid(b.geom)) AS latlong
           FROM base b,
            percentis p
        ), imoveis_filtrados AS (
         SELECT DISTINCT ON (imoveis.gid) imoveis.gid AS gid_cliente,
            imoveis.cidade,
            imoveis.uf,
            st_centroid(imoveis.geom) AS ponto_imovel,
            (st_y(st_centroid(imoveis.geom)) || ','::text) || st_x(st_centroid(imoveis.geom)) AS latlonglote
           FROM esteira.imoveis
          WHERE imoveis.cidade::text = '{{nm_mun}}'::text AND imoveis.uf::text = '{{nm_uf}}'::text
        )
 SELECT im.gid_cliente,
    im.cidade,
    im.uf,
    im.latlonglote,
    rc.nm_bairro,
    rc.nm_mun,
    rc.nm_uf,
    rc.cd_setor,
    rc.dom_total_par_pes_resp,
    rc.mor_total_dom_par,
    rc.mor_total_dom_par_variancia,
    rc.renda_media_pes_resp,
    rc.desvio_padrao_renda,
    rc.coeficiente_variacao_renda,
    rc.score_variacao_renda,
    rc.interpretacao_variacao_renda,
    rc.latlong,
    st_distance(im.ponto_imovel::geography, rc.geom::geography, true) AS st_distance
   FROM imoveis_filtrados im
     JOIN renda_categorizada rc ON st_dwithin(im.ponto_imovel::geography, rc.geom::geography, {{st_distance}}::double precision, true)
  WHERE im.cidade::text = '{{nm_mun}}'::text AND im.uf::text = '{{nm_uf}}'::text
WITH DATA;
-- TIRAR WITH DATA SE DER ERRO

CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_imoveis_bi_logradouro_lake
TABLESPACE pg_default
AS SELECT row_number() OVER (PARTITION BY lote.gid ORDER BY anuncio.id_fonte, logr_candidato.logradouro_rank) AS mv_row_id,
    lote.gid AS id_lote_relacionado,
    lote.gid AS gid_cliente,
    logr_candidato.nm_logr AS nome_logradouro_captura,
    logr_candidato.logradouro_rank,
    logr_candidato.dist_lote_logradouro_m,
    anuncio.date_part,
    anuncio.titulo,
    anuncio.descricao,
    anuncio.area,
    anuncio.data_anuncio,
    anuncio.id_fonte,
    anuncio.num_andares,
    anuncio.num_vagas_garagem,
    anuncio.num_suites,
    anuncio.num_banheiros,
    anuncio.num_quartos,
    anuncio.valor,
    anuncio.iptu,
    anuncio.taxa_condominial,
    anuncio.contato,
    anuncio.link_anuncio,
    anuncio.fonte,
    anuncio.tipo_imovel,
    anuncio.tipo_negocio,
    anuncio.tipo_uso,
    anuncio.estado_construcao,
    anuncio.imovel_lancamento,
    anuncio.bl_temporada,
    anuncio.data_raspagem,
    anuncio.hash,
    anuncio.bl_ativo,
    anuncio.estado_sigla,
    anuncio.cidade,
    anuncio.bairro_tratado,
    anuncio.cep,
    anuncio.complemento,
    anuncio.logradouro,
    anuncio.numero,
    anuncio.precisao,
    anuncio.ponto,
    anuncio.lat,
    anuncio.lon,
    anuncio.data_tabela,
    anuncio.is_outlier,
    (st_y(anuncio.ponto) || ','::text) || st_x(anuncio.ponto) AS latlong_anuncio,
    st_distance(st_transform(anuncio.ponto, {{src}}), logr_candidato.geom_{{src}}) AS distancia_anuncio_logradouro_m
   FROM esteira.imoveis lote
     CROSS JOIN LATERAL ( SELECT cad.nm_logr,
            cad.geom AS geom_{{src}},
            st_distance(st_centroid(st_transform(lote.geom, {{src}})), cad.geom) AS dist_lote_logradouro_m,
            row_number() OVER (ORDER BY (st_distance(st_centroid(st_transform(lote.geom, {{src}})), cad.geom))) AS logradouro_rank
           FROM geo_{{schema}}.cad_logr cad
          WHERE st_dwithin(st_centroid(st_transform(lote.geom, {{src}})), cad.geom, 500::double precision)
          ORDER BY (st_distance(st_centroid(st_transform(lote.geom, {{src}})), cad.geom))
         LIMIT 5) logr_candidato
     JOIN geo_{{schema}}.viewmat_imoveis_bi anuncio ON st_dwithin(st_transform(anuncio.ponto, {{src}}), logr_candidato.geom_{{src}}, 75::double precision)
  WHERE (anuncio.tipo_negocio::text = ANY (ARRAY['Venda'::character varying::text, 'Aluguel'::character varying::text])) AND anuncio.bl_ativo IS TRUE AND (anuncio.precisao = ANY (ARRAY[3, 4]))
WITH DATA;

CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_imoveis_bi_shortstay_logradouro
TABLESPACE pg_default
AS SELECT row_number() OVER (PARTITION BY lote.gid ORDER BY anuncio.gid, logr_candidato.logradouro_rank) AS mv_row_id,
    lote.gid AS id_lote_relacionado,
    lote.gid AS gid_cliente,
    logr_candidato.nm_logr,
    anuncio.gid,
    anuncio.airbnb_property_id,
    anuncio.vrbo_property_id,
    anuncio.listing_type,
    anuncio.bedrooms,
    anuncio.bathrooms,
    anuncio.accommodates,
    anuncio.rating,
    anuncio.reviews,
    anuncio.title,
    anuncio.revenue_ltm,
    anuncio.revenue_potential_ltm,
    anuncio.occupancy_rate_ltm,
    anuncio.average_daily_rate_ltm,
    anuncio.days_available_ltm,
    anuncio.lat,
    anuncio.lon,
    anuncio.data_raspagem,
    anuncio.ativo,
    (st_y(st_transform(st_setsrid(st_makepoint(anuncio.lon::double precision, anuncio.lat::double precision), 4326), 4326)) || ','::text) || st_x(st_transform(st_setsrid(st_makepoint(anuncio.lon::double precision, anuncio.lat::double precision), 4326), 4326)) AS latlon
   FROM esteira.imoveis lote
     CROSS JOIN LATERAL ( SELECT cad.nm_logr,
            st_transform(cad.geom, {{src}}) AS geom_{{src}},
            st_distance(st_centroid(st_transform(lote.geom, {{src}})), st_transform(cad.geom, {{src}})) AS dist_lote_logradouro_m,
            row_number() OVER (ORDER BY (st_distance(st_centroid(st_transform(lote.geom, {{src}})), st_transform(cad.geom, {{src}})))) AS logradouro_rank
           FROM geo_{{schema}}.cad_logr cad
          WHERE st_dwithin(st_centroid(st_transform(lote.geom, {{src}})), st_transform(cad.geom, {{src}}), 500::double precision)
          ORDER BY (row_number() OVER (ORDER BY (st_distance(st_centroid(st_transform(lote.geom, {{src}})), st_transform(cad.geom, {{src}})))))
         LIMIT 5) logr_candidato
     JOIN airbnb.airdna_geral anuncio ON st_dwithin(st_transform(st_setsrid(st_makepoint(anuncio.lon::double precision, anuncio.lat::double precision), 4326), {{src}}), logr_candidato.geom_{{src}}, 75::double precision)
WITH DATA;

CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_imoveis_bi_shortstay_bairro
TABLESPACE pg_default
AS SELECT a.gid,
    a.airbnb_property_id,
    a.vrbo_property_id,
    a.listing_type,
    a.bedrooms,
    a.bathrooms,
    a.accommodates,
    a.rating,
    a.reviews,
    a.title,
    a.revenue_ltm,
    a.revenue_potential_ltm,
    a.occupancy_rate_ltm,
    a.average_daily_rate_ltm,
    a.days_available_ltm,
    a.lat,
    a.lon,
    a.data_raspagem,
    a.ativo,
    concat(a.lat, ',', a.lon) AS latlon,
    st_transform(st_setsrid(st_makepoint(a.lon::numeric::double precision, a.lat::numeric::double precision), 4326), {{src}}) AS geom_airbnb,
    ef.gid_cliente,
    ef.cidade,
    ef.uf,
    b.nm_bairro
   FROM ( SELECT airdna_geral.gid,
            airdna_geral.airbnb_property_id,
            airdna_geral.vrbo_property_id,
            airdna_geral.listing_type,
            airdna_geral.bedrooms,
            airdna_geral.bathrooms,
            airdna_geral.accommodates,
            airdna_geral.rating,
            airdna_geral.reviews,
            airdna_geral.title,
            airdna_geral.revenue_ltm,
            airdna_geral.revenue_potential_ltm,
            airdna_geral.occupancy_rate_ltm,
            airdna_geral.average_daily_rate_ltm,
            airdna_geral.days_available_ltm,
            airdna_geral.lat,
            airdna_geral.lon,
            airdna_geral.data_raspagem,
            airdna_geral.ativo
           FROM airbnb.airdna_geral) a
     JOIN ( SELECT DISTINCT ON (imoveis.gid) imoveis.gid AS gid_cliente,
            imoveis.cidade,
            imoveis.uf,
            st_centroid(imoveis.geom) AS ponto_imovel,
            (st_y(st_centroid(st_transform(imoveis.geom, 4326))) || ','::text) || st_x(st_centroid(st_transform(imoveis.geom, 4326))) AS latlonglote
           FROM esteira.imoveis) ef ON (ef.cidade::text = ANY (ARRAY['{{nm_mun}}'::text])) AND ef.uf::text = '{{nm_uf}}'::text
     JOIN geo_{{schema}}.cad_bairro b ON st_contains(b.geom, st_transform(ef.ponto_imovel, {{src}}))
  WHERE st_contains(b.geom, st_transform(st_setsrid(st_makepoint(a.lon::numeric::double precision, a.lat::numeric::double precision), 4326), {{src}}))
WITH DATA;

CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_imoveis_bi_logradouro_lancamentos
TABLESPACE pg_default
AS SELECT row_number() OVER (PARTITION BY lote.gid ORDER BY anuncio.id_fonte, logr_candidato.logradouro_rank) AS mv_row_id,
    lote.gid AS id_lote_relacionado,
    lote.gid AS gid_cliente,
    logr_candidato.nm_logr AS nome_logradouro_captura,
    logr_candidato.logradouro_rank,
    logr_candidato.dist_lote_logradouro_m,
    anuncio.titulo,
    anuncio.area,
    anuncio.id_fonte,
    anuncio.num_suites,
    anuncio.num_banheiros,
    anuncio.num_quartos,
    anuncio.valor,
    anuncio.link_anuncio,
    anuncio.tipo_imovel,
    anuncio.tipo_negocio,
    anuncio.tipo_uso,
    anuncio.num_andares,
    anuncio.data_raspagem,
    anuncio.ponto,
    anuncio.bairro_tratado,
    anuncio.lat,
    anuncio.lon,
    anuncio.data_tabela,
    anuncio.is_outlier,
    anuncio.controle1,
    anuncio.controle2,
    anuncio.incorporadora,
    anuncio.empreendimento,
    anuncio.data_lancamento,
    anuncio.status,
    (st_y(st_transform(anuncio.ponto, 4326)) || ','::text) || st_x(st_transform(anuncio.ponto, 4326)) AS latlong,
    st_distance(st_transform(anuncio.ponto, {{src}}), logr_candidato.geom_{{src}}) AS distancia_anuncio_logradouro_m
   FROM esteira.imoveis lote
     CROSS JOIN LATERAL ( SELECT cad.nm_logr,
            st_transform(cad.geom, {{src}}) AS geom_{{src}},
            st_distance(st_centroid(st_transform(lote.geom, {{src}})), st_transform(cad.geom, {{src}})) AS dist_lote_logradouro_m,
            row_number() OVER (ORDER BY (st_distance(st_centroid(st_transform(lote.geom, {{src}})), st_transform(cad.geom, {{src}})))) AS logradouro_rank
           FROM geo_{{schema}}.cad_logr cad
          WHERE st_dwithin(st_centroid(st_transform(lote.geom, {{src}})), st_transform(cad.geom, {{src}}), 500::double precision)
          ORDER BY (row_number() OVER (ORDER BY (st_distance(st_centroid(st_transform(lote.geom, {{src}})), st_transform(cad.geom, {{src}})))))
         LIMIT 5) logr_candidato
     JOIN observatorio.lancamentos anuncio ON st_dwithin(st_transform(anuncio.ponto, {{src}}), logr_candidato.geom_{{src}}, 75::double precision)
  WHERE (anuncio.tipo_negocio::text = ANY (ARRAY['Venda'::text])) AND anuncio.bl_ativo IS TRUE AND (anuncio.precisao = ANY (ARRAY[3, 4])) AND anuncio.cidade::text = '{{nm_mun}}'::text
WITH DATA;

CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_imoveis_bi_bairro_lancamentos
TABLESPACE pg_default
AS SELECT im.titulo,
    im.descricao,
    im.area,
    im.data_anuncio,
    im.id_fonte,
    im.num_andares,
    im.num_vagas_garagem,
    im.num_suites,
    im.num_banheiros,
    im.num_quartos,
    im.valor,
    im.iptu,
    im.taxa_condominial,
    im.contato,
    im.link_anuncio,
    im.fonte,
    im.tipo_imovel,
    im.tipo_negocio,
    im.tipo_uso,
    im.estado_construcao,
    im.imovel_lancamento,
    im.bl_temporada,
    im.data_raspagem,
    im.hash,
    im.bl_ativo,
    im.estado_sigla,
    im.cidade,
    im.bairro_tratado,
    im.cep,
    im.complemento,
    im.logradouro,
    im.numero,
    im.precisao,
    im.ponto,
    im.lat,
    im.lon,
    im.data_tabela,
    im.is_outlier,
    im.latlong,
    im.controle1,
    im.controle2,
    im.incorporadora,
    im.empreendimento,
    im.data_lancamento,
    im.status,
    im.estoque,
    ef.latlonglote,
    ef.ponto_imovel,
    ef.gid_cliente,
    b.nm_bairro
   FROM ( SELECT DISTINCT ON ((((((lancamentos.bairro_tratado::text || ''::text) || lancamentos.logradouro::text) || ''::text) || lancamentos.numero::text) || lancamentos.titulo::text)) lancamentos.id,
            lancamentos.titulo,
            lancamentos.descricao,
            lancamentos.area,
            lancamentos.data_anuncio,
            lancamentos.id_fonte,
            lancamentos.num_andares,
            lancamentos.num_vagas_garagem,
            lancamentos.num_suites,
            lancamentos.num_banheiros,
            lancamentos.num_quartos,
            lancamentos.valor,
            lancamentos.iptu,
            lancamentos.taxa_condominial,
            lancamentos.contato,
            lancamentos.link_anuncio,
            lancamentos.fonte,
            lancamentos.tipo_imovel,
            lancamentos.tipo_negocio,
            lancamentos.tipo_uso,
            lancamentos.estado_construcao,
            lancamentos.imovel_lancamento,
            lancamentos.bl_temporada,
            lancamentos.data_raspagem,
            lancamentos.hash,
            lancamentos.bl_ativo,
            lancamentos.estado_sigla,
            lancamentos.cidade,
            lancamentos.bairro_tratado,
            lancamentos.cep,
            lancamentos.complemento,
            lancamentos.logradouro,
            lancamentos.numero,
            lancamentos.precisao,
            lancamentos.ponto,
            lancamentos.lat,
            lancamentos.lon,
            lancamentos.data_tabela,
            lancamentos.is_outlier,
            (lancamentos.lat::text || ','::text) || lancamentos.lon::text AS latlong,
            lancamentos.controle1,
            lancamentos.controle2,
            lancamentos.incorporadora,
            lancamentos.empreendimento,
            lancamentos.data_lancamento,
            lancamentos.status,
            lancamentos.estoque
           FROM observatorio.lancamentos
          WHERE lancamentos.tipo_negocio::text = ANY (ARRAY['Venda'::text, 'Aluguel'::text])) im
     JOIN geo_{{schema}}.cad_bairro b ON st_contains(b.geom, st_transform(im.ponto, {{src}}))
     JOIN ( SELECT DISTINCT ON (imoveis.gid) imoveis.gid AS gid_cliente,
            imoveis.cidade,
            imoveis.uf,
            st_centroid(imoveis.geom) AS ponto_imovel,
            (st_y(st_centroid(st_transform(imoveis.geom, 4326))) || ','::text) || st_x(st_centroid(st_transform(imoveis.geom, 4326))) AS latlonglote
           FROM esteira.imoveis
          WHERE (imoveis.cidade::text = ANY (ARRAY['{{nm_mun}}'::text])) AND imoveis.uf::text = '{{nm_uf}}'::text) ef ON st_contains(b.geom, st_transform(ef.ponto_imovel, {{src}}))
WITH DATA;

CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.monit_estatistica_media_trimestre_raio
TABLESPACE pg_default
AS WITH base_data AS (
         SELECT NULLIF(m.valor, 0::double precision) / NULLIF(m.area, 0::double precision) AS vl_m2,
            m.estado_sigla,
            m.cidade,
            m.bairro_tratado,
                CASE
                    WHEN m.tipo_imovel::text = ANY (ARRAY['Apartamento'::text, 'Flat'::text]) THEN 'Apartamento'::character varying
                    WHEN m.tipo_imovel::text = ANY (ARRAY['Casa'::text, 'Sobrado'::text, 'Casa de Condomínio'::text]) THEN 'Casa'::character varying
                    WHEN m.tipo_imovel::text = ANY (ARRAY['Sala/Conjunto'::text, 'Consultório'::text, 'Ponto Comercial/Loja/Box'::text]) THEN 'Sala/Loja'::character varying
                    WHEN m.tipo_imovel::text = 'Lote/Terreno'::text THEN 'Lote'::character varying
                    WHEN m.tipo_imovel::text = ANY (ARRAY['Chácara'::text, 'Fazenda/Sítios/Chácaras'::text]) THEN 'Fazenda/Sítios/Chácaras'::character varying
                    ELSE m.tipo_imovel
                END AS tipo_imovel,
            m.tipo_negocio,
            m.num_quartos,
            m.ponto,
            m.data_tabela
           FROM observatorio.monit_geral m
          WHERE m.bl_ativo IS TRUE AND m.ponto IS NOT NULL AND m.cidade::text = '{{nm_mun}}'::text AND m.estado_sigla::text = '{{nm_uf}}'::text AND m.data_tabela >= '2024-01-01'::date AND m.data_tabela <= '2027-09-30'::date AND (m.tipo_imovel::text = ANY (ARRAY['Apartamento'::text, 'Flat'::text, 'Casa'::text, 'Sobrado'::text, 'Casa de Condomínio'::text, 'Sala/Conjunto'::text, 'Consultório'::text, 'Ponto Comercial/Loja/Box'::text, 'Lote/Terreno'::text, 'Chácara'::text, 'Fazenda/Sítios/Chácaras'::text]))
        ), quartiles_corrected AS (
         SELECT base_data.cidade,
            base_data.bairro_tratado,
            base_data.num_quartos,
            base_data.tipo_negocio,
            base_data.tipo_imovel,
            base_data.vl_m2,
            base_data.data_tabela,
            ntile(4) OVER (PARTITION BY base_data.cidade, base_data.bairro_tratado, base_data.tipo_negocio, base_data.tipo_imovel, base_data.num_quartos, base_data.data_tabela ORDER BY base_data.vl_m2) AS vl_m2_quartile,
            count(*) OVER (PARTITION BY base_data.cidade, base_data.bairro_tratado, base_data.tipo_negocio, base_data.tipo_imovel, base_data.num_quartos, base_data.data_tabela) AS partition_count
           FROM base_data
        ), quartile_values AS (
         SELECT quartiles_corrected.cidade,
            quartiles_corrected.bairro_tratado,
            quartiles_corrected.num_quartos,
            quartiles_corrected.tipo_negocio,
            quartiles_corrected.tipo_imovel,
            quartiles_corrected.data_tabela,
            min(
                CASE
                    WHEN quartiles_corrected.vl_m2_quartile = 1 THEN quartiles_corrected.vl_m2
                    ELSE NULL::double precision
                END) AS q1,
            max(
                CASE
                    WHEN quartiles_corrected.vl_m2_quartile = 3 THEN quartiles_corrected.vl_m2
                    ELSE NULL::double precision
                END) AS q3
           FROM quartiles_corrected
          WHERE quartiles_corrected.partition_count >= 7
          GROUP BY quartiles_corrected.cidade, quartiles_corrected.bairro_tratado, quartiles_corrected.num_quartos, quartiles_corrected.tipo_negocio, quartiles_corrected.tipo_imovel, quartiles_corrected.data_tabela
        ), iqr_limits_corrected AS (
         SELECT qv.cidade,
            qv.bairro_tratado,
            qv.num_quartos,
            qv.tipo_negocio,
            qv.tipo_imovel,
            qv.data_tabela,
            qv.q3 - qv.q1 AS iqr,
            qv.q1 - 1.5::double precision * (qv.q3 - qv.q1) AS iq1_limites_minimos,
            qv.q3 + 1.5::double precision * (qv.q3 - qv.q1) AS iq3_limites_maximos
           FROM quartile_values qv
        ), filtered_data AS (
         SELECT bd.vl_m2,
            bd.estado_sigla,
            bd.cidade,
            bd.bairro_tratado,
            bd.tipo_imovel,
            bd.tipo_negocio,
            bd.num_quartos,
            bd.data_tabela,
            bd.ponto
           FROM base_data bd
             JOIN iqr_limits_corrected il ON bd.cidade::text = il.cidade::text AND bd.bairro_tratado::text = il.bairro_tratado::text AND bd.tipo_imovel::text = il.tipo_imovel::text AND bd.tipo_negocio::text = il.tipo_negocio::text AND bd.num_quartos = il.num_quartos AND bd.data_tabela = il.data_tabela
          WHERE bd.vl_m2 > il.iq1_limites_minimos AND bd.vl_m2 < il.iq3_limites_maximos
        ), related_data AS (
         SELECT imoveis.gid AS gid_cliente,
            imoveis.cidade AS imoveis_cidade,
            imoveis.uf,
            filtered_data.vl_m2,
            filtered_data.estado_sigla,
            filtered_data.cidade,
            filtered_data.bairro_tratado,
            filtered_data.tipo_imovel,
            filtered_data.tipo_negocio,
            filtered_data.num_quartos,
            filtered_data.data_tabela,
            filtered_data.ponto
           FROM esteira.imoveis imoveis
             JOIN filtered_data ON st_dwithin(filtered_data.ponto::geography, st_centroid(st_transform(imoveis.geom, 4326))::geography, 1000::double precision, true)
          WHERE imoveis.cidade::text = '{{nm_mun}}'::text AND imoveis.uf::text = '{{nm_uf}}'::text AND imoveis.gid > 5000
        )
 SELECT 
    row_number() OVER () AS row_id,
    related_data.gid_cliente,
    related_data.imoveis_cidade AS cidade,
    related_data.uf,
    related_data.estado_sigla,
    related_data.bairro_tratado,
    related_data.tipo_imovel,
    related_data.tipo_negocio,
    related_data.num_quartos,
    related_data.data_tabela,
    round(avg(related_data.vl_m2)::numeric, 2) AS vm2
   FROM related_data
  GROUP BY related_data.gid_cliente, related_data.imoveis_cidade, related_data.uf, related_data.estado_sigla, related_data.bairro_tratado, related_data.tipo_imovel, related_data.tipo_negocio, related_data.num_quartos, related_data.data_tabela
WITH DATA;

CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_cno_logradouro
TABLESPACE pg_default
AS SELECT row_number() OVER (PARTITION BY lote.gid ORDER BY cno_data.id, logr_candidato.logradouro_rank) AS mv_row_id,
    lote.gid AS id_lote_relacionado,
    lote.gid AS gid_cliente,
    logr_candidato.nm_logr,
    cno_data.id,
    cno_data.cno,
    cno_data.cnae,
    cno_data.cno_cnae_descricao,
    cno_data.destinacao,
    cno_data.categoria,
    cno_data.tipo_area,
    cno_data.area_total,
    cno_data.situacao,
    cno_data.situacao_descricao,
    cno_data.data_inicio,
    cno_data.data_situacao,
    cno_data.nome_empresarial,
    cno_data.endereco_consulta,
    cno_data.data_registro,
    cno_data.latitude,
    cno_data.longitude,
    cno_data.latlong,
    cno_data.geom2,
    cno_data.precisao_geocoding,
    cno_data.endereco_formatado,
    cno_data.ni_responsavel_vinculo,
    cno_data.cd_pais,
    cno_data.nm_pais,
    cno_data.data_inicio_responsabilidade,
    cno_data.cno_vinculado,
    cno_data.cep,
    cno_data.ni_responsavel,
    cno_data.qualificacao_responsavel,
    cno_data.qualificacao_responsavel_descricao,
    cno_data.cd_mun,
    cno_data.nm_mun,
    cno_data.tp_logr,
    cno_data.nm_logr AS cno_nm_logr,
    cno_data.cd_logr,
    cno_data.nm_bairro,
    cno_data.nm_estado,
    cno_data.caixa_postal,
    cno_data.complemento,
    cno_data.unidade_medida,
    cno_data.nome,
    cno_data.codigo_localizacao,
    cno_data.metragem,
    cno_data.tipo_area_complementar,
    cno_data.data_registro_cnae,
    cno_data.data_inicio_vinculo,
    cno_data.data_fim_vinculo,
    cno_data.data_registro_vinculo,
    cno_data.qualificacao_contribuinte,
    cno_data.qualificacao_contribuinte_descricao
   FROM esteira.imoveis lote
     CROSS JOIN LATERAL ( SELECT cad.nm_logr,
            st_transform(cad.geom, {{src}}) AS geom_{{src}},
            st_distance(st_centroid(st_transform(lote.geom, {{src}})), st_transform(cad.geom, {{src}})) AS dist_lote_logradouro_m,
            row_number() OVER (ORDER BY (st_distance(st_centroid(st_transform(lote.geom, {{src}})), st_transform(cad.geom, {{src}})))) AS logradouro_rank
           FROM geo_{{schema}}.cad_logr cad
          WHERE st_dwithin(st_centroid(st_transform(lote.geom, {{src}})), st_transform(cad.geom, {{src}}), 500::double precision)
          ORDER BY (row_number() OVER (ORDER BY (st_distance(st_centroid(st_transform(lote.geom, {{src}})), st_transform(cad.geom, {{src}})))))
         LIMIT 5) logr_candidato
     JOIN ( SELECT DISTINCT ON (aa.cno) lpad(row_number() OVER ()::text, 6, '0'::text)::numeric AS id,
            aa.cno::numeric(12,0) AS cno,
            ac.cnae::numeric(7,0) AS cnae,
            ah.descricao AS cno_cnae_descricao,
            ab."Destinação" AS destinacao,
            ab.categoria,
            ab."Tipo de Área" AS tipo_area,
            aa."Área total"::numeric(11,2) AS area_total,
            aa."situação"::numeric(2,0) AS situacao,
            ae.descricao AS situacao_descricao,
            to_date(aa."Data de início"::text, 'YYYY-MM-DD'::text) AS data_inicio,
            to_date(aa."Data da situação"::text, 'YYYY-MM-DD'::text) AS data_situacao,
            aa."Nome empresarial" AS nome_empresarial,
            (((((((((((aa."Tipo de logradouro"::text || ' '::text) || aa.logradouro::text) || ', '::text) || aa."Número do logradouro"::text) || ' - '::text) || aa.bairro::text) || ', '::text) || aa."Nome do município"::text) || ' - '::text) || aa.estado::text) || ', '::text) || aa.cep::text AS endereco_consulta,
            to_date(aa."Data de registro"::text, 'YYYY-MM-DD'::text) AS data_registro,
            ai.latitude,
            ai.longitude,
            (ai.latitude || ','::text) || ai.longitude AS latlong,
            st_setsrid(st_makepoint(ai.longitude::double precision, ai.latitude::double precision), 4326) AS geom2,
            ai.precisao_geocoding,
            ai.endereco_formatado,
            ad."NI do responsável" AS ni_responsavel_vinculo,
            aa."Código do Pais"::text AS cd_pais,
            aa."Nome do pais" AS nm_pais,
            to_date(aa."Data de inicio da responsabilidade"::text, 'YYYY-MM-DD'::text) AS data_inicio_responsabilidade,
            aa."CNO vinculado" AS cno_vinculado,
            aa.cep,
            aa."NI do responsável" AS ni_responsavel,
            aa."Qualificação do responsavel"::numeric(4,0) AS qualificacao_responsavel,
            ag.descricao AS qualificacao_responsavel_descricao,
            aa."Código do municipio"::numeric(4,0) AS cd_mun,
            aa."Nome do município" AS nm_mun,
            aa."Tipo de logradouro" AS tp_logr,
            aa.logradouro AS nm_logr,
            aa."Número do logradouro" AS cd_logr,
            aa.bairro AS nm_bairro,
            aa.estado AS nm_estado,
            aa."Caixa Postal" AS caixa_postal,
            aa.complemento,
            aa."Unidade de medida" AS unidade_medida,
            aa.nome,
            aa."Código de localização" AS codigo_localizacao,
            ab.metragem::numeric(22,0) AS metragem,
            ab."Tipo de Área Complementar" AS tipo_area_complementar,
            to_date(ac."Data de registro"::text, 'YYYY-MM-DD'::text) AS data_registro_cnae,
            to_date(ad."Data de início"::text, 'YYYY-MM-DD'::text) AS data_inicio_vinculo,
            to_date(ad."Data de fim"::text, 'YYYY-MM-DD'::text) AS data_fim_vinculo,
            to_date(ad."Data de registro"::text, 'YYYY-MM-DD'::text) AS data_registro_vinculo,
            ad."Qualificação do contribuinte"::numeric(4,0) AS qualificacao_contribuinte,
            af.descricao AS qualificacao_contribuinte_descricao
           FROM cno.cno aa
             LEFT JOIN cno.cno_areas ab ON aa.cno::text = ab.cno::text
             LEFT JOIN cno.cno_cnaes ac ON ab.cno::text = ac.cno::text
             LEFT JOIN cno.cno_vinculos ad ON ac.cno::text = ad.cno::text
             LEFT JOIN cno.dic_cno_situacao ae ON aa."situação"::numeric = ae.atributo
             LEFT JOIN cno.dic_cno_qualificacao_contribuinte af ON ad."Qualificação do contribuinte"::text = af.atributo
             LEFT JOIN cno.dic_cno_qualificacao_responsavel ag ON aa."Qualificação do responsavel"::text = ag.atributo
             LEFT JOIN cno.dic_cno_cnaes ah ON ac.cnae::text = ah.atributo::text
             LEFT JOIN cno.tb_localizacao ai ON aa.cno::text = ai.cno::text
          WHERE (aa."Nome do município"::text = ANY (ARRAY['{{nm_mun_maiusculocomacento}}'::text])) AND ai.ativo = true) cno_data ON st_dwithin(st_transform(cno_data.geom2, {{src}}), logr_candidato.geom_{{src}}, 75::double precision)
WITH DATA;


CREATE MATERIALIZED VIEW IF NOT EXISTS geo_{{schema}}.viewmat_cno_bairro
TABLESPACE pg_default
AS SELECT ee.id,
    ee.cno,
    ee.cnae,
    ee.cno_cnae_descricao,
    ee.destinacao,
    ee.categoria,
    ee.tipo_area,
    ee.area_total,
    ee.situacao,
    ee.situacao_descricao,
    ee.data_inicio,
    ee.data_situacao,
    ee.nome_empresarial,
    ee.endereco_consulta,
    ee.data_registro,
    ee.latitude,
    ee.longitude,
    ee.latlong,
    ee.geom2,
    ee.precisao_geocoding,
    ee.endereco_formatado,
    ee.ni_responsavel_vinculo,
    ee.cd_pais,
    ee.nm_pais,
    ee.data_inicio_responsabilidade,
    ee.cno_vinculado,
    ee.cep,
    ee.ni_responsavel,
    ee.qualificacao_responsavel,
    ee.qualificacao_responsavel_descricao,
    ee.cd_mun,
    ee.nm_mun,
    ee.tp_logr,
    ee.nm_logr,
    ee.cd_logr,
    ee.nm_bairro,
    ee.nm_estado,
    ee.caixa_postal,
    ee.complemento,
    ee.unidade_medida,
    ee.nome,
    ee.codigo_localizacao,
    ee.metragem,
    ee.tipo_area_complementar,
    ee.data_registro_cnae,
    ee.data_inicio_vinculo,
    ee.data_fim_vinculo,
    ee.data_registro_vinculo,
    ee.qualificacao_contribuinte,
    ee.qualificacao_contribuinte_descricao,
    ef.gid_cliente,
    ef.ponto_4326,
    ef.cidade,
    ef.uf,
    ef.latlonglote,
    st_distance(ef.ponto_4326::geography, ee.geom2::geography, true) AS st_distance,
    b.nm_bairro AS bairro_cno
   FROM ( SELECT DISTINCT ON (aa.cno) lpad(row_number() OVER ()::text, 6, '0'::text)::numeric AS id,
            aa.cno::numeric(12,0) AS cno,
            ac.cnae::numeric(7,0) AS cnae,
            ah.descricao AS cno_cnae_descricao,
            ab."Destinação" AS destinacao,
            ab.categoria,
            ab."Tipo de Área" AS tipo_area,
            aa."Área total"::numeric(11,2) AS area_total,
            aa."situação"::numeric(2,0) AS situacao,
            ae.descricao AS situacao_descricao,
            to_date(aa."Data de início"::text, 'YYYY-MM-DD'::text) AS data_inicio,
            to_date(aa."Data da situação"::text, 'YYYY-MM-DD'::text) AS data_situacao,
            aa."Nome empresarial" AS nome_empresarial,
            (((((((((((aa."Tipo de logradouro"::text || ' '::text) || aa.logradouro::text) || ', '::text) || aa."Número do logradouro"::text) || ' - '::text) || aa.bairro::text) || ', '::text) || aa."Nome do município"::text) || ' - '::text) || aa.estado::text) || ', '::text) || aa.cep::text AS endereco_consulta,
            to_date(aa."Data de registro"::text, 'YYYY-MM-DD'::text) AS data_registro,
            ai.latitude,
            ai.longitude,
            (ai.latitude || ','::text) || ai.longitude AS latlong,
            st_setsrid(st_makepoint(ai.longitude::double precision, ai.latitude::double precision), 4326) AS geom2,
            ai.precisao_geocoding,
            ai.endereco_formatado,
            ad."NI do responsável" AS ni_responsavel_vinculo,
            aa."Código do Pais"::text AS cd_pais,
            aa."Nome do pais" AS nm_pais,
            to_date(aa."Data de inicio da responsabilidade"::text, 'YYYY-MM-DD'::text) AS data_inicio_responsabilidade,
            aa."CNO vinculado" AS cno_vinculado,
            aa.cep,
            aa."NI do responsável" AS ni_responsavel,
            aa."Qualificação do responsavel"::numeric(4,0) AS qualificacao_responsavel,
            ag.descricao AS qualificacao_responsavel_descricao,
            aa."Código do municipio"::numeric(4,0) AS cd_mun,
            aa."Nome do município" AS nm_mun,
            aa."Tipo de logradouro" AS tp_logr,
            aa.logradouro AS nm_logr,
            aa."Número do logradouro" AS cd_logr,
            aa.bairro AS nm_bairro,
            aa.estado AS nm_estado,
            aa."Caixa Postal" AS caixa_postal,
            aa.complemento,
            aa."Unidade de medida" AS unidade_medida,
            aa.nome,
            aa."Código de localização" AS codigo_localizacao,
            ab.metragem::numeric(22,0) AS metragem,
            ab."Tipo de Área Complementar" AS tipo_area_complementar,
            to_date(ac."Data de registro"::text, 'YYYY-MM-DD'::text) AS data_registro_cnae,
            to_date(ad."Data de início"::text, 'YYYY-MM-DD'::text) AS data_inicio_vinculo,
            to_date(ad."Data de fim"::text, 'YYYY-MM-DD'::text) AS data_fim_vinculo,
            to_date(ad."Data de registro"::text, 'YYYY-MM-DD'::text) AS data_registro_vinculo,
            ad."Qualificação do contribuinte"::numeric(4,0) AS qualificacao_contribuinte,
            af.descricao AS qualificacao_contribuinte_descricao
           FROM cno.cno aa
             LEFT JOIN cno.cno_areas ab ON aa.cno::text = ab.cno::text
             LEFT JOIN cno.cno_cnaes ac ON ab.cno::text = ac.cno::text
             LEFT JOIN cno.cno_vinculos ad ON ac.cno::text = ad.cno::text
             LEFT JOIN cno.dic_cno_situacao ae ON aa."situação"::numeric = ae.atributo
             LEFT JOIN cno.dic_cno_qualificacao_contribuinte af ON ad."Qualificação do contribuinte"::text = af.atributo
             LEFT JOIN cno.dic_cno_qualificacao_responsavel ag ON aa."Qualificação do responsavel"::text = ag.atributo
             LEFT JOIN cno.dic_cno_cnaes ah ON ac.cnae::text = ah.atributo::text
             LEFT JOIN cno.tb_localizacao ai ON aa.cno::text = ai.cno::text
          WHERE (aa."Nome do município"::text = ANY (ARRAY['SÃO JOSÉ'::text])) AND ai.ativo = true) ee
     JOIN ( SELECT DISTINCT ON (imoveis.gid) imoveis.gid AS gid_cliente,
            st_transform(st_centroid(imoveis.geom), {{src}}) AS ponto_{{src}},
            st_centroid(imoveis.geom) AS ponto_4326,
            imoveis.cidade,
            imoveis.uf,
            (st_y(st_centroid(imoveis.geom)) || ','::text) || st_x(st_centroid(imoveis.geom)) AS latlonglote
           FROM esteira.imoveis) ef ON ef.cidade::text = '{{nm_mun}}'::text AND ef.uf::text = '{{nm_uf}}'::text
     JOIN geo_{{schema}}.cad_bairro b ON st_contains(b.geom, ef.ponto_{{src}})
  WHERE st_contains(b.geom, st_transform(ee.geom2, {{src}}))
WITH DATA;


-- Índice único para monit_estatistica_media_trimestre_raio (necessário para REFRESH CONCURRENTLY)
CREATE UNIQUE INDEX IF NOT EXISTS idx_monit_estat_raio_unique 
ON geo_{{schema}}.monit_estatistica_media_trimestre_raio (row_id);

`;

let finalSql = sqlTemplate;

for (const key in items[0].json) {
  const value = items[0].json[key];
  const regex = new RegExp(`{{${key}}}`, 'g');
  finalSql = finalSql.replace(regex, value);
}

return [{ json: { sql: finalSql } }];
