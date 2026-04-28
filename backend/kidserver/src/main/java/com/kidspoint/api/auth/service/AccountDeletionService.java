package com.kidspoint.api.auth.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * 계정 및 Kids 도메인에서 해당 사용자 행 삭제 (Apple 계정 삭제 가이드라인 대응).
 */
@Service
public class AccountDeletionService {

    private final JdbcTemplate jdbcTemplate;

    public AccountDeletionService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Transactional
    public void deleteKidsUserAndAccount(UUID userId) {
        jdbcTemplate.update(
            "DELETE FROM kidspoint.mission_logs WHERE changed_by = ?::uuid",
            userId.toString());

        // 미션 로그 → 할당(사용자 관련) → 사용자가 생성한 미션 등
        jdbcTemplate.update(
            "DELETE FROM kidspoint.mission_logs USING kidspoint.mission_assignments ma "
                + "WHERE mission_logs.mission_assignment_id = ma.id "
                + "AND (ma.assignee_id = ?::uuid OR ma.assigned_by = ?::uuid)",
            userId.toString(),
            userId.toString());

        jdbcTemplate.update(
            "DELETE FROM kidspoint.mission_assignments WHERE assignee_id = ?::uuid OR assigned_by = ?::uuid",
            userId.toString(),
            userId.toString());

        jdbcTemplate.update(
            "DELETE FROM kidspoint.mission_logs USING kidspoint.mission_assignments ma "
                + "WHERE mission_logs.mission_assignment_id = ma.id "
                + "AND ma.mission_id IN (SELECT id FROM kidspoint.missions WHERE created_by = ?::uuid)",
            userId.toString());

        jdbcTemplate.update(
            "DELETE FROM kidspoint.mission_assignments WHERE mission_id IN "
                + "(SELECT id FROM kidspoint.missions WHERE created_by = ?::uuid)",
            userId.toString());

        jdbcTemplate.update(
            "DELETE FROM kidspoint.missions WHERE created_by = ?::uuid",
            userId.toString());

        jdbcTemplate.update(
            "DELETE FROM kidspoint.reward_purchases WHERE buyer_id = ?::uuid",
            userId.toString());

        jdbcTemplate.update("DELETE FROM kidspoint.rewards WHERE created_by = ?::uuid", userId.toString());

        jdbcTemplate.update(
            "DELETE FROM kidspoint.point_transactions WHERE point_account_id IN "
                + "(SELECT id FROM kidspoint.point_accounts WHERE user_id = ?::uuid)",
            userId.toString());

        jdbcTemplate.update("DELETE FROM kidspoint.point_accounts WHERE user_id = ?::uuid", userId.toString());

        jdbcTemplate.update(
            "DELETE FROM kidspoint.family_members WHERE user_id = ?::uuid",
            userId.toString());

        jdbcTemplate.update(
            "DELETE FROM kidspoint.user_push_tokens WHERE user_id = ?::uuid",
            userId.toString());

        try {
            jdbcTemplate.update(
                "DELETE FROM public.spring_session WHERE principal_name = ?",
                userId.toString());
        } catch (Exception ignored) {
            // 세션 테이블이 없거나 스키마가 다른 환경은 무시
        }

        int n = jdbcTemplate.update("DELETE FROM kidspoint.users WHERE id = ?::uuid", userId.toString());
        if (n == 0) {
            throw new IllegalStateException("User not found or already deleted");
        }
    }
}
