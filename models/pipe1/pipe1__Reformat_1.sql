{{
  config({    
    "materialized": "ephemeral",
    "database": "anubhav",
    "schema": "default"
  })
}}

WITH static_id_and_name AS (

  {#Provides a fixed default record (id=1, name='abc') to serve as a stable reference or fallback label in reports and joins.#}
  SELECT 
    1 AS id,
    "abc" AS name,
    "addr_1" AS address,
    23 AS val

),

Reformat_1 AS (

  SELECT * 
  
  FROM static_id_and_name AS in0

)

SELECT *

FROM Reformat_1
