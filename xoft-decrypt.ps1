<#
.SYNOPSIS
    Decrypts text that was encrypted with the hobby‑style XOFT cipher.

.DESCRIPTION
    Reverses all stages of XOFT as documented by CodeProject:
        1. Base‑64 character → 6‑bit value      (GetNFromB64)
        2. Undo “×4 + m” nibble tweak
        3. Re‑pack nibbles into 8‑bit bytes
        4. Subtract key‑length constant
        5. XOR with repeating key
    Outputs the recovered plaintext (ASCII).

.PARAMETER Ciphertext
    The XOFT‑encoded, base‑64 string.

.PARAMETER Key
    The ASCII key used during encryption.

.EXAMPLE
    PS> .\xoft-decrypt.ps1 -Ciphertext 'AZGLA5C7EBWTIVCzExC7Ad' -Key 'hidden'
    hello world
#>

param(
    [Parameter(Mandatory)]
    [string]$Ciphertext,

    [Parameter(Mandatory)]
    [string]$Key
)

# --- constants ---------------------------------------------------------------
$b64Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='
$keyLen      = $Key.Length

# --- helper: map a base‑64 char to its index (0‑64) --------------------------
function Get-B64Index([char]$c) {
    $idx = $b64Alphabet.IndexOf($c)
    if ($idx -lt 0) { throw "Invalid base‑64 character: '$c'" }
    return $idx
}

# --- 1. base64 → integers ----------------------------------------------------
[int[]]$vals = foreach ($ch in $Ciphertext.ToCharArray()) { Get-B64Index $ch }

# --- 2. undo the ‘×4 + m’ nibble tweak --------------------------------------
[int[]]$nibbles = for ($i = 0; $i -lt $vals.Count; $i++) {
    $m        = $i % 4                     # cycle 0,1,2,3
    $temp     = ($vals[$i] - $m) % 64      # reverse “+ m”
    [int]($temp / 4)                       # reverse “×4”
}

# --- 3. re‑pack two 4‑bit nibbles → one byte --------------------------------
[int[]]$bytes = for ($i = 0; $i -lt $nibbles.Count; $i += 2) {
    ($nibbles[$i] -shl 4) -bor $nibbles[$i + 1]
}

# --- 4 & 5. subtract keyLen and XOR with rotating key ------------------------
[byte[]]$plainBytes = 0..($bytes.Count - 1) | ForEach-Object {
    $b       = ($bytes[$_] - $keyLen) % 256
    $keyByte = [byte][char]$Key[($_ % $keyLen)]
    $b -bxor $keyByte
}

# --- output ------------------------------------------------------------------
[System.Text.Encoding]::ASCII.GetString($plainBytes)
