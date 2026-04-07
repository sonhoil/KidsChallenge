package com.kidspoint.api.subscription.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class VerifyIAPRequest {
    @NotBlank(message = "Organization ID is required")
    private String organizationId;

    @NotBlank(message = "Receipt or purchase token is required")
    private String receipt; // Android: purchaseToken, iOS: receipt data

    private String purchaseToken; // Android 전용

    @NotBlank(message = "Transaction ID is required")
    private String transactionId;

    @NotBlank(message = "Platform is required")
    private String platform; // "android" or "ios"

    @NotBlank(message = "Product ID is required")
    private String productId;

    // Getters and Setters
    public String getOrganizationId() {
        return organizationId;
    }

    public void setOrganizationId(String organizationId) {
        this.organizationId = organizationId;
    }

    public String getReceipt() {
        return receipt;
    }

    public void setReceipt(String receipt) {
        this.receipt = receipt;
    }

    public String getPurchaseToken() {
        return purchaseToken;
    }

    public void setPurchaseToken(String purchaseToken) {
        this.purchaseToken = purchaseToken;
    }

    public String getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(String transactionId) {
        this.transactionId = transactionId;
    }

    public String getPlatform() {
        return platform;
    }

    public void setPlatform(String platform) {
        this.platform = platform;
    }

    public String getProductId() {
        return productId;
    }

    public void setProductId(String productId) {
        this.productId = productId;
    }
}
