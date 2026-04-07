package com.kidspoint.api.subscription.domain;

import java.time.Instant;
import java.util.UUID;

public class Subscription {
    private UUID id;
    private UUID organizationId;
    private String paymentProvider; // "toss", "iamport", "stripe" 등
    private String paymentId; // 결제 프로바이더의 결제 ID
    private String customerId; // 결제 프로바이더의 고객 ID
    private Status status;
    private Instant currentPeriodStart;
    private Instant currentPeriodEnd;
    private Instant trialEnd;
    private Instant createdAt;
    private Instant updatedAt;

    public enum Status {
        active, canceled, trial, past_due
    }

    // Constructors
    public Subscription() {
    }

    public Subscription(UUID id, UUID organizationId, String paymentProvider, Status status) {
        this.id = id;
        this.organizationId = organizationId;
        this.paymentProvider = paymentProvider;
        this.status = status;
    }

    // Getters and Setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getOrganizationId() {
        return organizationId;
    }

    public void setOrganizationId(UUID organizationId) {
        this.organizationId = organizationId;
    }

    public String getPaymentProvider() {
        return paymentProvider;
    }

    public void setPaymentProvider(String paymentProvider) {
        this.paymentProvider = paymentProvider;
    }

    public String getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(String paymentId) {
        this.paymentId = paymentId;
    }

    public String getCustomerId() {
        return customerId;
    }

    public void setCustomerId(String customerId) {
        this.customerId = customerId;
    }

    public Status getStatus() {
        return status;
    }

    public void setStatus(Status status) {
        this.status = status;
    }

    public Instant getCurrentPeriodStart() {
        return currentPeriodStart;
    }

    public void setCurrentPeriodStart(Instant currentPeriodStart) {
        this.currentPeriodStart = currentPeriodStart;
    }

    public Instant getCurrentPeriodEnd() {
        return currentPeriodEnd;
    }

    public void setCurrentPeriodEnd(Instant currentPeriodEnd) {
        this.currentPeriodEnd = currentPeriodEnd;
    }

    public Instant getTrialEnd() {
        return trialEnd;
    }

    public void setTrialEnd(Instant trialEnd) {
        this.trialEnd = trialEnd;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }
}
