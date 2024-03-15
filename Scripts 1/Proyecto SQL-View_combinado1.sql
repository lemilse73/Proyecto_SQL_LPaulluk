-- Vista comparativa con los datos de riesgos de los clientes de los meses analizados (combina las vistas de riesgo global del mes anterior y el último mes).

CREATE VIEW riesgo_globalv_combinado_mes_anterior_ultimo AS
SELECT * FROM riesgo_globalv_ultimo_mes
UNION
SELECT * FROM riesgo_globalv_mes_anterior
ORDER BY id_cliente;