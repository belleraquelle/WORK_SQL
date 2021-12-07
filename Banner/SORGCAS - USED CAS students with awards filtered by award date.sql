SELECT DISTINCT
    spriden_id,
    skricas.*
FROM 
    skricas
    JOIN spriden ON spriden_pidm = skricas_pidm AND spriden_change_ind IS NULL
    JOIN sorlcur learnerSorlcur ON skricas_pidm = learnerSorlcur.sorlcur_pidm 
        AND learnerSorlcur.sorlcur_seqno = skricas_lcur_seqno AND learnerSorlcur.sorlcur_lmod_code = 'LEARNER'
    JOIN shrdgmr ON learnerSorlcur.sorlcur_pidm = shrdgmr_pidm AND learnerSorlcur.sorlcur_key_seqno = shrdgmr_stsp_key_sequence 
WHERE
    1=1
    AND shrdgmr_degs_code = 'AW'
    AND shrdgmr_grad_date >= '01-AUG-2021'
    AND skricas_cas_status = 'USED'
    AND skricas_study_eligibility IS NOT NULL
    --AND skricas_grad_cas_batch_type IS NULL
    --AND skricas_pidm = '1328072'
    --AND spriden_id = '18002311'
    ;

  
UPDATE skricas
SET skricas_study_eligibility = 'Tier 1 - Entry into the UK', skricas_study_eligibility_date = skricas_visa_start_dt
  WHERE skricas_pidm||skricas_application_id IN (
    SELECT 
        skricas_pidm || skricas_application_id
    FROM 
        skricas
        JOIN spriden ON spriden_pidm = skricas_pidm AND spriden_change_ind IS NULL
        JOIN sorlcur learnerSorlcur ON skricas_pidm = learnerSorlcur.sorlcur_pidm 
            AND learnerSorlcur.sorlcur_seqno = skricas_lcur_seqno AND learnerSorlcur.sorlcur_lmod_code = 'LEARNER'
        JOIN shrdgmr ON learnerSorlcur.sorlcur_pidm = shrdgmr_pidm AND learnerSorlcur.sorlcur_key_seqno = shrdgmr_stsp_key_sequence 
    WHERE
        1=1
        AND shrdgmr_degs_code = 'AW'
        AND shrdgmr_grad_date >= '01-AUG-2021'
        AND skricas_cas_status = 'USED'
        AND skricas_study_eligibility IS NULL
)
  ;