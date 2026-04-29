package com.kidspoint.api.auth.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * 계정 및 Kids 도메인에서 해당 사용자 행 삭제 (Apple 계정 삭제 가이드라인 대응).
 * SQL 은 MyBatis와 동일하게 스키마 생략 — JDBC URL 의 currentSchema(예: kidspoint)에 맡긴다.
 *
 * <p>PostgreSQL: 하나의 트랜잭션에서 실패한 SQL 이 있으면 그 트랜잭션 전체가 aborted 되므로,
 * 존재하지 않을 수 있는 테이블(spring_session, organization_members) 삭제는
 * {@link Propagation#NOT_SUPPORTED} 로 별도 호출해야 한다.
 */
@Service
public class AccountDeletionService {

    private final JdbcTemplate jdbcTemplate;

    public AccountDeletionService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * users 삭제까지 한 트랜잭션으로 수행. 내부에서 try/catch 로 SQL 을 삼키면 안 된다.
     */
    @Transactional
    public void deleteKidsUserAndAccount(UUID userId) {
        String uid = userId.toString();

        jdbcTemplate.update("DELETE FROM mission_logs WHERE changed_by = ?::uuid", uid);

        jdbcTemplate.update(
            "DELETE FROM mission_logs USING mission_assignments ma "
                + "WHERE mission_logs.mission_assignment_id = ma.id "
                + "AND (ma.assignee_id = ?::uuid OR ma.assigned_by = ?::uuid)",
            uid,
            uid);

        jdbcTemplate.update(
            "DELETE FROM mission_assignments WHERE assignee_id = ?::uuid OR assigned_by = ?::uuid",
            uid,
            uid);

        jdbcTemplate.update(
            "DELETE FROM mission_logs USING mission_assignments ma "
                + "WHERE mission_logs.mission_assignment_id = ma.id "
                + "AND ma.mission_id IN (SELECT id FROM missions WHERE created_by = ?::uuid)",
            uid);

        jdbcTemplate.update(
            "DELETE FROM mission_assignments WHERE mission_id IN "
                + "(SELECT id FROM missions WHERE created_by = ?::uuid)",
            uid);

        jdbcTemplate.update("DELETE FROM missions WHERE created_by = ?::uuid", uid);

        jdbcTemplate.update("DELETE FROM reward_purchases WHERE buyer_id = ?::uuid", uid);

        jdbcTemplate.update(
            "DELETE FROM reward_purchases WHERE reward_id IN "
                + "(SELECT id FROM rewards WHERE created_by = ?::uuid)",
            uid);

        jdbcTemplate.update("DELETE FROM rewards WHERE created_by = ?::uuid", uid);

        jdbcTemplate.update(
            "DELETE FROM point_transactions WHERE point_account_id IN "
                + "(SELECT id FROM point_accounts WHERE user_id = ?::uuid)",
            uid);

        jdbcTemplate.update("DELETE FROM point_accounts WHERE user_id = ?::uuid", uid);

        jdbcTemplate.update("DELETE FROM family_members WHERE user_id = ?::uuid", uid);

        jdbcTemplate.update("DELETE FROM user_push_tokens WHERE user_id = ?::uuid", uid);

        int n = jdbcTemplate.update("DELETE FROM users WHERE id = ?::uuid", uid);
        if (n == 0) {
            throw new IllegalStateException("User not found or already deleted");
        }
    }

    /** 조직 멤버 테이블이 없거나 스키마가 다른 환경 대비. 트랜잭션 없이 각각 커밋. */
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public void bestEffortDeleteOrganizationMembers(UUID userId) {
        try {
            jdbcTemplate.update(
                "DELETE FROM organization_members WHERE user_id = ?::uuid",
                userId.toString());
        } catch (Exception ignored) {
            // 테이블 없음 등
        }
    }

    /**
     * Spring Session 은 스키마가 배포마다 다를 수 있음. users 삭제 뒤 호출해도 principal_name 으로 정리 가능.
     */
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public void bestEffortDeleteSpringSessions(String principalName) {
        String[] stmts = {
            "DELETE FROM spring_session WHERE principal_name = ?",
            "DELETE FROM public.spring_session WHERE principal_name = ?",
            "DELETE FROM kidspoint.spring_session WHERE principal_name = ?",
        };
        for (String sql : stmts) {
            try {
                jdbcTemplate.update(sql, principalName);
            } catch (Exception ignored) {
                // 테이블/스키마 없음
            }
        }
    }
}
