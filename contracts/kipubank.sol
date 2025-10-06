// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title KipuBank
/// @notice Banco simple con límite global y por transacción.
contract KipuBank {
    // ==== ERRORES ====
    error InvalidValue(); // Valor inválido
    error BankCapExceeded(uint256 currentTotal, uint256 attemptedDeposit, uint256 bankCap); // Supera el límite global
    error InsufficientBalance(uint256 available, uint256 requested); // Fondos insuficientes
    error WithdrawLimitExceeded(uint256 requested, uint256 limit); // Supera el límite por transacción
    error TransferFailed(address to, uint256 amount); // Falló el envío

    // ==== EVENTOS ====
    event Deposited(address indexed user, uint256 amount); // Depósito
    event Withdrawn(address indexed user, uint256 amount); // Retiro

    // ==== ESTADO ====
    mapping(address => uint256) private balances; // Saldo por usuario
    uint256 public totalDeposits; // Total depositado
    uint256 public totalDepositCount; // Cantidad de depósitos
    uint256 public totalWithdrawCount; // Cantidad de retiros
    uint256 public immutable bankCap; // Límite global
    uint256 public immutable withdrawLimitPerTx; // Límite por transacción
    bool private locked; // Bloqueo para reentrancia

    // ==== CONSTRUCTOR ====
    constructor(uint256 _bankCap, uint256 _withdrawLimitPerTx) {
        bankCap = _bankCap;
        withdrawLimitPerTx = _withdrawLimitPerTx;
    }

    // ==== MODIFICADOR ====
    modifier nonReentrant() {
        if (locked) revert();
        locked = true;
        _;
        locked = false;
    }

    // ==== FUNCIONES EXTERNAS ====
    /// @notice Deposita ETH en tu cuenta.
    function deposit() external payable {
        if (msg.value == 0) revert InvalidValue();

        uint256 newTotal = totalDeposits + msg.value;
        if (newTotal > bankCap) revert BankCapExceeded(totalDeposits, msg.value, bankCap);

        balances[msg.sender] += msg.value;
        totalDeposits = newTotal;
        totalDepositCount++;

        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Retira ETH hasta el límite permitido.
    function withdraw(uint256 amount) external nonReentrant {
        uint256 balanceUser = balances[msg.sender];
        if (balanceUser < amount) revert InsufficientBalance(balanceUser, amount);
        if (amount > withdrawLimitPerTx) revert WithdrawLimitExceeded(amount, withdrawLimitPerTx);
        if (amount == 0) revert InvalidValue();

        balances[msg.sender] = balanceUser - amount;
        totalWithdrawCount++;

        _safeSend(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    // ==== VISTAS ====
    /// @notice Devuelve el saldo del usuario.
    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    /// @notice Devuelve estadísticas básicas del contrato.
    function getBankStats()
        external
        view
        returns (uint256, uint256, uint256)
    {
        return (totalDeposits, totalDepositCount, totalWithdrawCount);
    }

    // ==== INTERNA ====
    /// @notice Envía ETH de forma segura.
    function _safeSend(address to, uint256 amount) private {
        (bool success, ) = to.call{value: amount}("");
        if (!success) revert TransferFailed(to, amount);
    }

    // ==== FALLBACK ====
    /// @notice Bloquea envíos directos.
    receive() external payable {
        revert InvalidValue();
    }

    fallback() external payable {
        revert InvalidValue();
    }
}
