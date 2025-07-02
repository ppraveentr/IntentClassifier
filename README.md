# Intelligent Banking Intent Extractor

Personal project by Praveen Prabhakar.

## Overview

This app demonstrates how to extract and classify user banking intents from natural language using on-device generative models and the Foundation Models framework. Enter a request such as "Send $50 to Mom tomorrow from checking" and the app will classify the intent and extract relevant details.

## Features

- On-device intent classification using Foundation Models
- Supports various banking intents:
    - Payments (send money, pay bills)
    - Schedule appointments
    - Check FICO score
    - Find ATMs
    - Card management (freeze, unfreeze cards)
    - Account queries (balances, transactions)
- Example requests and robust parsing of dates and entities
- Sample input picker and real-time output display

<img width="461" alt="Payment Indend" src="https://github.com/user-attachments/assets/e878da60-c1b8-4343-9d3c-bd07d5f1d7e5" />
<img width="461" alt="Schedule appointments Indend" src="https://github.com/user-attachments/assets/1014d549-954a-4946-914a-e016a6b4fa5e" />

## Usage

1. Open the project in Xcode 26.0 or later.
2. Ensure your development environment supports SwiftUI and Foundation Models framework.
3. Build and run on a supported simulator or device.
4. Enter sample banking requests in the input field, or tap to select from bundled examples.
5. View the extracted intent and details in the output box.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request with your improvements.

## License

This project is licensed under your personal license. See LICENSE.txt for details.


---

_This project originally demonstrated the Foundation Models framework, now customized and maintained as a personal project._
