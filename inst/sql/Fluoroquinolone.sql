CREATE TABLE #Codesets (
  codeset_id int NOT NULL,
  concept_id bigint NOT NULL
)
;

INSERT INTO #Codesets (codeset_id, concept_id)
SELECT 0 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
(
  select concept_id from @vocabulary_database_schema.CONCEPT where concept_id in (1797513,1707800,923081,1789276,1716721,1716903,1742253,1721543,19027679,43009011,43009033,43009038,21603009,21603008,21603013,21603022,21603014,21603021,21603019,21603010,715910)
UNION  select c.concept_id
  from @vocabulary_database_schema.CONCEPT c
  join @vocabulary_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (1797513,1707800,923081,1789276,1716721,1716903,1742253,1721543,19027679,43009011,43009033,43009038,21603009,21603008,21603013,21603022,21603014,21603021,21603019,21603010,715910)
  and c.invalid_reason is null

) I
LEFT JOIN
(
  select concept_id from @vocabulary_database_schema.CONCEPT where concept_id in (42629035,42479725,43258666,42948145,42948147,36217286,40028359,36217287,40028361,36217289,36217292,40160496,36249233,36222576,36227395,40069655,36227393,40069651,43695029,40890877,44183167,42952942,41144210,36215651,35858962,36221026,40001157,40028720,40059318,40059607,40057467,40066893,2068131,36158979,40028718,40066892,42961482,43534856,43534858,43534862,43534858,21605196,21605161,21605162,36213853,43534857,36225035,43534859,35144130,35860990,43534860)
UNION  select c.concept_id
  from @vocabulary_database_schema.CONCEPT c
  join @vocabulary_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (42629035,42479725,43258666,42948145,42948147,36217286,40028359,36217287,40028361,36217289,36217292,40160496,36249233,36222576,36227395,40069655,36227393,40069651,43695029,40890877,44183167,42952942,41144210,36215651,35858962,36221026,40001157,40028720,40059318,40059607,40057467,40066893,2068131,36158979,40028718,40066892,42961482,43534856,43534858,43534862,43534858,21605196,21605161,21605162,36213853,43534857,36225035,43534859,35144130,35860990,43534860)
  and c.invalid_reason is null

) E ON I.concept_id = E.concept_id
WHERE E.concept_id is null
) C
;

DELETE FROM @target_database_schema.@target_cohort_table where cohort_definition_id = @target_cohort_id;
INSERT INTO @target_database_schema.@target_cohort_table (cohort_definition_id, subject_id, cohort_start_date, cohort_end_date)
select @target_cohort_id as cohort_definition_id, d.person_id, d.drug_exposure_start_date, d.drug_exposure_end_date FROM @cdm_database_schema.DRUG_EXPOSURE d INNER JOIN #Codesets cs on d.drug_concept_id = cs.concept_id;

TRUNCATE TABLE #Codesets;
DROP TABLE #Codesets;
