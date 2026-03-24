package com.example.medichain.dto;

import java.math.BigInteger;

public class BatchResponse {

    private final String batchId;
    private final String currentOwner;
    private final BigInteger createdAt;
    private final String metadataHash;
    private final String state;

    public BatchResponse(
            String batchId,
            String currentOwner,
            BigInteger createdAt,
            String metadataHash,
            String state) {
        this.batchId = batchId;
        this.currentOwner = currentOwner;
        this.createdAt = createdAt;
        this.metadataHash = metadataHash;
        this.state = state;
    }

    public String getBatchId() {
        return batchId;
    }

    public String getCurrentOwner() {
        return currentOwner;
    }

    public BigInteger getCreatedAt() {
        return createdAt;
    }

    public String getMetadataHash() {
        return metadataHash;
    }

    public String getState() {
        return state;
    }
}
