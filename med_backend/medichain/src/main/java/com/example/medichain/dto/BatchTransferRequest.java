package com.example.medichain.dto;

import jakarta.validation.constraints.NotBlank;

public class BatchTransferRequest {

    @NotBlank
    private String batchId;

    @NotBlank
    private String to;

    public String getBatchId() {
        return batchId;
    }

    public void setBatchId(String batchId) {
        this.batchId = batchId;
    }

    public String getTo() {
        return to;
    }

    public void setTo(String to) {
        this.to = to;
    }
}
