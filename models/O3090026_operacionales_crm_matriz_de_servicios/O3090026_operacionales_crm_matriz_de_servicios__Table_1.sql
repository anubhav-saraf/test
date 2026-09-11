{{
  config({    
    "materialized": "table",
    "alias": "t_CRM_Servicios",
    "database": "dev_application_operationals",
    "schema": "crm"
  })
}}

WITH sectores_calidad_reclamos AS (

  SELECT * 
  
  FROM {{ source('pro_business_sectores', 'sectores_calidad_reclamos') }}

),

Filter_12_1_1_1_1_1_1 AS (

  SELECT * 
  
  FROM sectores_calidad_reclamos AS in0
  
  WHERE ref_data_date_part <= {{ var('ref_data_date_part') }}

),

aggregate_1_1_1_1_1_1_1_1 AS (

  SELECT any_value(AAAAMM) AS AAAAMM
  
  FROM Filter_12_1_1_1_1_1_1 AS productos_mdp_inventario
  
  GROUP BY AAAAMM

),

OrderBy_1_1_1_1_1_1_1_1 AS (

  SELECT * 
  
  FROM aggregate_1_1_1_1_1_1_1_1 AS in0
  
  ORDER BY AAAAMM DESC NULLS LAST

),

RecordID_1_1_1_1_1_1_1_1 AS (

  {{
    prophecy_basics.RecordID(
      ['OrderBy_1_1_1_1_1_1_1_1'], 
      'incremental_id', 
      'AAAAMM_id', 
      'integer', 
      6, 
      1, 
      'tableLevel', 
      'first_column', 
      [], 
      []
    )
  }}

),

Sample_1_1_1_1_1_1_1_1 AS (

  {{
    prophecy_basics.Sample(
      ['RecordID_1_1_1_1_1_1_1_1'], 
      '[{"name": "AAAAMM_id", "dataType": "Integer"}, {"name": "AAAAMM", "dataType": "String"}]', 
      'sampleDataset', 
      [], 
      1002, 
      'firstN', 
      13, 
      [{ 'expression': { 'expression': 'AAAAMM' }, 'sortType': 'desc' }]
    )
  }}

),

join_1_1_1_1_1_1_1_1 AS (

  SELECT 
    in0.*,
    in1.AAAAMM_id AS AAAAMM_id
  
  FROM sectores_calidad_reclamos AS in0
  INNER JOIN Sample_1_1_1_1_1_1_1_1 AS in1
     ON in0.AAAAMM = in1.AAAAMM

),

Filter_7 AS (

  SELECT * 
  
  FROM join_1_1_1_1_1_1_1_1 AS in0
  
  WHERE tipo_resolucion = 'A favor Cliente'

),

productos_cuentas_transacciones AS (

  SELECT * 
  
  FROM {{ source('pro_business_productos', 'productos_cuentas_transacciones') }}

),

Filter_12_1_1_1_1_1 AS (

  SELECT * 
  
  FROM productos_cuentas_transacciones AS in0
  
  WHERE ref_data_date_part <= {{ var('ref_data_date_part') }}

),

aggregate_1_1_1_1_1_1_1 AS (

  SELECT any_value(AAAAMM) AS AAAAMM
  
  FROM Filter_12_1_1_1_1_1 AS productos_mdp_inventario
  
  GROUP BY AAAAMM

),

OrderBy_1_1_1_1_1_1_1 AS (

  SELECT * 
  
  FROM aggregate_1_1_1_1_1_1_1 AS in0
  
  ORDER BY AAAAMM DESC NULLS LAST

),

RecordID_1_1_1_1_1_1_1 AS (

  {{
    prophecy_basics.RecordID(
      ['OrderBy_1_1_1_1_1_1_1'], 
      'incremental_id', 
      'AAAAMM_id', 
      'integer', 
      6, 
      1, 
      'tableLevel', 
      'first_column', 
      [], 
      []
    )
  }}

),

Sample_1_1_1_1_1_1_1 AS (

  {{
    prophecy_basics.Sample(
      ['RecordID_1_1_1_1_1_1_1'], 
      '[{"name": "AAAAMM_id", "dataType": "Integer"}, {"name": "AAAAMM", "dataType": "String"}]', 
      'sampleDataset', 
      [], 
      1002, 
      'firstN', 
      13, 
      [{ 'expression': { 'expression': 'AAAAMM' }, 'sortType': 'desc' }]
    )
  }}

),

join_1_1_1_1_1_1_1 AS (

  SELECT 
    in0.*,
    in1.AAAAMM_id AS AAAAMM_id
  
  FROM productos_cuentas_transacciones AS in0
  INNER JOIN Sample_1_1_1_1_1_1_1 AS in1
     ON in0.AAAAMM = in1.AAAAMM

),

reformat_11 AS (

  SELECT 
    *,
    CASE
      WHEN (
        codigo_tipo_transaccion_cuenta = '0034'
        and forma_pago_cobro = '01'
        and len(datos_adicionales_transaccion) <> 86
      )
        THEN 'transferencia_interna'
      WHEN (codigo_tipo_transaccion_cuenta = '0034' and forma_pago_cobro = '16')
        THEN 'transferencia_plaza'
      WHEN (
        codigo_tipo_transaccion_cuenta = '0023'
        and forma_pago_cobro = '16'
        and RIGHT(datos_adicionales_transaccion, 4) = 'HGA6'
      )
        THEN 'transferencia_exterior'
      WHEN (codigo_tipo_transaccion_cuenta = '0444' and forma_pago_cobro = '01')
        THEN 'buzoneras'
      WHEN --- Buzonera deposito efectivo
      (codigo_tipo_transaccion_cuenta = '0019' and forma_pago_cobro = '17')
        THEN 'buzoneras'
      WHEN --- Buzonera deposito efectivo
      (codigo_tipo_transaccion_cuenta = '0679')
        THEN 'buzoneras'
      WHEN --- Buzonera deposito efectivo
      (codigo_tipo_transaccion_cuenta = '0003' and forma_pago_cobro = '17')
        THEN 'buzoneras'
      WHEN --- Buzonera deposito cheque
      (codigo_tipo_transaccion_cuenta = '0003' and forma_pago_cobro = '17')
        THEN 'buzoneras'
      WHEN --- Buzonera pago instituciones
      (codigo_tipo_transaccion_cuenta = '0003' and forma_pago_cobro = '08')
        THEN 'atm'
      WHEN --- ATM deposito Cheque
      (codigo_tipo_transaccion_cuenta = '0159' and forma_pago_cobro = '08')
        THEN 'atm'
      WHEN --- ATM deposito Efectivo
      (codigo_tipo_transaccion_cuenta IN ('0036', '5036') and forma_pago_cobro = '08')
        THEN 'atm'
      WHEN --- ATM Retiro Efectivo
      (codigo_tipo_transaccion_cuenta = '0037' and forma_pago_cobro = '08')
        THEN 'atm'
      WHEN --- ATM Pasaje Fondos
      (forma_pago_cobro = '16' and codigo_tipo_transaccion_cuenta IN ('0021', '0422', '0421', '0417'))
        THEN 'dispensador'
      WHEN --- Dispensador retiro
      (
        codigo_tipo_transaccion_cuenta = '0034'
        and forma_pago_cobro = '01'
        and len(datos_adicionales_transaccion) = 86
      )
        THEN 'pago_servicios'
      WHEN --- Pago de servicios
      (codigo_tipo_transaccion_cuenta IN ('0021', '0020', '0298'))
        THEN 'pago_cheques'
      ELSE 'N/A'
    END AS universo_corte
  
  FROM join_1_1_1_1_1_1_1 AS in0

),

Filter_8 AS (

  SELECT * 
  
  FROM reformat_11 AS in0
  
  WHERE universo_corte <> 'N/A'

),

aggregate_14_2 AS (

  SELECT 
    any_value(idf_pers_ods) AS idf_pers_ods,
    any_value(universo_corte) AS universo_corte,
    any_value(AAAAMM_id) AS AAAAMM_id,
    any_value(AAAAMM) AS AAAAMM,
    CAST(count(1) AS int) AS cantidad_casos
  
  FROM Filter_8 AS in0
  
  GROUP BY 
    idf_pers_ods, AAAAMM_id, AAAAMM, universo_corte

),

filter_6_1 AS (

  SELECT * 
  
  FROM join_1_1_1_1_1_1_1 AS in0
  
  WHERE codigo_tipo_transaccion_cuenta = '0035'

),

filter_6 AS (

  SELECT * 
  
  FROM join_1_1_1_1_1_1_1 AS in0
  
  WHERE codigo_tipo_transaccion_cuenta = '0034'

),

filter_6_filter_6_1 AS (

  SELECT 
    in0.idf_pers_ods AS idf_pers_ods,
    in0.AAAAMM AS AAAAMM,
    in0.AAAAMM_id AS AAAAMM_id
  
  FROM filter_6 AS in0
  INNER JOIN filter_6_1 AS in1
     ON in0.numero_referencia_transaccion = in1.numero_referencia_transaccion
    and in0.ref_data_date_part = in1.ref_data_date_part

),

aggregate_15_1_1_1 AS (

  SELECT any_value(idf_pers_ods) AS idf_pers_ods
  
  FROM filter_6_filter_6_1 AS in0
  
  GROUP BY idf_pers_ods

),

join_10_2_1_1_1 AS (

  SELECT 
    in0.idf_pers_ods AS idf_pers_ods,
    in1.AAAAMM_id AS AAAAMM_id,
    in1.AAAAMM AS AAAAMM,
    CAST(0 AS int) AS cantidad_cambios_de_moneda
  
  FROM aggregate_15_1_1_1 AS in0
  INNER JOIN Sample_1_1_1_1_1_1_1 AS in1
     ON 1 = 1

),

canales_sucursales_administrador_de_filas_visitas AS (

  SELECT * 
  
  FROM {{ source('pro_business_canales', 'canales_sucursales_administrador_de_filas_visitas') }}

),

filter_3 AS (

  SELECT * 
  
  FROM canales_sucursales_administrador_de_filas_visitas AS in0
  
  WHERE ref_data_date_part > ({{ var('ref_data_date_part') }} - 10000)

),

aggregate_5 AS (

  SELECT 
    any_value(idf_pers_ods) AS idf_pers_ods,
    any_value(descripcion_team) AS descripcion_team,
    count(idf_pers_ods) AS cantidad_visitas_sucursal
  
  FROM filter_3 AS in0
  
  GROUP BY 
    idf_pers_ods, descripcion_team

),

Sample_4 AS (

  {{
    prophecy_basics.Sample(
      ['aggregate_5'], 
      '[{"name": "idf_pers_ods", "dataType": "String"}, {"name": "descripcion_team", "dataType": "String"}, {"name": "cantidad_visitas_sucursal", "dataType": "Bigint"}]', 
      'sampleGroup', 
      ['idf_pers_ods'], 
      1002, 
      'firstN', 
      1, 
      [{ 'expression': { 'expression': 'cantidad_visitas_sucursal' }, 'sortType': 'desc' }]
    )
  }}

),

aggregate_4 AS (

  SELECT 
    any_value(idf_pers_ods) AS idf_pers_ods,
    count(idf_pers_ods) AS cantidad_visitas,
    sum(tiempo_atencion) AS tiempo_atencion,
    avg(tiempo_espera) AS tiempo_espera
  
  FROM filter_3 AS in0
  
  GROUP BY idf_pers_ods

),

join_6 AS (

  SELECT 
    in0.*,
    in1.descripcion_team AS descripcion_team,
    in1.cantidad_visitas_sucursal AS cantidad_visitas_sucursal
  
  FROM aggregate_4 AS in0
  LEFT JOIN Sample_4 AS in1
     ON in0.idf_pers_ods = in1.idf_pers_ods

),

canales_sucursales_administrador_de_filas_atenciones AS (

  SELECT * 
  
  FROM {{ source('pro_business_canales', 'canales_sucursales_administrador_de_filas_atenciones') }}

),

filter_3_1 AS (

  SELECT * 
  
  FROM canales_sucursales_administrador_de_filas_atenciones AS in0
  
  WHERE ref_data_date_part > ({{ var('ref_data_date_part') }} - 10000)

),

Reformat_5 AS (

  SELECT 
    idf_pers_ods AS idf_pers_ods,
    identificador_visita AS identificador_visita,
    identificador_atencion AS identificador_atencion,
    usuario_banco AS usuario_banco,
    descripcion_team AS descripcion_team,
    coalesce(descripcion_servicio_prestado, tarea) AS descripcion_servicio_tarea_prestada
  
  FROM filter_3_1 AS in0

),

aggregate_5_1 AS (

  SELECT 
    any_value(idf_pers_ods) AS idf_pers_ods,
    any_value(descripcion_servicio_tarea_prestada) AS descripcion_servicio_tarea_prestada,
    count(idf_pers_ods) AS cantidad_veces_servicio_prestado
  
  FROM Reformat_5 AS in0
  
  GROUP BY 
    idf_pers_ods, descripcion_servicio_tarea_prestada

),

Sample_5 AS (

  {{
    prophecy_basics.Sample(
      ['aggregate_5_1'], 
      '[{"name": "idf_pers_ods", "dataType": "String"}, {"name": "descripcion_servicio_tarea_prestada", "dataType": "String"}, {"name": "cantidad_veces_servicio_prestado", "dataType": "Bigint"}]', 
      'sampleGroup', 
      ['idf_pers_ods'], 
      1002, 
      'firstN', 
      1, 
      [{ 'expression': { 'expression': 'cantidad_veces_servicio_prestado' }, 'sortType': 'desc' }]
    )
  }}

),

join_7 AS (

  SELECT 
    in0.*,
    in1.descripcion_servicio_tarea_prestada AS descripcion_servicio_tarea_prestada,
    in1.cantidad_veces_servicio_prestado AS cantidad_veces_servicio_prestado
  
  FROM join_6 AS in0
  LEFT JOIN Sample_5 AS in1
     ON in0.idf_pers_ods = in1.idf_pers_ods

),

reformat_4_1 AS (

  SELECT 
    idf_pers_ods AS idf_pers_ods,
    CAST(4 AS smallint) AS CodServicio,
    concat('Visitas (ultimo año): ', cantidad_visitas) AS Col1,
    concat('Tiempo atención: ', tiempo_atencion, 'min') AS Col2,
    concat('Espera promedio: ', CAST(tiempo_espera AS decimal (19, 2)), 'min') AS Col3,
    concat(
      'Suc. más visitada: ', 
      descripcion_team, 
      ' (', 
      cantidad_visitas_sucursal, 
      CASE
        WHEN cantidad_visitas_sucursal = 1
          THEN ' vez)'
        ELSE ' veces)'
      END) AS Col4,
    concat(
      'Principal operativa: ', 
      coalesce(descripcion_servicio_tarea_prestada, 'N/A'), 
      ' (', 
      cantidad_veces_servicio_prestado, 
      CASE
        WHEN cantidad_veces_servicio_prestado = 1
          THEN ' vez)'
        ELSE ' veces)'
      END) AS Col5
  
  FROM join_7 AS in0

),

canales_digital_usuarios AS (

  SELECT * 
  
  FROM {{ source('pro_business_canales', 'canales_digital_usuarios') }}

),

Filter_12_1_1_1_1 AS (

  SELECT * 
  
  FROM canales_digital_usuarios AS in0
  
  WHERE ref_data_date_part <= {{ var('ref_data_date_part') }}

),

aggregate_1_1_1_1_1_1 AS (

  SELECT 
    any_value(AAAAMM) AS AAAAMM,
    max(ref_data_date_part) AS ref_data_date_part
  
  FROM Filter_12_1_1_1_1 AS productos_mdp_inventario
  
  GROUP BY AAAAMM

),

OrderBy_1_1_1_1_1_1 AS (

  SELECT * 
  
  FROM aggregate_1_1_1_1_1_1 AS in0
  
  ORDER BY AAAAMM DESC NULLS LAST

),

RecordID_1_1_1_1_1_1 AS (

  {{
    prophecy_basics.RecordID(
      ['OrderBy_1_1_1_1_1_1'], 
      'incremental_id', 
      'AAAAMM_id', 
      'integer', 
      6, 
      1, 
      'tableLevel', 
      'first_column', 
      [], 
      []
    )
  }}

),

Sample_1_1_1_1_1_1 AS (

  {{
    prophecy_basics.Sample(
      ['RecordID_1_1_1_1_1_1'], 
      '[{"name": "AAAAMM_id", "dataType": "Integer"}, {"name": "AAAAMM", "dataType": "String"}, {"name": "ref_data_date_part", "dataType": "Integer"}]', 
      'sampleDataset', 
      [], 
      1002, 
      'firstN', 
      4, 
      [{ 'expression': { 'expression': 'AAAAMM' }, 'sortType': 'desc' }]
    )
  }}

),

join_1_1_1_1_1_1 AS (

  SELECT 
    in0.*,
    in1.AAAAMM_id AS AAAAMM_id
  
  FROM canales_digital_usuarios AS in0
  INNER JOIN Sample_1_1_1_1_1_1 AS in1
     ON in0.ref_data_date_part = in1.ref_data_date_part

),

filter_1 AS (

  SELECT * 
  
  FROM join_1_1_1_1_1_1 AS in0
  
  WHERE status_sitio = 'Active' and status_codigo_usuario = 'Active' and AAAAMM_id = 1

),

Reformat_1 AS (

  SELECT 
    *,
    CAST(CASE
      WHEN tiene_llave_digital = false or llave_digital_deshabilitada = true or llave_digital_bloqueada = true
        THEN false
      ELSE true
    END AS boolean) AS tiene_llave_digital_activa,
    CAST(CASE
      WHEN tiene_p2p = false or estado_p2p != 'Active'
        THEN false
      ELSE true
    END AS boolean) AS tiene_p2p_activo
  
  FROM filter_1 AS in0

),

Sample_1 AS (

  {{
    prophecy_basics.Sample(
      ['Reformat_1'], 
      '[{"name": "ref_data_date_part", "dataType": "Integer"}, {"name": "ref_timestamp_procesamiento", "dataType": "Timestamp"}, {"name": "AAAAMM", "dataType": "String"}, {"name": "codigo_sitio_supernet4", "dataType": "Integer"}, {"name": "codigo_sitio_supernet5", "dataType": "Integer"}, {"name": "nombre_sitio", "dataType": "String"}, {"name": "fecha_hora_creacion_sitio", "dataType": "Timestamp"}, {"name": "fecha_hora_aprobacion_sitio", "dataType": "Timestamp"}, {"name": "descripcion_tipo_sitio", "dataType": "String"}, {"name": "descripcion_modalidad_sitio", "dataType": "String"}, {"name": "tiene_llave_digital", "dataType": "Boolean"}, {"name": "llave_digital_bloqueada", "dataType": "Boolean"}, {"name": "llave_digital_deshabilitada", "dataType": "Boolean"}, {"name": "fecha_hora_alta_llave_digital", "dataType": "Timestamp"}, {"name": "fecha_hora_ultimo_uso_llave_digital", "dataType": "Timestamp"}, {"name": "tiene_p2p", "dataType": "Boolean"}, {"name": "estado_p2p", "dataType": "String"}, {"name": "fecha_hora_cambio_estado_p2p", "dataType": "Timestamp"}, {"name": "status_sitio", "dataType": "String"}, {"name": "es_migrado", "dataType": "Boolean"}, {"name": "fecha_hora_migracion", "dataType": "Timestamp"}, {"name": "fecha_hora_ultimo_login_sitio", "dataType": "Timestamp"}, {"name": "codigo_usuario", "dataType": "String"}, {"name": "codigo_usuario_sitio", "dataType": "Integer"}, {"name": "estado_usuario_sitio", "dataType": "String"}, {"name": "idf_pers_ods", "dataType": "String"}, {"name": "es_titular", "dataType": "Boolean"}, {"name": "nombre_usuario", "dataType": "String"}, {"name": "apellido_usuario", "dataType": "String"}, {"name": "status_codigo_usuario", "dataType": "String"}, {"name": "descripcion_tipo_usuario", "dataType": "String"}, {"name": "descripcion_modalidad_usuario", "dataType": "String"}, {"name": "idf_pers_ods_del_asociador", "dataType": "String"}, {"name": "fecha_hora_creacion_usuario", "dataType": "Timestamp"}, {"name": "fecha_hora_modificacion_usuario", "dataType": "Timestamp"}, {"name": "fecha_hora_ultimo_login_usuario", "dataType": "Timestamp"}, {"name": "fecha_hora_ultimo_cambio_password", "dataType": "Timestamp"}, {"name": "plataforma", "dataType": "String"}, {"name": "accesos_app", "dataType": "Integer"}, {"name": "accesos_app_tc", "dataType": "Integer"}, {"name": "accesos_banred", "dataType": "Integer"}, {"name": "accesos_web", "dataType": "Integer"}, {"name": "accesos_otros", "dataType": "Integer"}, {"name": "accesos_totales", "dataType": "Integer"}, {"name": "AAAAMM_id", "dataType": "Integer"}, {"name": "tiene_llave_digital_activa", "dataType": "Boolean"}, {"name": "tiene_p2p_activo", "dataType": "Boolean"}]', 
      'sampleGroup', 
      ['idf_pers_ods'], 
      1002, 
      'firstN', 
      1, 
      [{ 'expression': { 'expression': 'fecha_hora_ultimo_login_usuario' }, 'sortType': 'desc' }]
    )
  }}

),

aggregate_8 AS (

  SELECT 
    any_value(idf_pers_ods) AS idf_pers_ods,
    count(1) AS cantidad_incidentes
  
  FROM join_1_1_1_1_1_1_1_1 AS in0
  
  GROUP BY idf_pers_ods

),

canales_biometria_clientes AS (

  SELECT * 
  
  FROM {{ source('pro_business_canales', 'canales_biometria_clientes') }}

),

filter_2 AS (

  SELECT * 
  
  FROM canales_biometria_clientes AS in0
  
  WHERE ref_data_date_part = {{ var('ref_data_date_part') }}

),

aggregate_1 AS (

  SELECT 
    any_value(idf_pers_ods) AS idf_pers_ods,
    max(tiene_p2p_activo) AS tiene_p2p_activo,
    max(tiene_llave_digital) AS tiene_llave_digital,
    max(fecha_hora_ultimo_uso_llave_digital) AS fecha_hora_ultimo_uso_llave_digital
  
  FROM Reformat_1 AS filter_1
  
  GROUP BY idf_pers_ods

),

join_1 AS (

  SELECT 
    in0.idf_pers_ods AS idf_pers_ods,
    in1.tiene_p2p_activo AS tiene_p2p_activo,
    in0.tiene_llave_digital_activa AS tiene_llave_digital_activa,
    in0.descripcion_tipo_sitio AS descripcion_tipo_sitio,
    in0.descripcion_tipo_usuario AS descripcion_tipo_usuario,
    in0.descripcion_modalidad_usuario AS descripcion_modalidad_usuario,
    in1.fecha_hora_ultimo_uso_llave_digital AS fecha_hora_ultimo_uso_llave_digital
  
  FROM Sample_1 AS in0
  INNER JOIN aggregate_1 AS in1
     ON in0.idf_pers_ods = in1.idf_pers_ods

),

filter_1_1 AS (

  SELECT * 
  
  FROM join_1_1_1_1_1_1 AS in0
  
  WHERE status_sitio = 'Active' and status_codigo_usuario = 'Active' and AAAAMM_id <> 1

),

aggregate_2 AS (

  SELECT 
    any_value(idf_pers_ods) AS idf_pers_ods,
    sum(accesos_app) AS accesos_app,
    sum(accesos_app_tc) AS accesos_app_tc,
    sum(accesos_banred) AS accesos_banred,
    sum(accesos_web) AS accesos_web,
    sum(accesos_otros) AS accesos_otros,
    sum(accesos_totales) AS accesos_totales
  
  FROM filter_1_1 AS in0
  
  GROUP BY idf_pers_ods

),

Reformat_2 AS (

  SELECT 
    *,
    CASE
      WHEN accesos_web > 0
      AND COALESCE(accesos_otros, 0)
          + COALESCE(accesos_banred, 0)
          + COALESCE(accesos_app_tc, 0)
          + COALESCE(accesos_app, 0) = 0
        THEN 'Solo Web'
      WHEN accesos_app > 0
      AND COALESCE(accesos_otros, 0)
          + COALESCE(accesos_banred, 0)
          + COALESCE(accesos_app_tc, 0)
          + COALESCE(accesos_web, 0) = 0
        THEN 'Solo App'
      WHEN accesos_totales = 0
        THEN 'N/A'
      ELSE 'Web y App'
    END AS tipo_cliente_digital
  
  FROM aggregate_2 AS in0

),

join_2 AS (

  SELECT 
    in0.*,
    in1.accesos_app AS accesos_app,
    in1.accesos_app_tc AS accesos_app_tc,
    in1.accesos_banred AS accesos_banred,
    in1.accesos_web AS accesos_web,
    in1.accesos_otros AS accesos_otros,
    in1.accesos_totales AS accesos_totales,
    in1.tipo_cliente_digital AS tipo_cliente_digital
  
  FROM join_1 AS in0
  LEFT JOIN Reformat_2 AS in1
     ON in0.idf_pers_ods = in1.idf_pers_ods

),

join_3 AS (

  SELECT 
    in0.*,
    in1.descripcion_ultimo_estado AS biometria_descripcion_ultimo_estado,
    in1.fecha_hora_ultimo_estado AS biometria_fecha_hora_ultimo_estado
  
  FROM join_2 AS in0
  LEFT JOIN filter_2 AS in1
     ON in0.idf_pers_ods = in1.idf_pers_ods

),

reformat_3 AS (

  SELECT 
    idf_pers_ods AS idf_pers_ods,
    CAST(1 AS smallint) AS CodServicio,
    concat('Plataforma: ', coalesce(descripcion_tipo_sitio, 'N/A')) AS Col1,
    concat('Tipo de cliente: ', coalesce(tipo_cliente_digital, 'N/A')) AS Col2,
    concat('Modalidad: ', coalesce(descripcion_modalidad_usuario, 'N/A')) AS Col3,
    concat(
      'Llave digital: ', 
      CASE
        WHEN tiene_llave_digital_activa = true
          THEN 'Activa'
        ELSE 'No disponible'
      END) AS Col4,
    concat(
      'Fecha ultimo uso llave digital: ', 
      coalesce(date_format(fecha_hora_ultimo_uso_llave_digital, 'dd-MM-yyyy'), 'N/A')) AS Col5,
    concat('YaTePago: ', CASE
      WHEN tiene_p2p_activo = true
        THEN 'Activo'
      ELSE 'No disponible'
    END) AS Col6,
    CASE
      WHEN biometria_descripcion_ultimo_estado = 'COMPLETED'
        THEN 'Biometria: Activa'
      WHEN biometria_descripcion_ultimo_estado IS NULL OR trim(biometria_descripcion_ultimo_estado) = ''
        THEN 'Biometria: No enrolado'
      ELSE 'Biometria: Iniciado no finalizado'
    END AS Col7,
    concat(
      'Fecha alta biometria: ', 
      CASE
        WHEN biometria_descripcion_ultimo_estado = 'COMPLETED'
          THEN date_format(biometria_fecha_hora_ultimo_estado, 'yyyy-MM-dd')
        ELSE 'N/A'
      END) AS Col8
  
  FROM join_3

),

canales_cabinas_atenciones AS (

  SELECT * 
  
  FROM {{ source('pro_business_canales', 'canales_cabinas_atenciones') }}

),

filter_3_2 AS (

  SELECT * 
  
  FROM canales_cabinas_atenciones AS in0
  
  WHERE ref_data_date_part > ({{ var('ref_data_date_part') }} - 10000)
        and subtramite IS NOT NULL
        and idf_pers_ods IS NOT NULL

),

Filter_4 AS (

  SELECT * 
  
  FROM filter_3_2 AS in0
  
  WHERE subtramite IN ('Resuelto en cabina SI', 'Resuelto en cabina NO')

),

Reformat_7 AS (

  SELECT 
    in0.*,
    CAST(CASE
      WHEN subtramite = 'Resuelto en cabina SI'
        THEN 1
      ELSE 0
    END AS INT) AS resuelto_cabina
  
  FROM Filter_4 AS in0

),

aggregate_7 AS (

  SELECT 
    any_value(id_turno) AS id_turno,
    max(resuelto_cabina) AS resuelto_cabina,
    any_value(idf_pers_ods) AS idf_pers_ods
  
  FROM Reformat_7 AS in0
  
  GROUP BY 
    idf_pers_ods, id_turno

),

aggregate_6 AS (

  SELECT 
    any_value(idf_pers_ods) AS idf_pers_ods,
    any_value(sector_llamado) AS sector_llamado,
    any_value(usuario_banco) AS usuario_banco,
    count(idf_pers_ods) AS cantidad_atenciones
  
  FROM filter_3_1 AS in0
  
  GROUP BY 
    idf_pers_ods, sector_llamado, usuario_banco

),

Sample_6 AS (

  {{
    prophecy_basics.Sample(
      ['aggregate_6'], 
      '[{"name": "idf_pers_ods", "dataType": "String"}, {"name": "sector_llamado", "dataType": "String"}, {"name": "usuario_banco", "dataType": "String"}, {"name": "cantidad_atenciones", "dataType": "Bigint"}]', 
      'sampleGroup', 
      ['idf_pers_ods', 'sector_llamado'], 
      1002, 
      'firstN', 
      1, 
      [{ 'expression': { 'expression': 'cantidad_atenciones' }, 'sortType': 'desc' }]
    )
  }}

),

reformat_6 AS (

  SELECT 
    idf_pers_ods AS idf_pers_ods,
    replace(sector_llamado, ' ', '_') AS sector_llamado,
    usuario_banco AS usuario_banco,
    cantidad_atenciones AS cantidad_atenciones,
    concat(
      usuario_banco, 
      ' (', 
      cantidad_atenciones, 
      CASE
        WHEN cantidad_atenciones = 1
          THEN ' vez)'
        ELSE ' veces)'
      END) AS funcionario_visitas
  
  FROM Sample_6

),

aggregate_14_1_1_1 AS (

  SELECT 
    any_value(idf_pers_ods) AS idf_pers_ods,
    any_value(AAAAMM_id) AS AAAAMM_id,
    any_value(AAAAMM) AS AAAAMM,
    CAST(count(1) AS int) AS cantidad_cambios_de_moneda
  
  FROM filter_6_filter_6_1 AS in0
  
  GROUP BY 
    idf_pers_ods, AAAAMM_id, AAAAMM

),

join_11_2_1_1_1 AS (

  SELECT 
    in0.idf_pers_ods AS idf_pers_ods,
    in0.AAAAMM_id AS AAAAMM_id,
    in0.AAAAMM AS AAAAMM,
    in0.cantidad_cambios_de_moneda AS cantidad_cambios_de_moneda
  
  FROM join_10_2_1_1_1 AS in0
  ANTI JOIN aggregate_14_1_1_1 AS in1
     ON in0.idf_pers_ods = in1.idf_pers_ods and in0.AAAAMM = in1.AAAAMM

),

Union_2 AS (

  SELECT * 
  
  FROM join_11_2_1_1_1 AS in0
  
  UNION
  
  SELECT * 
  
  FROM aggregate_14_1_1_1 AS in1

),

Reformat_7_1_1_1_1_1 AS (

  SELECT 
    *,
    concat_ws(';', AAAAMM, cantidad_cambios_de_moneda) AS cantidad_cambios_de_moneda_aaaamm
  
  FROM Union_2 AS in0

),

aggregate_9 AS (

  SELECT 
    any_value(idf_pers_ods) AS idf_pers_ods,
    any_value(producto_con_incidente) AS producto_con_incidente,
    count(1) AS cantidad_por_producto
  
  FROM join_1_1_1_1_1_1_1_1 AS in0
  
  GROUP BY 
    idf_pers_ods, producto_con_incidente

),

Sample_9 AS (

  {{
    prophecy_basics.Sample(
      ['aggregate_9'], 
      '[{"name": "idf_pers_ods", "dataType": "String"}, {"name": "producto_con_incidente", "dataType": "String"}, {"name": "cantidad_por_producto", "dataType": "Bigint"}]', 
      'sampleGroup', 
      ['idf_pers_ods'], 
      1002, 
      'firstN', 
      1, 
      [{ 'expression': { 'expression': 'cantidad_por_producto' }, 'sortType': 'desc' }]
    )
  }}

),

aggregate_8_1 AS (

  SELECT 
    any_value(idf_pers_ods) AS idf_pers_ods,
    count(1) AS cantidad_incidentes_a_favor
  
  FROM Filter_7 AS in0
  
  GROUP BY idf_pers_ods

),

join_9 AS (

  SELECT 
    in0.idf_pers_ods AS idf_pers_ods,
    in0.cantidad_incidentes AS cantidad_incidentes,
    in1.cantidad_incidentes_a_favor AS cantidad_incidentes_a_favor,
    in2.producto_con_incidente AS producto_con_incidente,
    in2.cantidad_por_producto AS cantidad_por_producto
  
  FROM aggregate_8 AS in0
  INNER JOIN aggregate_8_1 AS in1
     ON in0.idf_pers_ods = in1.idf_pers_ods
  INNER JOIN Sample_9 AS in2
     ON in0.idf_pers_ods = in2.idf_pers_ods

),

aggregate_15_2 AS (

  SELECT 
    any_value(idf_pers_ods) AS idf_pers_ods,
    any_value(universo_corte) AS universo_corte
  
  FROM Filter_8 AS in0
  
  GROUP BY 
    idf_pers_ods, universo_corte

),

join_10_2_2 AS (

  SELECT 
    in0.idf_pers_ods AS idf_pers_ods,
    in1.AAAAMM_id AS AAAAMM_id,
    in1.AAAAMM AS AAAAMM,
    in0.universo_corte AS universo_corte,
    CAST(0 AS int) AS cantidad_casos
  
  FROM aggregate_15_2 AS in0
  INNER JOIN Sample_1_1_1_1_1_1_1 AS in1
     ON 1 = 1

),

join_11_2_2 AS (

  SELECT 
    in0.idf_pers_ods AS idf_pers_ods,
    in0.universo_corte AS universo_corte,
    in0.AAAAMM_id AS AAAAMM_id,
    in0.AAAAMM AS AAAAMM,
    in0.cantidad_casos AS cantidad_casos
  
  FROM join_10_2_2 AS in0
  ANTI JOIN aggregate_14_2 AS in1
     ON in0.idf_pers_ods = in1.idf_pers_ods
    and in0.AAAAMM = in1.AAAAMM
    and in0.universo_corte = in1.universo_corte

),

Union_1 AS (

  SELECT * 
  
  FROM join_11_2_2 AS in0
  
  UNION
  
  SELECT * 
  
  FROM aggregate_14_2 AS in1

),

Reformat_7_1_1_2 AS (

  SELECT 
    *,
    concat_ws(';', AAAAMM, cantidad_casos) AS cantidad_casos_aaaamm
  
  FROM Union_1 AS in0

),

Pivot_1_1_2_1_1_2 AS (

  SELECT *
  
  FROM (
    SELECT 
      idf_pers_ods,
      universo_corte,
      AAAAMM_id,
      cantidad_casos_aaaamm
    
    FROM Reformat_7_1_1_2 AS join_1_1_1
  )
  PIVOT (
    FIRST(cantidad_casos_aaaamm)
    FOR AAAAMM_id
    IN (
      1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
    )
  )

),

reformat_5_1_2_1_1_2 AS (

  SELECT 
    idf_pers_ods AS idf_pers_ods,
    CASE
      WHEN universo_corte IN ('transferencia_interna', 'transferencia_plaza', 'transferencia_exterior')
        THEN CAST(2 AS smallint)
      WHEN universo_corte IN ('buzoneras', 'atm', 'dispensador')
        THEN CAST(3 AS smallint)
      WHEN universo_corte IN ('pago_servicios')
        THEN CAST(5 AS smallint)
      ELSE CAST(99 AS smallint)
    END AS CodServicio,
    CASE
      WHEN universo_corte = 'transferencia_interna'
        THEN 'Transferencias Internas'
      WHEN universo_corte = 'transferencia_plaza'
        THEN 'Transferencias Plaza'
      WHEN universo_corte = 'transferencia_exterior'
        THEN 'Transferencias Exterior'
      WHEN universo_corte = 'buzoneras'
        THEN 'Uso Buzoneras'
      WHEN universo_corte = 'atm'
        THEN 'Uso ATM'
      WHEN universo_corte = 'dispensador'
        THEN 'Uso Dispensador'
      WHEN universo_corte = 'pago_servicios'
        THEN 'Pagos Servicios'
      ELSE 'N/A'
    END AS Col1,
    `1` AS Col2,
    `2` AS Col3,
    `3` AS Col4,
    `4` AS Col5,
    `5` AS Col6,
    `6` AS Col7,
    `7` AS Col8,
    `8` AS Col9,
    `9` AS Col10,
    `10` AS Col11,
    `11` AS Col12,
    `12` AS Col13,
    `13` AS Col14
  
  FROM Pivot_1_1_2_1_1_2 AS Pivot_1

),

Pivot_1 AS (

  SELECT *
  
  FROM (
    SELECT 
      idf_pers_ods,
      sector_llamado,
      funcionario_visitas
    
    FROM reformat_6 AS in0
  )
  PIVOT (
    CONCAT_WS(', ', COLLECT_LIST(funcionario_visitas))
    FOR sector_llamado
    IN (
      'CAJAS', 'ATENCION_AL_CLIENTE', 'EJECUTIVOS_DE_CUENTA'
    )
  )

),

aggregate_3 AS (

  SELECT 
    any_value(idf_pers_ods) AS idf_pers_ods,
    max(fecha_hora_ultimo_login_usuario) AS fecha_hora_ultimo_login_usuario
  
  FROM filter_1 AS in0
  
  GROUP BY idf_pers_ods

),

join_4 AS (

  SELECT 
    in1.*,
    in0.fecha_hora_ultimo_login_usuario AS fecha_hora_ultimo_login_usuario
  
  FROM aggregate_3 AS in0
  INNER JOIN Reformat_2 AS in1
     ON in0.idf_pers_ods = in1.idf_pers_ods

),

reformat_3_1 AS (

  SELECT 
    idf_pers_ods AS idf_pers_ods,
    CAST(1 AS smallint) AS CodServicio,
    concat('Ultimo Login: ', coalesce(date_format(fecha_hora_ultimo_login_usuario, 'dd-MM-yyyy'), 'N/A')) AS Col1,
    concat('Accesos Totales Trimestre: ', coalesce(accesos_totales, 0)) AS Col2,
    concat('Accesos APP Trimestre: ', coalesce(accesos_app, 0)) AS Col3,
    concat('Accesos Web Trimestre: ', coalesce(accesos_web, 0)) AS Col4,
    concat('Accesos Banred Trimestre: ', coalesce(accesos_banred, 0)) AS Col5,
    concat(
      'Accesos Resto Trimestre: ', 
      coalesce(accesos_totales, 0)
      - coalesce(accesos_app, 0)
      - coalesce(accesos_web, 0)
      - coalesce(accesos_banred, 0)) AS Col6
  
  FROM join_4 AS join_3

),

Sample_2 AS (

  {{
    prophecy_basics.Sample(
      ['filter_3_1'], 
      '[{"name": "ref_data_date_part", "dataType": "Integer"}, {"name": "ref_timestamp_procesamiento", "dataType": "Timestamp"}, {"name": "idf_pers_ods", "dataType": "String"}, {"name": "pais_documento", "dataType": "String"}, {"name": "tipo_documento", "dataType": "String"}, {"name": "numero_documento", "dataType": "String"}, {"name": "identificador_visita", "dataType": "Integer"}, {"name": "genera_numero", "dataType": "Boolean"}, {"name": "identificador_atencion", "dataType": "Integer"}, {"name": "codigo_segmento", "dataType": "String"}, {"name": "codigo_subsegmento", "dataType": "String"}, {"name": "estado_tramite", "dataType": "String"}, {"name": "fecha_hora_inicio_atencion", "dataType": "Timestamp"}, {"name": "fecha_hora_fin_atencion", "dataType": "Timestamp"}, {"name": "tiempo_espera", "dataType": "Decimal(19, 2)"}, {"name": "tiempo_atencion", "dataType": "Decimal(19, 2)"}, {"name": "sector_seleccionado", "dataType": "String"}, {"name": "sector_llamado", "dataType": "String"}, {"name": "super_grupo_tarea", "dataType": "String"}, {"name": "grupo_tarea", "dataType": "String"}, {"name": "tarea", "dataType": "String"}, {"name": "fila", "dataType": "String"}, {"name": "codigo_servicio_prestado", "dataType": "Integer"}, {"name": "descripcion_servicio_prestado", "dataType": "String"}, {"name": "usuario_banco", "dataType": "String"}, {"name": "codigo_team", "dataType": "String"}, {"name": "descripcion_team", "dataType": "String"}, {"name": "grupo_sucursal", "dataType": "String"}]', 
      'sampleGroup', 
      ['identificador_visita'], 
      1002, 
      'firstN', 
      1, 
      [{ 'expression': { 'expression': 'tiempo_atencion' }, 'sortType': 'desc' }]
    )
  }}

),

Sample_3 AS (

  {{
    prophecy_basics.Sample(
      ['filter_3'], 
      '[{"name": "ref_data_date_part", "dataType": "Integer"}, {"name": "ref_timestamp_procesamiento", "dataType": "Timestamp"}, {"name": "idf_pers_ods", "dataType": "String"}, {"name": "pais_documento", "dataType": "String"}, {"name": "tipo_documento", "dataType": "String"}, {"name": "numero_documento", "dataType": "String"}, {"name": "identificador_visita", "dataType": "Integer"}, {"name": "genera_numero", "dataType": "Boolean"}, {"name": "codigo_segmento", "dataType": "String"}, {"name": "codigo_subsegmento", "dataType": "String"}, {"name": "estado_tramite", "dataType": "String"}, {"name": "fecha_hora_extraccion_ticket", "dataType": "Timestamp"}, {"name": "fecha_hora_inicio_atencion", "dataType": "Timestamp"}, {"name": "fecha_hora_fin_atencion", "dataType": "Timestamp"}, {"name": "tiempo_espera", "dataType": "Decimal(19, 2)"}, {"name": "tiempo_atencion", "dataType": "Decimal(19, 2)"}, {"name": "tiempo_total_en_sucursal", "dataType": "Decimal(19, 2)"}, {"name": "cantidad_atenciones", "dataType": "Integer"}, {"name": "codigo_team", "dataType": "String"}, {"name": "descripcion_team", "dataType": "String"}, {"name": "grupo_sucursal", "dataType": "String"}]', 
      'sampleGroup', 
      ['idf_pers_ods'], 
      1002, 
      'firstN', 
      1, 
      [{ 'expression': { 'expression': 'fecha_hora_extraccion_ticket' }, 'sortType': 'desc' }]
    )
  }}

),

Join_5 AS (

  SELECT 
    in0.*,
    in1.descripcion_servicio_prestado AS descripcion_servicio_prestado,
    in1.usuario_banco AS usuario_banco
  
  FROM Sample_3 AS in0
  INNER JOIN Sample_2 AS in1
     ON in0.identificador_visita = in1.identificador_visita

),

reformat_4 AS (

  SELECT 
    idf_pers_ods AS idf_pers_ods,
    CAST(4 AS smallint) AS CodServicio,
    'Ultima visita' AS Col1,
    concat('Fecha y hora: ', fecha_hora_extraccion_ticket) AS Col2,
    concat('Sucursal: ', descripcion_team) AS Col3,
    concat('Usuario atencion: ', usuario_banco) AS Col4,
    concat('Tiempo espera: ', tiempo_espera, 'min') AS Col5,
    concat('Tiempo atencion: ', tiempo_atencion, 'min') AS Col6,
    concat('Motivo: ', descripcion_servicio_prestado) AS Col7
  
  FROM Join_5 AS in0

),

reformat_4_1_1 AS (

  SELECT 
    idf_pers_ods AS idf_pers_ods,
    CAST(4 AS smallint) AS CodServicio,
    'Sectores y principales funcionarios' AS Col1,
    concat('Cajas: ', CASE
      WHEN CAJAS IS NULL OR CAJAS = ''
        THEN 'N/A'
      ELSE CAJAS
    END) AS Col2,
    concat(
      'Mostrador: ', 
      CASE
        WHEN ATENCION_AL_CLIENTE IS NULL OR ATENCION_AL_CLIENTE = ''
          THEN 'N/A'
        ELSE ATENCION_AL_CLIENTE
      END) AS Col3,
    concat(
      'Ejecutivos: ', 
      CASE
        WHEN EJECUTIVOS_DE_CUENTA IS NULL OR EJECUTIVOS_DE_CUENTA = ''
          THEN 'N/A'
        ELSE EJECUTIVOS_DE_CUENTA
      END) AS Col4
  
  FROM Pivot_1 AS in0

),

Pivot_1_1_2_1_1_1_1_1 AS (

  SELECT *
  
  FROM (
    SELECT 
      idf_pers_ods,
      AAAAMM_id,
      cantidad_cambios_de_moneda_aaaamm
    
    FROM Reformat_7_1_1_1_1_1 AS join_1_1_1
  )
  PIVOT (
    FIRST(cantidad_cambios_de_moneda_aaaamm)
    FOR AAAAMM_id
    IN (
      1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
    )
  )

),

reformat_5_1_2_1_1_1_1_1 AS (

  SELECT 
    idf_pers_ods AS idf_pers_ods,
    CAST(2 AS smallint) AS CodServicio,
    'Cambios de Moneda' AS Col1,
    `1` AS Col2,
    `2` AS Col3,
    `3` AS Col4,
    `4` AS Col5,
    `5` AS Col6,
    `6` AS Col7,
    `7` AS Col8,
    `8` AS Col9,
    `9` AS Col10,
    `10` AS Col11,
    `11` AS Col12,
    `12` AS Col13,
    `13` AS Col14
  
  FROM Pivot_1_1_2_1_1_1_1_1 AS Pivot_1

),

join_8 AS (

  SELECT 
    in0.*,
    in1.resuelto_cabina AS resuelto_cabina
  
  FROM filter_3_2 AS in0
  INNER JOIN aggregate_7 AS in1
     ON in0.id_turno = in1.id_turno and in0.idf_pers_ods = in1.idf_pers_ods

),

Sample_7 AS (

  {{
    prophecy_basics.Sample(
      ['join_8'], 
      '[{"name": "ref_data_date_part", "dataType": "Integer"}, {"name": "ref_timestamp_procesamiento", "dataType": "Timestamp"}, {"name": "idf_pers_ods", "dataType": "String"}, {"name": "id_turno", "dataType": "Integer"}, {"name": "ordinal_turno", "dataType": "Integer"}, {"name": "turno", "dataType": "String"}, {"name": "fecha_hora_dato", "dataType": "Timestamp"}, {"name": "accion_turno", "dataType": "String"}, {"name": "tramite", "dataType": "String"}, {"name": "subtramite", "dataType": "String"}, {"name": "email_usuario", "dataType": "String"}, {"name": "puesto_atencion", "dataType": "String"}, {"name": "numero_documento", "dataType": "String"}, {"name": "telefono", "dataType": "String"}, {"name": "id_sala_espera", "dataType": "Bigint"}, {"name": "nombre_sala_espera", "dataType": "String"}, {"name": "tiempo_espera", "dataType": "Decimal(19, 2)"}, {"name": "tiempo_atencion", "dataType": "Decimal(19, 2)"}, {"name": "nombre_terminal", "dataType": "String"}, {"name": "tiene_prioridad", "dataType": "Boolean"}, {"name": "computa_nivel_sevicio", "dataType": "Boolean"}, {"name": "id_sesion_videollamada_chat", "dataType": "String"}, {"name": "id_grabacion_videollamada_chat", "dataType": "String"}, {"name": "link_descarga_videollamada_chat", "dataType": "String"}, {"name": "resuelto_cabina", "dataType": "Integer"}]', 
      'sampleGroup', 
      ['idf_pers_ods'], 
      1002, 
      'firstN', 
      1, 
      [{ 'expression': { 'expression': 'fecha_hora_dato' }, 'sortType': 'asc_nulls_last' }]
    )
  }}

),

reformat_8 AS (

  SELECT 
    idf_pers_ods AS idf_pers_ods,
    CAST(4 AS smallint) AS CodServicio,
    'Ultima visita Cabina:' AS Col1,
    concat('Fecha y hora: ', date_trunc('second', fecha_hora_dato)) AS Col2,
    concat('Cabina: ', nombre_terminal) AS Col3,
    concat(
      'Motivo: ', 
      CASE
        WHEN subtramite IN ('Resuelto en cabina SI', 'Resuelto en cabina NO')
          THEN tramite
        ELSE subtramite
      END) AS Col4,
    concat('Resuelto en cabina: ', CASE
      WHEN resuelto_cabina = 1
        THEN 'Si'
      ELSE 'No'
    END) AS Col5
  
  FROM Sample_7

),

Sample_8 AS (

  {{
    prophecy_basics.Sample(
      ['join_1_1_1_1_1_1_1_1'], 
      '[{"name": "ref_data_date_part", "dataType": "Integer"}, {"name": "ref_timestamp_procesamiento", "dataType": "Timestamp"}, {"name": "idf_pers_ods", "dataType": "String"}, {"name": "numero_incidente", "dataType": "Integer"}, {"name": "fecha_incidente", "dataType": "Date"}, {"name": "fecha_vencimiento_sla", "dataType": "Date"}, {"name": "fecha_vencimiento_bcu", "dataType": "Date"}, {"name": "nombre_sector_ingreso", "dataType": "String"}, {"name": "nombre_usuario_ingreso", "dataType": "String"}, {"name": "fecha_resolucion", "dataType": "Date"}, {"name": "nombre_usuario_resolucion", "dataType": "String"}, {"name": "nombre_sector_resolucion", "dataType": "String"}, {"name": "fecha_cierre", "dataType": "Date"}, {"name": "nombre_usuario_cierre", "dataType": "String"}, {"name": "nombre_sector_cierre", "dataType": "String"}, {"name": "estado_incidente", "dataType": "String"}, {"name": "semaforo_sla", "dataType": "String"}, {"name": "semaforo_bcu", "dataType": "String"}, {"name": "nombre_sector_asignado", "dataType": "String"}, {"name": "tipo_incidente", "dataType": "String"}, {"name": "tag_motivo_incidente", "dataType": "String"}, {"name": "producto_con_incidente", "dataType": "String"}, {"name": "descripcion_subsegmento", "dataType": "String"}, {"name": "fecha_recepcion", "dataType": "Date"}, {"name": "canal_recepcion", "dataType": "String"}, {"name": "descripcion_incidente", "dataType": "String"}, {"name": "monto_reclamado_pesos", "dataType": "Decimal(27, 2)"}, {"name": "monto_reclamado_dolares", "dataType": "Decimal(27, 2)"}, {"name": "monto_reclamado_euros", "dataType": "Decimal(27, 2)"}, {"name": "monto_reclamado_arbitrado_dolares", "dataType": "Decimal(27, 2)"}, {"name": "pan_tarjeta", "dataType": "String"}, {"name": "tipo_resolucion", "dataType": "String"}, {"name": "motivo_de_resolucion", "dataType": "String"}, {"name": "motivo_devolucion", "dataType": "String"}, {"name": "contacto_cliente", "dataType": "String"}, {"name": "fecha_contacto", "dataType": "Date"}, {"name": "nombre_usuario_contacto", "dataType": "String"}, {"name": "plazo_especial", "dataType": "String"}, {"name": "monto_final_pesos", "dataType": "Decimal(27, 2)"}, {"name": "monto_final_dolares", "dataType": "Decimal(27, 2)"}, {"name": "monto_final_euros", "dataType": "Decimal(27, 2)"}, {"name": "monto_final_arbitrado_dolares", "dataType": "Decimal(27, 2)"}, {"name": "dias_plazo_bcu", "dataType": "Integer"}, {"name": "dias_plazo_sla", "dataType": "Integer"}, {"name": "dias_corridos_transcurridos", "dataType": "Integer"}, {"name": "motivo_bcu", "dataType": "String"}, {"name": "nombre_oficial", "dataType": "String"}, {"name": "detalle_transacciones", "dataType": "String"}, {"name": "con_automatizacion", "dataType": "String"}, {"name": "resolucion_inmediata", "dataType": "String"}, {"name": "tiempo_en_sector_resolucion", "dataType": "Integer"}, {"name": "tiempo_en_sector_cierre", "dataType": "Integer"}, {"name": "tiempo_en_otros_sectores", "dataType": "Integer"}, {"name": "tiempo_total", "dataType": "Integer"}, {"name": "prorrogado_bcu", "dataType": "String"}, {"name": "seguro", "dataType": "String"}, {"name": "aseguradora", "dataType": "String"}, {"name": "detalle_sectores", "dataType": "String"}, {"name": "cantidad_sectores", "dataType": "Integer"}, {"name": "carga_correcta", "dataType": "String"}, {"name": "AAAAMM", "dataType": "String"}, {"name": "AAAAMM_id", "dataType": "Integer"}]', 
      'sampleGroup', 
      ['idf_pers_ods'], 
      1002, 
      'firstN', 
      1, 
      [{ 'expression': { 'expression': 'ref_data_date_part' }, 'sortType': 'desc' }]
    )
  }}

),

reformat_9 AS (

  SELECT 
    idf_pers_ods AS idf_pers_ods,
    CAST(6 AS smallint) AS CodServicio,
    concat('Fecha ultimo incidente: ', fecha_incidente) AS Col1,
    concat('Producto: ', LEFT(producto_con_incidente, 40)) AS Col2,
    concat('Motivo: ', LEFT(trim(tag_motivo_incidente), 41)) AS Col3,
    concat(
      'Monto Arbitrado USD: ', 
      replace(replace(replace(format_number(monto_final_arbitrado_dolares, 2), ',', '#'), '.', ','), '#', '.')) AS Col4,
    concat(
      'Resolución: ', 
      CASE
        WHEN tipo_resolucion IS NULL or trim(tipo_resolucion) = ''
          THEN 'Pendiente'
        ELSE tipo_resolucion
      END) AS Col5
  
  FROM Sample_8 AS in0

),

reformat_10 AS (

  SELECT 
    idf_pers_ods AS idf_pers_ods,
    CAST(6 AS smallint) AS CodServicio,
    concat('Cantidad incidentes 12 meses: ', cantidad_incidentes) AS Col1,
    concat('Cantidad de fallos a favor: ', coalesce(cantidad_incidentes_a_favor, 0)) AS Col2,
    concat('Producto más afectado: ', LEFT(producto_con_incidente, 27)) AS Col3,
    concat('Cantidad del producto: ', cantidad_por_producto) AS Col4
  
  FROM join_9

),

UnionByName_1 AS (

  {{ prophecy_basics.UnionByName([], [], 'allowMissingColumns') }}

),

filter_5 AS (

  SELECT * 
  
  FROM UnionByName_1 AS in0
  
  WHERE idf_pers_ods IS NOT NULL and LEFT(idf_pers_ods, 5) = '10137'

)

SELECT *

FROM filter_5
