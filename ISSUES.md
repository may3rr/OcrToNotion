# Proposed Follow-up Issues

1. **Secrets Management UI** – Provide an in-app settings surface to capture and update GPT/Notion credentials and endpoints instead of relying on manual Keychain inserts.
2. **LLM Response Validation** – Add JSON schema validation with graceful retry logic when the language model returns malformed or partial data.
3. **Enhanced Notion Sync** – Support updating existing tasks by external ID and handle status transitions (e.g., auto-mark overdue tasks).
4. **Shortcut Error Feedback** – Surface localized, user-friendly error messages back to Shortcuts when OCR, GPT, or Notion operations fail.
5. **Unit Test Coverage** – Introduce mocks for the OCR, GPT, and Notion services to enable unit testing of the intent workflow.
