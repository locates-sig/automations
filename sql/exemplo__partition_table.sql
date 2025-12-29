

-- Tabela de logs particionada por mês
CREATE TABLE observatorio.monit (
    id BIGSERIAL,
    data_tabela DATE NOT NULL,
    tipo_imovel TEXT,
    valor NUMERIC,
    PRIMARY KEY (id, data_tabela)  -- Chave primária DEVE incluir coluna de partição
) PARTITION BY RANGE (data_tabela);

-- Criar partições automaticamente (exemplo)
CREATE TABLE observatorio.monit_2024_01 PARTITION OF observatorio.monit
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE observatorio.monit_2024_02 PARTITION OF observatorio.monit
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- Criar índices em CADA partição
CREATE INDEX idx_monit_2024_01_tipo ON observatorio.monit_2024_01(tipo_imovel);
CREATE INDEX idx_monit_2024_02_tipo ON observatorio.monit_2024_02(tipo_imovel);

-- Consulta a partição correta automaticamente melhorando performance
SELECT * FROM monit WHERE data_tabela = '2024-03-15';
