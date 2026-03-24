package com.example.medichain.controller;

import com.example.medichain.dto.BatchCreateRequest;
import com.example.medichain.dto.BatchResponse;
import com.example.medichain.dto.BatchTransferRequest;
import com.example.medichain.dto.OwnershipRecordResponse;
import com.example.medichain.dto.TransactionResponse;
import com.example.medichain.dto.VerifyBatchRequest;
import com.example.medichain.dto.VerifyBatchResponse;
import com.example.medichain.service.SupplyChainService;
import com.example.medichain.util.Bytes32Util;
import jakarta.validation.Valid;
import java.math.BigInteger;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.web3j.protocol.core.methods.response.Log;
import org.web3j.protocol.core.methods.response.TransactionReceipt;

@RestController
@RequestMapping("/api/supply-chain")
@Validated
public class SupplyChainController {

    private final SupplyChainService supplyChainService;

    public SupplyChainController(SupplyChainService supplyChainService) {
        this.supplyChainService = supplyChainService;
    }

    @PostMapping("/batches")
    public ResponseEntity<TransactionResponse> createBatch(@Valid @RequestBody BatchCreateRequest request)
            throws Exception {
        TransactionReceipt receipt = supplyChainService.createBatch(
                Bytes32Util.fromHexString(request.getBatchId()),
                Bytes32Util.fromHexString(request.getMetadataHash()));
        return ResponseEntity.ok(toResponse(receipt));
    }

    @PostMapping("/batches/transfer")
    public ResponseEntity<TransactionResponse> transferBatch(@Valid @RequestBody BatchTransferRequest request)
            throws Exception {
        TransactionReceipt receipt = supplyChainService.transferBatch(
                Bytes32Util.fromHexString(request.getBatchId()),
                request.getTo());
        return ResponseEntity.ok(toResponse(receipt));
    }

    @PostMapping("/batches/verify")
    public ResponseEntity<VerifyBatchResponse> verifyBatch(@Valid @RequestBody VerifyBatchRequest request)
            throws Exception {
        byte[] batchId = Bytes32Util.fromHexString(request.getBatchId());
        byte[] metadataHash = Bytes32Util.fromHexString(request.getMetadataHash());

        boolean isValid = supplyChainService.verifyBatchReadOnly(batchId, metadataHash);
        TransactionReceipt receipt = supplyChainService.verifyBatchTx(batchId, metadataHash);

        return ResponseEntity.ok(new VerifyBatchResponse(isValid, toResponse(receipt)));
    }

    @GetMapping("/batches/{batchId}")
    public ResponseEntity<BatchResponse> getBatch(@PathVariable String batchId) throws Exception {
        return ResponseEntity.ok(supplyChainService.getBatch(Bytes32Util.fromHexString(batchId)));
    }

    @GetMapping("/batches/{batchId}/history")
    public ResponseEntity<BigInteger> getHistoryLength(@PathVariable String batchId) throws Exception {
        return ResponseEntity.ok(
                supplyChainService.getOwnershipHistoryLength(Bytes32Util.fromHexString(batchId)));
    }

    @GetMapping("/batches/{batchId}/history/{index}")
    public ResponseEntity<OwnershipRecordResponse> getHistoryRecord(
            @PathVariable String batchId,
            @PathVariable BigInteger index) throws Exception {
        return ResponseEntity.ok(
                supplyChainService.getOwnershipRecord(Bytes32Util.fromHexString(batchId), index));
    }

    private TransactionResponse toResponse(TransactionReceipt receipt) {
        List<String> logs = receipt.getLogs().stream().map(Log::getData).toList();
        return new TransactionResponse(
                receipt.getTransactionHash(),
                receipt.getBlockNumber(),
                receipt.getGasUsed(),
                receipt.getStatus(),
                logs);
    }
}
