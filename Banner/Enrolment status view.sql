CREATE OR REPLACE VIEW OXBR_INTDEV.OXBR_ENROL_STATUS_CODES_V
(PIDM,ENROLMENT_TERM,ACADEMIC_ENROLMENT_STATUS,FINANCIAL_ENROLMENT_STATUS,OVERALL_ENROLMENT_STATUS,STUDY_PATHS)
AS
(
	SELECT
			 a.sgbstdn_PIDM
			,enrol.enrol_term
			 -- Academic enrolment status
			,oxbr_enrolment.get_enrolment_status_code(
										 MIN(d.sfbetrm_ESTS_CODE)
										,MAX(NVL(c.sfrensp_ESTS_CODE,' '))
										,MAX(szrenrl_ACADEMIC_ENROL_STATUS)
										,CASE WHEN MAX(sprhold_PIDM) IS NOT NULL THEN 1 ELSE 0 END
										,COUNT(*)
										,'OP'
									  )
			 -- Financial enrolment status
			,oxbr_enrolment.get_enrolment_status_code(
										 MIN(d.sfbetrm_ESTS_CODE)
										,MAX(NVL(c.sfrensp_ESTS_CODE,' '))
										,MAX(szrenrl_FINANCIAL_ENROL_STATUS)
										,CASE WHEN MAX(sprhold_PIDM) IS NOT NULL THEN 1 ELSE 0 END
										,COUNT(*)
									  )
			 -- Overall enrolment status
			,oxbr_enrolment.get_enrolment_status_code(
										 MIN(d.sfbetrm_ESTS_CODE)
										,MAX(NVL(c.sfrensp_ESTS_CODE,' '))
										,MAX(szrenrl_OVERALL_ENROL_STATUS)
										,CASE WHEN MAX(sprhold_PIDM) IS NOT NULL THEN 1 ELSE 0 END
										,COUNT(*)
									  )
			 -- Study paths
			,CASE
				WHEN MAX(szrenrl_STUDY_PATHS) IS NULL THEN LISTAGG(c.sfrensp_KEY_SEQNO, ',') WITHIN GROUP (ORDER BY c.sfrensp_KEY_SEQNO)
				ELSE MAX(szrenrl_STUDY_PATHS)
			 END
	FROM
		sgbstdn a
		JOIN (
			SELECT 
				oxbr_enrolment.get_enrolment_term as enrol_term 
			FROM dual
			) enrol
			ON 1=1
		JOIN sorlcur ON
				sorlcur_PIDM			= a.sgbstdn_PIDM
			AND sorlcur_LMOD_CODE		= 'LEARNER'
			AND sorlcur_CACT_CODE		= 'ACTIVE'
			AND sorlcur_CURRENT_CDE		= 'Y'
			AND sorlcur_TERM_CODE_END	IS NULL
		JOIN sgrstsp s ON 
				s.sgrstsp_PIDM			= sorlcur_PIDM
			AND s.sgrstsp_KEY_SEQNO		= sorlcur_KEY_SEQNO
			AND s.sgrstsp_STSP_CODE		= 'AS'
			AND s.sgrstsp_TERM_CODE_EFF	= (
											SELECT
												MAX(t.sgrstsp_TERM_CODE_EFF)
											FROM
												sgrstsp t
											WHERE
														t.sgrstsp_PIDM			= s.sgrstsp_PIDM
													AND t.sgrstsp_KEY_SEQNO		= s.sgrstsp_KEY_SEQNO
													AND t.sgrstsp_TERM_CODE_EFF	<= enrol.enrol_term
										)
		LEFT OUTER JOIN szrenrl ON
				szrenrl_PIDM            = a.sgbstdn_PIDM
			AND szrenrl_TERM_CODE       = enrol.enrol_term
		-- This join used to get study paths which are "EL" for the current term
		LEFT OUTER JOIN sfrensp c ON
				c.sfrensp_PIDM			= a.sgbstdn_PIDM
			AND c.sfrensp_TERM_CODE		= enrol.enrol_term
			AND c.sfrensp_ESTS_CODE		= 'EL'
			AND	c.sfrensp_KEY_SEQNO		= sorlcur_KEY_SEQNO
		-- This join used to get Banner enrolment status for the current term, if it is "EL" or "EN"
		LEFT OUTER JOIN sfbetrm d ON
				d.sfbetrm_PIDM			= a.sgbstdn_PIDM
			AND d.sfbetrm_TERM_CODE		= enrol.enrol_term
			AND d.sfbetrm_ESTS_CODE     IN ('EL','EN')
		LEFT OUTER JOIN (
							SELECT
								sprhold_PIDM
							FROM
								sprhold
							WHERE
									TRUNC(NVL(sprhold_TO_DATE,SYSDATE+1)) > TRUNC(SYSDATE)
								AND	EXISTS (
									SELECT
										1
									FROM
										stvhldd
									WHERE
											sprhold_HLDD_CODE	= stvhldd_CODE
										AND	stvhldd_VR_MSG_NO	= 1
								)
						) ON sprhold_PIDM = a.sgbstdn_PIDM
	WHERE
			a.sgbstdn_STST_CODE		= 'AS'
		AND	a.sgbstdn_TERM_CODE_EFF	= (	SELECT
											MAX(b.sgbstdn_TERM_CODE_EFF)
										FROM
											sgbstdn b
										WHERE
												b.sgbstdn_PIDM			= a.sgbstdn_PIDM
											AND	b.sgbstdn_TERM_CODE_EFF	<= enrol.enrol_term
									)
	GROUP BY
		a.sgbstdn_PIDM, enrol.enrol_term
)