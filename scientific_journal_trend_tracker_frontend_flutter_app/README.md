# Scientific Journal Trend Tracker Frontend

A premium, responsive, and data-driven Flutter application for monitoring, tracking, and analyzing academic publication trends and emerging research keywords. Designed with a clean scholarly aesthetic using dark/deep blue gradients, glassmorphism, and interactive visualization charts.

---

## 🚀 Key Features

### 👤 User & Auth Flow
*   **Secure Authentication**: JWT token-based session management integrated with `SharedPreferences`.
*   **Role-Based Dashboards**: Automatically changes layout permissions depending on roles: `Admin`, `Researcher`, or `Student`.
*   **Profile Settings**: Update name, bio, research interests, and change credentials securely.

### 📊 Trends & Analytics Dashboard
*   **Interactive Charts**: Data visualization using `fl_chart` to track publication growth rates and year-over-year keyword metrics.
*   **Trending keywords**: Grid/List of topics growing rapidly in academic literature.
*   **Bookmarks & Saved Papers**: Save papers to personal bookmarks, fetch paginated reading lists, and check bookmark status instantly.
*   **Tracking & Notifications**: Choose to follow specific keywords or journals and receive in-app alerts when new related papers are indexed.

### 📝 Scholar Resources (CRUD)
*   **Papers**: Local paginated title/abstract search, plus on-demand external academic searches powered by Semantic Scholar.
*   **Journals**: View tracked scholarly publishers, ISSNs, and impact factors.
*   **Topics**: Group research keywords into cohesive topics, highlighting emerging trends.
*   **Authors [NEW]**: 
    *   Responsive grid cards highlighting author name, affiliation, ORCID/Scholar badges, and total publication counts.
    *   Full-text search on name and affiliation.
    *   Dialog forms (Researchers & Admins) to Create/Update author profiles.
    *   Safety alert dialogs for deletion (Admin only).

### 🛠️ Admin Management
*   **User Profiles Control**: Activate/Deactivate users and update system-wide roles.
*   **API Harvesting Sources**: Add, edit, or delete external API providers (e.g. OpenAlex, Semantic Scholar), configuring sync frequencies.
*   **Manual Synchronization**: Force an on-demand data sync run in the background.
*   **Sync Execution Logs [NEW]**:
    *   Track background scheduler runs with color-coded status badges (`success`, `failed`, `running`).
    *   Detailed statistics on paper updates (Papers Added, Skipped, Updated).
    *   Details dialog displaying exact timestamps, duration, and error traces.
    *   A logs cleanup tool to purge historical execution history.

---

## 🛠️ Technology Stack

- **SDK**: Flutter (Dart `^3.11.5`)
- **State Management**: `provider` (`^6.1.5+1`)
- **Routing**: `go_router` (`^17.2.3`)
- **Aesthetics & UI**: `google_fonts` (Lora & Inter), `lucide_icons`
- **Charts**: `fl_chart` (`^1.2.0`)
- **Local Storage**: `shared_preferences` & `flutter_secure_storage`
- **Network**: `http`

---

## 💻 Setup and Running

### Prerequisites
- Flutter SDK installed and configured on your machine.
- A running backend server (defaults to port 5000).

### Steps
1. **Navigate to project directory**:
   ```bash
   cd scientific_journal_trend_tracker_frontend_flutter_app
   ```

2. **Configure API Base URL**:
   Open `lib/core/constants/api_constants.dart` and modify `baseUrl` to point to your local backend IP or production address:
   ```dart
   // For local development:
   static const String baseUrl = 'http://localhost:5000'; // Web or Desktop
   // static const String baseUrl = 'http://10.0.2.2:5000'; // Android Emulator
   ```

3. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

4. **Launch Application**:
   ```bash
   flutter run
   ```
