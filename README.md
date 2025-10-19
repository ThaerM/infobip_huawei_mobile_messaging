# infobip_huawei_mobile_messaging

Flutter wrapper for **Infobip Mobile Messaging – Huawei** (HMS) with push, token stream, message receive/tap, **In-App**, and **Inbox**.

## Requirements

- Huawei **AppGallery Connect** project with **Push Kit** enabled and **`agconnect-services.json`** in your app’s `android/app/`.  
  Docs: AG Connect + Push Kit setup.
- Infobip **Mobile Application Profile** with **Application Code** and **Huawei** push enabled.

## Install

`pubspec.yaml`:
```yaml
dependencies:
  infobip_huawei_mobile_messaging: ^0.1.0