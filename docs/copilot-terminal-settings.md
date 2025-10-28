# GitHub Copilot Terminal Interruption Fix

## Issue

GitHub Copilot frequently interrupts terminal/console operations, causing terminal restarts and connection losses.

## Solution - VS Code Settings

Add these settings to your VS Code configuration to prevent terminal interruptions:

### 1. Disable Copilot Auto-Completions (Primary Fix)

```json
"github.copilot.editor.enableAutoCompletions": false
```

This is the most common cause of terminal interruptions - disables automatic inline suggestions.

### 2. Disable Terminal Shell Integration (If Issue Persists)

```json
"terminal.integrated.shellIntegration.enabled": false
```

Prevents extensions from intercepting terminal commands.

### 3. Disable Copilot Code Actions

```json
"github.copilot.editor.enableCodeActions": false
```

Reduces Copilot's aggressiveness in providing suggestions.

### 4. Selective Copilot Enable/Disable

```json
"github.copilot.enable": {
  "*": true,
  "markdown": false,
  "plaintext": false,
  "scminput": false
}
```

## How to Apply Settings

### Method 1: Settings UI

1. Press `Cmd+,` to open Settings
2. Search for "copilot terminal" or "copilot enable"
3. Uncheck/modify relevant options

### Method 2: Settings JSON

1. Press `Cmd+Shift+P`
2. Type "Preferences: Open User Settings (JSON)"
3. Add the settings above to your configuration

### Method 3: Workspace Settings

Create/edit `.vscode/settings.json` in your project root:

```json
{
  "github.copilot.editor.enableAutoCompletions": false,
  "terminal.integrated.shellIntegration.enabled": false
}
```

## Temporary Disable

When working extensively in terminal:

- Press `Cmd+Shift+P`
- Type "GitHub Copilot: Disable"
- Re-enable later with "GitHub Copilot: Enable"

## Notes

- Start with disabling `enableAutoCompletions` first
- If interruptions continue, progressively apply additional settings
- Terminal shell integration is useful but can conflict with extensions
- Consider workspace-specific settings if the issue only affects certain projects

---

Last Updated: October 18, 2025
