package com.kidspoint.api.subscription.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;

public class CreatePaymentRequest {
    @NotNull(message = "Organization ID is required")
    private String organizationId;

    @NotBlank(message = "Payment provider is required")
    private String paymentProvider; // "toss", "iamport", "stripe" 등

    @NotBlank(message = "Payment method is required")
    private String paymentMethod; // "card", "bank_transfer" 등

    @Positive(message = "Amount must be positive")
    private BigDecimal amount;

    @NotBlank(message = "Payment ID from provider is required")
    private String providerPaymentId; // 결제 프로바이더에서 받은 결제 ID

    private String customerId; // 결제 프로바이더의 고객 ID (선택)

    // Getters and Setters
    public String getOrganizationId() {
        return organizationId;
    }

    public void setOrganizationId(String organizationId) {
        this.organizationId = organizationId;
    }

    public String getPaymentProvider() {
        return paymentProvider;
    }

    public void setPaymentProvider(String paymentProvider) {
        this.paymentProvider = paymentProvider;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getProviderPaymentId() {
        return providerPaymentId;
    }

    public void setProviderPaymentId(String providerPaymentId) {
        this.providerPaymentId = providerPaymentId;
    }

    public String getCustomerId() {
        return customerId;
    }

    public void setCustomerId(String customerId) {
        this.customerId = customerId;
    }
}
