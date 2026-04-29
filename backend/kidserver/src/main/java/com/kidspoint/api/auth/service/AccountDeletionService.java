package com.kidspoint.api.auth.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * 계정 및 Kids 도메인에서 해당 사용자 행 삭제 (Apple 계정 삭제 가이드라인 대응).
 * SQL 은 MyBatis와 동일하게 스키마 생략 — JDBC URL 의 currentSchema(예: kidspoint)에 맡긴다.
 */
@Service
public class AccountDeletionService {

    private final JdbcTemplate jdbcTemplate;

    public AccountDeletionService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

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

        // rewards 삭제 전 해당 리워드의 모든 구매 행 제거 (프로덕션 FK 가 RESTRICT 인 경우 대비)
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

        deleteSpringSessionsForPrincipal(uid);

        try {
            jdbcTemplate.update("DELETE FROM organization_members WHERE user_id = ?::uuid", uid);
        } catch (Exception ignored) {
            // boxsage/조직 도메인 미사용 환경
        }

        int n = jdbcTemplate.update("DELETE FROM users WHERE id = ?::uuid", uid);
        if (n == 0) {
            throw new IllegalStateException("User not found or already deleted");
        }
    }

    /**
     * Spring Session JDBC 테이블 스키마가 배포마다 public / kidspoint 등으로 달라질 수 있어 모두 시도한다.
     */
    private void deleteSpringSessionsForPrincipal(String principalName) {
        String[] stmts = {
            "DELETE FROM spring_session WHERE principal_name = ?",
            "DELETE FROM public.spring_session WHERE principal_name = ?",
            "DELETE FROM kidspoint.spring_session WHERE principal_name = ?",
        };
        for (String sql : stmts) {
            try {
                jdbcTemplate.update(sql, principalName);
            } catch (Exception ignored) {
                // 해당 스키마에 테이블 없음 등
            }
        }
    }
}
