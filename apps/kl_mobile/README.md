# Navi4All - Kaiserslautern

## Translation Guide
This app currently supports the following locales:
- `en` - English
- `de` - German

App-wide strings are located in the `kl_mobile/lib/i10n/app_[locale].arb` files, where `[locale]` is the language code (e.g. `de`).

All strings must have a 1:1 mapping accross locales, meaning that if a string is present in one locale, it must also be present in all other locales.

The following steps should be performed while translating:
* Open the `app_[locale].arb` file for the locale you want to translate
* Translate the value of each key, ensuring that the key itself remains unchanged
* Confirm existing parameter positioning is retained in translated strings
* Preserve newline characters (`\n`) in strings, as they may affect the layout of the app
* Try to retain similar lengths for translated strings, as this can help maintain the app's layout
* Save the `app_[locale].arb` file once translation is complete
* From the root directory of the project, run the following command:
   ```bash
   flutter gen-l10n
   ```
   Note: This command requires the Flutter SDK to be installed.