# medichain

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Supply-chain UI

This build adds a Supply Chain Console UI that talks to:

```
http://localhost:8081/api/supply-chain
```

If you run on Android emulator, update the base URL in
`lib/services/api_service.dart` to `http://10.0.2.2:8081/api`.

### Run

```
flutter pub get
flutter run
```

### Sample payloads

Create Batch:

```
POST /api/supply-chain/batches
{
	"batchId": "0xabc123",
	"metadataHash": "0xdef456"
}
```

Transfer Batch:

```
POST /api/supply-chain/batches/transfer
{
	"batchId": "0xabc123",
	"to": "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"
}
```

Verify Batch:

```
POST /api/supply-chain/batches/verify
{
	"batchId": "0xabc123",
	"metadataHash": "0xdef456"
}
```

Get Batch:

```
GET /api/supply-chain/batches/{batchId}
```

History:

```
GET /api/supply-chain/batches/{batchId}/history
GET /api/supply-chain/batches/{batchId}/history/{index}
```
