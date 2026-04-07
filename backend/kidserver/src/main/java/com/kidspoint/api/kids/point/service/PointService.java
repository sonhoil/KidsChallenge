package com.kidspoint.api.kids.point.service;

import com.kidspoint.api.kids.point.domain.PointAccount;
import com.kidspoint.api.kids.point.domain.PointTransaction;
import com.kidspoint.api.kids.point.mapper.PointAccountMapper;
import com.kidspoint.api.kids.point.mapper.PointTransactionMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@Transactional
public class PointService {

    private final PointAccountMapper pointAccountMapper;
    private final PointTransactionMapper pointTransactionMapper;

    @Autowired
    public PointService(PointAccountMapper pointAccountMapper, PointTransactionMapper pointTransactionMapper) {
        this.pointAccountMapper = pointAccountMapper;
        this.pointTransactionMapper = pointTransactionMapper;
    }

    /**
     * 포인트를 추가합니다 (적립)
     */
    public void addPoints(UUID familyId, UUID userId, Integer amount, String type, 
                          String referenceType, UUID referenceId, String description) {
        if (amount == null || amount <= 0) {
            throw new IllegalArgumentException("Amount must be positive");
        }

        PointAccount account = getOrCreateAccount(familyId, userId);
        account.setBalance(account.getBalance() + amount);
        account.setUpdatedAt(Instant.now());
        pointAccountMapper.update(account);

        // 트랜잭션 기록
        PointTransaction transaction = new PointTransaction();
        transaction.setPointAccountId(account.getId());
        transaction.setAmount(amount);
        transaction.setType(type);
        transaction.setReferenceType(referenceType);
        transaction.setReferenceId(referenceId);
        transaction.setDescription(description);
        transaction.setCreatedAt(Instant.now());
        pointTransactionMapper.insert(transaction);
    }

    /**
     * 포인트를 차감합니다 (사용)
     */
    public void deductPoints(UUID familyId, UUID userId, Integer amount, String type,
                             String referenceType, UUID referenceId, String description) {
        if (amount == null || amount <= 0) {
            throw new IllegalArgumentException("Amount must be positive");
        }

        PointAccount account = getOrCreateAccount(familyId, userId);
        if (account.getBalance() < amount) {
            throw new IllegalStateException("Insufficient points");
        }

        account.setBalance(account.getBalance() - amount);
        account.setUpdatedAt(Instant.now());
        pointAccountMapper.update(account);

        // 트랜잭션 기록 (음수로 저장)
        PointTransaction transaction = new PointTransaction();
        transaction.setPointAccountId(account.getId());
        transaction.setAmount(-amount);
        transaction.setType(type);
        transaction.setReferenceType(referenceType);
        transaction.setReferenceId(referenceId);
        transaction.setDescription(description);
        transaction.setCreatedAt(Instant.now());
        pointTransactionMapper.insert(transaction);
    }

    /**
     * 포인트 계좌를 조회하거나 없으면 생성합니다
     */
    public PointAccount getOrCreateAccount(UUID familyId, UUID userId) {
        PointAccount account = pointAccountMapper.selectByFamilyAndUser(familyId, userId);
        if (account == null) {
            account = new PointAccount();
            account.setId(UUID.randomUUID());
            account.setFamilyId(familyId);
            account.setUserId(userId);
            account.setBalance(0);
            account.setCreatedAt(Instant.now());
            account.setUpdatedAt(Instant.now());
            pointAccountMapper.insert(account);
        }
        return account;
    }

    /**
     * 현재 포인트 잔액을 조회합니다
     */
    public Integer getBalance(UUID familyId, UUID userId) {
        PointAccount account = getOrCreateAccount(familyId, userId);
        return account.getBalance();
    }
}
