# 🦾 Workout Architect

Elite AI-powered fitness ecosystem for personalized training protocols and real-time performance analytics.

## 🚀 Core Features

*   **AI Architecture Engine:** Generates goal-specific protocols (Hypertrophy, Strength, Fat Loss) scaling intensity based on user biometrics and target timeframes.
*   **Smart Scheduling:** Generates matching weekly cycles based on user-selected training days.
*   **Neural Dashboard:** Automatically synchronizes with the system clock to highlight today's routines and provides AI-driven feedback (Plateau detection, Injury alerts, Tactical tips).
*   **Integrated Nutrition:** Goal-specific meal protocols and nutritional pivots included in every generated plan.
*   **Performance Analytics:** Interactive charts tracking total training volume (Weight × Reps) and visual task-completion status.
*   **Biometric Tracking:** Direct body weight management with historical logging and dedicated update dialogs.
*   **Advanced Security:** Secure Auth suite featuring secure signup, email-based password resets, and in-app password updates.

## 🛠 Tech Stack & Packages

*   **Framework:** Flutter (MVVM Architecture)
*   **Backend:** Firebase (Auth & Firestore)
*   **AI Brain:** Gemini 2.0 Flash (via OpenRouter API)
*   **State Management:** `provider`
*   **Data Visualization:** `fl_chart`
*   **Design:** `lucide_icons`, `google_fonts`, `font_awesome_flutter`
*   **Logic:** `http` (API Bridge), `intl` (Date Formatting)

## 🚦 Quick Start

1.  **Firebase Setup:** Add `google-services.json` to `android/app/`. Enable Email Auth & Firestore.
2.  **API Integration:** Insert your Gemini key in `lib/main.dart`.
3.  **Launch:**
    ```sh
    flutter pub get
    flutter run
    ```
