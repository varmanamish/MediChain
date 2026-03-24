package com.example.medichain.dto;

import jakarta.validation.constraints.NotBlank;

public class VerifyBatchRequest {

    @NotBlank
    private String batchId;

    @NotBlank
    private String metadataHash;

    public String getBatchId() {
        return batchId;
    }

    public void setBatchId(String batchId) {
        this.batchId = batchId;
    }

    public String getMetadataHash() {
        return metadataHash;
    }

    public void setMetadataHash(String metadataHash) {
        this.metadataHash = metadataHash;
    }
}
