# 🏦 KipuBank

**KipuBank** es un contrato inteligente en Solidity que funciona como una bóveda segura de depósitos en ETH.  
Cada usuario tiene su propio balance y puede realizar depósitos o retiros bajo límites definidos, manteniendo buenas prácticas de seguridad y transparencia en cada operación.

---

## ⚙️ Características principales

- 💰 **Depósitos personales:** los usuarios pueden depositar ETH en su propia bóveda.
- 💸 **Retiros limitados:** cada retiro está sujeto a un umbral fijo (`withdrawLimitPerTx`), definido al desplegar el contrato.
- 🏦 **Límite global:** el contrato impone un máximo total de depósitos (`bankCap`) para controlar la capacidad del banco.
- 🔒 **Seguridad:** incluye protección contra reentrancia y utiliza el patrón *checks-effects-interactions*.
- ⚡ **Errores personalizados:** todas las validaciones fallidas revierten con errores específicos para mayor claridad.
- 🪪 **Eventos:** se emiten eventos en cada depósito y retiro exitoso.
- 📊 **Estadísticas:** el contrato lleva el conteo total de depósitos y retiros realizados.

---

## 🧩 Estructura del contrato

| Tipo de función | Nombre | Descripción |
|-----------------|---------|-------------|
| **Externa** | `deposit()` | Permite depositar ETH en la bóveda personal. |
| **Externa** | `withdraw(uint256 amount)` | Permite retirar ETH hasta el límite permitido por transacción. |
| **View** | `getBalance(address user)` | Devuelve el saldo actual de un usuario. |
| **View** | `getBankStats()` | Devuelve totales de depósitos y retiros. |
| **Privada** | `_safeSend(address to, uint256 amount)` | Envía ETH de forma segura, revirtiendo si falla. |

---

## 🔐 Seguridad implementada

- `nonReentrant`: evita ataques de reentrancia.
- Validaciones estrictas (`InvalidValue`, `InsufficientBalance`, etc.).
- Transferencias seguras usando `call`.
- Reversión de envíos directos mediante `receive()` y `fallback()`.

---

## 🚀 Parámetros de despliegue

El constructor recibe dos valores inmutables:

| Parámetro | Tipo | Descripción |
|------------|------|-------------|
| `_bankCap` | `uint256` | Límite global de depósitos en wei. |
| `_withdrawLimitPerTx` | `uint256` | Límite máximo por retiro (wei). |


