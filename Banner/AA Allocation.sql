t1.aa_ratio =
(select max(a2.aa_ratio) as max_ratio
         from academic_advisers a2
         where a2.aa_programme = sorlcur_program)
AND sorlcur_term_code_admit = :term
AND sorlcur_pidm = :pidm
--AND sorlcur_pidm in (SELECT aa_pop_pidm FROM aa_pop)
;

SELECT * FROM smrprle;