package com.example.medichain.dto;

public class VerifyBatchResponse {

    private final boolean valid;
    private final TransactionResponse transaction;

    public VerifyBatchResponse(boolean valid, TransactionResponse transaction) {
        this.valid = valid;
        this.transaction = transaction;
    }

    public boolean isValid() {
        return valid;
    }

    public TransactionResponse getTransaction() {
        return transaction;
    }
}
