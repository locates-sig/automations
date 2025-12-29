-- Buscar tabelas que contêm os campos específicos
SELECT 
    n.nspname AS schema_name,
    c.relname AS table_name,
    STRING_AGG(a.attname, ', ' ORDER BY a.attname) AS campos_encontrados
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
JOIN pg_attribute a ON a.attrelid = c.oid
WHERE c.relkind IN ('r', 'v', 'm', 'p')  -- r=table, v=view, m=materialized view, p=partitioned table
  AND a.attnum > 0  -- Colunas normais (não colunas de sistema)
  AND NOT a.attisdropped  -- Não incluir colunas deletadas
  AND n.nspname NOT IN ('pg_catalog', 'information_schema', 'pg_toast')  -- Excluir schemas do sistema
  AND a.attname IN ('row_id', 'id', 'gid', 'geom', 'gid_cliente')
GROUP BY n.nspname, c.relname
HAVING COUNT(DISTINCT a.attname) >= 1  -- Pelo menos 1 dos campos
ORDER BY n.nspname, c.relname;


Syntax error at line 1 near "%"
Failed query: 

CREATE UNIQUE INDEX ON esteira.dicionario_potencial(id);CREATE UNIQUE INDEX ON esteira.efici(id);CREATE INDEX ON esteira.efici USING GIST (geom);CREATE UNIQUE INDEX ON esteira.eficiencia_floripa(id);CREATE INDEX ON esteira.eficiencia_floripa USING GIST (geom);CREATE UNIQUE INDEX ON esteira.eficiencia_stripmall_floripa(id);CREATE INDEX ON esteira.eficiencia_stripmall_floripa USING GIST (geom);