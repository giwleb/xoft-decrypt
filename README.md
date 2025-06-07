# XOFT Decrypt PowerShell Tool

A small command‑line utility for **decrypting text that was encrypted with the hobby‑grade “XOFT” cipher** (a multi‑stage, repeating‑key XOR algorithm popularised by a 2009 CodeProject post).

> **Heads‑up — XOFT is *not* cryptographically secure.**  It can be broken with classical frequency analysis.  Use this tool only for curiosity, legacy compatibility, or educational exploration.

---

## Features

* Pure PowerShell ‑‑ no external modules or binaries.
* Accepts ciphertext and key directly via named parameters.
* Reverses every XOFT encoding stage: Base‑64 → nibble‑tweak → byte‑pack → constant‑subtract → XOR.
* Outputs recovered plaintext to `stdout`, so it can be piped into other tools.

---

## Prerequisites

| Requirement | Notes |
|-------------|-------|
| **PowerShell 5.x** (Windows) **or PowerShell 7+** (cross‑platform) | The script uses only built‑in cmdlets and .NET classes. |
| ASCII‑compatible key & ciphertext | The reference implementation assumes 8‑bit ASCII.  For UTF‑8 data, you’ll need to adapt the encoding sections. |

---

## Installation

1. Clone or download this repository.
2. Place **`xoft-decrypt.ps1`** in the project root (or anywhere that’s on your `$env:PATH`).
3. (Optional) Unblock the file if it was downloaded from the internet:
   ```powershell
   Unblock-File .\xoft-decrypt.ps1
   ```

---

## Usage

```powershell
# Basic invocation
.\xoft-decrypt.ps1 -Ciphertext "AZGLA5C7EBWTIVCzExC7Ad" -Key "hidden"

# Shorthand with positional args (Ciphertext, then Key)
.\xoft-decrypt.ps1 "AZGLA5C7EBWTIVCzExC7Ad" "hidden"

# Piping ciphertext in via the pipeline
"AZGLA5C7EBWTIVCzExC7Ad" | .\xoft-decrypt.ps1 -Key "hidden"
```

Expected output:

```text
hello world
```

Pass `-Verbose` for an annotated walk‑through of each internal stage (useful for teaching or debugging):

```powershell
.\xoft-decrypt.ps1 -Ciphertext "..." -Key "..." -Verbose
```

---

## Algorithm  (one‑liner version)

The script reverses the exact transforms applied by the CodeProject XOFT encoder:

1. **Base‑64 alphabet → 6‑bit integer values**
2. **Undo nibble tweak**   `(value − m) mod 64 ; (value / 4)`
3. **Re‑pack nibbles**   two 4‑bit nibbles → one 8‑bit byte
4. **Subtract key‑length constant**
5. **XOR each byte with the repeating key**

All steps are linear and deterministic; no cryptographic primitives are involved.

---

## Security Warning

XOFT provides *obfuscation*, not encryption.  For real confidentiality you should use a modern, standardised algorithm such as **AES‑GCM** or **ChaCha20‑Poly1305**.  This tool exists solely because some legacy data was encoded with XOFT and still needs to be read.

---

## Contributing

Pull requests are welcome for:

* Bug fixes, edge‑case handling, or performance tweaks.
* Adding complementary **encrypt** functionality.
* Porting to other scripting languages.

Please follow the established PowerShell style (camelCase variables, inline comment headers) and include tests for new functionality.

---

## License

This repository is released under the **MIT License**.  See `LICENSE` for details.
