select answers.survey_id, 0 as points_version, date(str_to_date(answers.date_survey_taken, '%d/%m/%Y')) as date_survey_taken, answers.entity_id, answers.entity_type_id,

(
case
when answers.Q1='Five or more' then 0
when answers.Q1='Four' then 5
when answers.Q1='Three' then 11
when answers.Q1='Two' then 18
when answers.Q1='One' then 28
end +
case
when answers.Q2='No formal school, primary (Class 1 - 4), or secondary (Class 5 - 8)' then 0
when answers.Q2='Vocational, complementary, apprenticeship, or lower high school (Class 9-10)' then 2
when answers.Q2='High school (Class 9-12)' then 4
when answers.Q2='Specialty post-high school, technical foreman, or university short-term (college)' then 5
when answers.Q2='University long-term' then 10
end +
case
when answers.Q3='Own system, not available, or no data' then 0
when answers.Q3='Public system' then 1
end +
case
when answers.Q4='No land-line, and no mobile' then 0
when answers.Q4='No land-line, but one mobile' then 7
when answers.Q4='One or more land-lines, but no mobile' then 9
when answers.Q4='No land-line, but two or more mobiles' then 13
when answers.Q4='One or more land-lines, and one mobile' then 16
when answers.Q4='One or more land-lines, and two or more mobiles' then 18
end +
case
when answers.Q5='No' then 0
when answers.Q5='Yes' then 3
end +
case
when answers.Q6='None' then 0
when answers.Q6='Only non-automatic' then 3
when answers.Q6='Automatic (regardless of owning non-automatic)' then 5
end +
case
when answers.Q7='None' then 0
when answers.Q7='Refrigerator only or freezer only' then 5
when answers.Q7='Refrigerator and freezer, or refrigerating combine' then 10
end +
case
when answers.Q8='No' then 0
when answers.Q8='Yes' then 5
end +
case
when answers.Q9='No' then 0
when answers.Q9='Yes' then 2
end +
case
when answers.Q10='No' then 0
when answers.Q10='Yes' then 18
end
) 
as ppi_score
from
(SELECT
qg.id as survey_id,
GROUP_CONCAT(if(q.nickname = 'ppi_romania_2009_survey_date', qgr.response, NULL)) AS 'date_survey_taken',
qgi.entity_id as entity_id,
es.entity_type_id as entity_type_id,
GROUP_CONCAT(if(q.nickname = 'ppi_romania_2009_family_members', qgr.response, NULL)) AS 'Q1',
GROUP_CONCAT(if(q.nickname = 'ppi_romania_2009_education_level', qgr.response, NULL)) AS 'Q2',
GROUP_CONCAT(if(q.nickname = 'ppi_romania_2009_sewage_system', qgr.response, NULL)) AS 'Q3',
GROUP_CONCAT(if(q.nickname = 'ppi_romania_2009_phones', qgr.response, NULL)) AS 'Q4',
GROUP_CONCAT(if(q.nickname = 'ppi_romania_2009_gas_stoves', qgr.response, NULL)) AS 'Q5',
GROUP_CONCAT(if(q.nickname = 'ppi_romania_2009_washing_machine_type', qgr.response, NULL)) AS 'Q6',
GROUP_CONCAT(if(q.nickname = 'ppi_romania_2009_refrigerator_type', qgr.response, NULL)) AS 'Q7',
GROUP_CONCAT(if(q.nickname = 'ppi_romania_2009_owns_color_television', qgr.response, NULL)) AS 'Q8',
GROUP_CONCAT(if(q.nickname = 'ppi_romania_2009_owns_radio', qgr.response, NULL)) AS 'Q9',
GROUP_CONCAT(if(q.nickname = 'ppi_romania_2009_owns_car', qgr.response, NULL)) AS 'Q10'
FROM question_group_response qgr, question_group_instance qgi, question_group qg, sections_questions sq, questions q, event_sources es
WHERE qgr.question_group_instance_id = qgi.id and qgr.sections_questions_id = sq.id and sq.question_id = q.question_id and qgi.question_group_id = qg.id and qg.title="PPI Romania 2009" and qgi.event_source_id = es.id
GROUP BY question_group_instance_id) as answers