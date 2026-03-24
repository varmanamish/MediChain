package com.example.medichain.service;

import com.example.medichain.config.BlockchainProperties;
import com.example.medichain.dto.BatchResponse;
import com.example.medichain.dto.OwnershipRecordResponse;
import java.math.BigInteger;
import java.util.List;
import org.springframework.stereotype.Service;
import org.web3j.abi.FunctionEncoder;
import org.web3j.abi.FunctionReturnDecoder;
import org.web3j.abi.TypeReference;
import org.web3j.abi.datatypes.Address;
import org.web3j.abi.datatypes.Function;
import org.web3j.abi.datatypes.Type;
import org.web3j.abi.datatypes.generated.Bytes32;
import org.web3j.abi.datatypes.generated.Uint256;
import org.web3j.abi.datatypes.generated.Uint8;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.DefaultBlockParameterName;
import org.web3j.protocol.core.methods.request.Transaction;
import org.web3j.protocol.core.methods.response.EthCall;
import org.web3j.protocol.core.methods.response.EthSendTransaction;
import org.web3j.protocol.core.methods.response.TransactionReceipt;
import org.web3j.tx.TransactionManager;
import org.web3j.tx.response.TransactionReceiptProcessor;
import org.web3j.utils.Numeric;

@Service
public class SupplyChainService {

    private final Web3j web3j;
    private final TransactionManager transactionManager;
    private final TransactionReceiptProcessor receiptProcessor;
    private final BlockchainProperties properties;

    public SupplyChainService(
            Web3j web3j,
            TransactionManager transactionManager,
            TransactionReceiptProcessor receiptProcessor,
            BlockchainProperties properties) {
        this.web3j = web3j;
        this.transactionManager = transactionManager;
        this.receiptProcessor = receiptProcessor;
        this.properties = properties;
    }

    public TransactionReceipt createBatch(byte[] batchId, byte[] metadataHash) throws Exception {
        Function function = new Function(
                "createBatch",
                List.of(new Bytes32(batchId), new Bytes32(metadataHash)),
                List.of());
        return sendTransaction(function);
    }

    public TransactionReceipt transferBatch(byte[] batchId, String to) throws Exception {
        Function function = new Function(
                "transferBatch",
                List.of(new Bytes32(batchId), new Address(to)),
                List.of());
        return sendTransaction(function);
    }

    public boolean verifyBatchReadOnly(byte[] batchId, byte[] metadataHash) throws Exception {
        Function function = new Function(
                "verifyBatch",
                List.of(new Bytes32(batchId), new Bytes32(metadataHash)),
                List.of(new TypeReference<org.web3j.abi.datatypes.Bool>() {}));
        List<Type> decoded = call(function);
        if (decoded.isEmpty()) {
            return false;
        }
        return (boolean) decoded.get(0).getValue();
    }

    public TransactionReceipt verifyBatchTx(byte[] batchId, byte[] metadataHash) throws Exception {
        Function function = new Function(
                "verifyBatch",
                List.of(new Bytes32(batchId), new Bytes32(metadataHash)),
                List.of());
        return sendTransaction(function);
    }

    public BatchResponse getBatch(byte[] batchId) throws Exception {
        Function function = new Function(
                "getBatch",
                List.of(new Bytes32(batchId)),
                List.of(
                        new TypeReference<Bytes32>() {},
                        new TypeReference<Address>() {},
                        new TypeReference<Uint256>() {},
                        new TypeReference<Bytes32>() {},
                        new TypeReference<Uint8>() {}
                ));

        List<Type> decoded = call(function);
        Bytes32 id = (Bytes32) decoded.get(0);
        Address owner = (Address) decoded.get(1);
        Uint256 createdAt = (Uint256) decoded.get(2);
        Bytes32 metadata = (Bytes32) decoded.get(3);
        Uint8 state = (Uint8) decoded.get(4);

        return new BatchResponse(
                Numeric.toHexString(id.getValue()),
                owner.getValue(),
                createdAt.getValue(),
                Numeric.toHexString(metadata.getValue()),
                mapBatchState(state.getValue())
        );
    }

    public BigInteger getOwnershipHistoryLength(byte[] batchId) throws Exception {
        Function function = new Function(
                "getOwnershipHistoryLength",
                List.of(new Bytes32(batchId)),
                List.of(new TypeReference<Uint256>() {}));
        List<Type> decoded = call(function);
        return ((Uint256) decoded.get(0)).getValue();
    }

    public OwnershipRecordResponse getOwnershipRecord(byte[] batchId, BigInteger index) throws Exception {
        Function function = new Function(
                "getOwnershipRecord",
                List.of(new Bytes32(batchId), new Uint256(index)),
                List.of(
                        new TypeReference<Address>() {},
                        new TypeReference<Uint8>() {},
                        new TypeReference<Uint256>() {}
                ));

        List<Type> decoded = call(function);
        Address owner = (Address) decoded.get(0);
        Uint8 role = (Uint8) decoded.get(1);
        Uint256 timestamp = (Uint256) decoded.get(2);

        return new OwnershipRecordResponse(owner.getValue(), role.getValue(), timestamp.getValue());
    }

    private TransactionReceipt sendTransaction(Function function) throws Exception {
        String data = FunctionEncoder.encode(function);
        EthSendTransaction tx = transactionManager.sendTransaction(
                properties.getGasPrice(),
                properties.getGasLimit(),
                properties.getSupplyChain().getContractAddress(),
                data,
                BigInteger.ZERO);

        if (tx.hasError()) {
            throw new IllegalStateException(tx.getError().getMessage());
        }

        return receiptProcessor.waitForTransactionReceipt(tx.getTransactionHash());
    }

    private List<Type> call(Function function) throws Exception {
        String data = FunctionEncoder.encode(function);
        Transaction tx = Transaction.createEthCallTransaction(
                transactionManager.getFromAddress(),
                properties.getSupplyChain().getContractAddress(),
                data);
        EthCall response = web3j.ethCall(tx, DefaultBlockParameterName.LATEST).send();

        if (response.isReverted()) {
            throw new IllegalStateException("Call reverted: " + response.getRevertReason());
        }

        return FunctionReturnDecoder.decode(response.getValue(), function.getOutputParameters());
    }

    private String mapBatchState(BigInteger state) {
        int value = state.intValue();
        return switch (value) {
            case 0 -> "CREATED";
            case 1 -> "IN_DISTRIBUTION";
            case 2 -> "IN_PHARMACY";
            case 3 -> "SOLD";
            default -> "UNKNOWN";
        };
    }
}
