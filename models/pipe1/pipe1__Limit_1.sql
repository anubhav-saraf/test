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
    "abc" AS name

),

Reformat_1 AS (

  SELECT * 
  
  FROM static_id_and_name AS in0

),

Reformat_2 AS (

  SELECT * 
  
  FROM Reformat_1 AS in0

),

Limit_1 AS (

  SELECT * 
  
  FROM Reformat_2 AS in0
  
  LIMIT 10

)

SELECT *

FROM Limit_1
