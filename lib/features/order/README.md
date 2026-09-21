# Local medicine orders

Orders are saved to SQLite and attachments to durable application storage.
Creation works without network access. The doctor picker reads the signed-in
account's existing Offline Doctors module; products use the existing cached
catalogue. Customer fields remain editable. `doctor_id` holds the selected local
doctor identity and is cleared when the customer name or customer type changes.

With no customer attachment, saving creates a PDF using bundled fonts. Existing
proof images/PDFs are retained. Preview and sharing always generate the structured
order document from the saved order snapshot. Sharing does not acknowledge upload.
Pending orders remain visible irrespective of their age.

## Backend integration remains disabled

No order API has been supplied. Leave `ORDER_CREATE_URL` unset. The sync service
reports upload unavailable and leaves rows/files intact. Before enabling a future
API, agree its request and acknowledgment contract, resolve local doctor IDs to
server IDs after doctor creation, and decide account scoping and server history.
Never send a local doctor ID as a server ID. The existing provisional multipart
adapter is not a confirmed backend contract.

The provisional adapter requires a successful response with `success: true` and
`data.id`, matching `data.clientGeneratedId`, and `data.attachmentAccepted: true`.
It uses the client-generated ID as an idempotency key. Do not enable this adapter
without verifying this contract and doctor identity resolution.

## Verification

Run `flutter test test/features/order`. Generate a demonstration PDF with:

```
flutter test test/features/order/order_pdf_test.dart --dart-define=ORDER_PDF_SAMPLE=output/pdf/medicine-order-sample.pdf
```

The Desktop reference image requested during implementation was unavailable, so
the document uses a medicine-order table with customer/delivery details, paid and
free quantities, optional rates, discounts, taxes, and estimated totals.
