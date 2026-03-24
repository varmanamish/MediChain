package com.example.medichain.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.math.BigInteger;

public class ProductRequest {

    @NotBlank(message = "Product ID is required")
    private String productId;

    @NotNull(message = "Manufacture date is required")
    @Positive(message = "Manufacture date must be a valid timestamp")
    private BigInteger manufactureDate;

    @NotNull(message = "Expiry date is required")
    @Positive(message = "Expiry date must be a valid timestamp")
    private BigInteger expiryDate;

    public ProductRequest() {}

    public ProductRequest(String productId,
                          BigInteger manufactureDate,
                          BigInteger expiryDate) {
        this.productId = productId;
        this.manufactureDate = manufactureDate;
        this.expiryDate = expiryDate;
    }

    public String getProductId() {
        return productId;
    }

    public BigInteger getManufactureDate() {
        return manufactureDate;
    }

    public BigInteger getExpiryDate() {
        return expiryDate;
    }

    public void setProductId(String productId) {
        this.productId = productId;
    }

    public void setManufactureDate(BigInteger manufactureDate) {
        this.manufactureDate = manufactureDate;
    }

    public void setExpiryDate(BigInteger expiryDate) {
        this.expiryDate = expiryDate;
    }
}
