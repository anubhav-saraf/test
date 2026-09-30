WITH static_rows AS (

  SELECT
    1 AS id,
    "abc" AS name

),

FindDuplicates_1 AS (

  {{
    prophecy_basics.FindDuplicates(
      ['static_rows'],
      [],
      '',
      'unique',
      '',
      '',
      '',
      'allCols',
      ['id', 'name'],
      []
    )
  }}

),

RecordID_1 AS (

  {{
    prophecy_basics.RecordID(
      ['FindDuplicates_1'],
      'incremental_id',
      'RecordID',
      'string',
      6,
      1000,
      'tableLevel',
      'first_column',
      [],
      []
    )
  }}

)

SELECT *

FROM RecordID_1
