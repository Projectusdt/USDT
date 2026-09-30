// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

contract MuSDTToken {
    string public constant name = "Tether";
    string public constant symbol = "USDT";
    uint8 public constant decimals = 6;

    string public constant logoURI =
        "https://static.tronscan.org/production/logo/usdtlogo.png";

    address public owner;
    bool public paused;

    uint256 public totalSupply;
    uint256 public transferFeeBasisPoints;
    address public feeRecipient;
    uint256 public maxTotalSupply;

    mapping(address => bool) public frozenAddress;
    mapping(address => uint256) public maxWithdrawalPerTx;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event Paused();
    event Unpaused();

    event Frozen(address indexed account);
    event Unfrozen(address indexed account);

    event FeeUpdated(
        uint256 feeBasisPoints,
        address indexed recipient
    );

    event WithdrawalLimitSet(
        address indexed account,
        uint256 maxAmount
    );

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event MaxSupplyUpdated(uint256 newMaxSupply);

    event TransferBlocked(
        address indexed account,
        bool frozen
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "token is paused");
        _;
    }

    constructor(address initialRecipient) {
        if (initialRecipient == address(0)) {
            revert("initialRecipient is zero address");
        }

        owner = msg.sender;
        paused = false;
        transferFeeBasisPoints = 0;
        feeRecipient = msg.sender;

        maxTotalSupply =
            10_000_000 * 10 ** uint256(decimals);

        uint256 supply =
            1_000_000 * 10 ** uint256(decimals);

        totalSupply = supply;

        require(
            totalSupply <= maxTotalSupply,
            "initial supply exceeds max supply"
        );

        balanceOf[initialRecipient] = supply;

        emit Transfer(
            address(0),
            initialRecipient,
            supply
        );
    }

    function transfer(
        address recipient,
        uint256 amount
    )
        external
        whenNotPaused
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(
        address spender,
        uint256 amount
    )
        external
        returns (bool)
    {
        require(
            spender != address(0),
            "invalid spender"
        );

        allowance[msg.sender][spender] = amount;

        emit Approval(
            msg.sender,
            spender,
            amount
        );

        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    )
        external
        whenNotPaused
        returns (bool)
    {
        uint256 allowed =
            allowance[sender][msg.sender];

        require(
            allowed >= amount,
            "allowance exceeded"
        );

        allowance[sender][msg.sender] =
            allowed - amount;

        _transfer(
            sender,
            recipient,
            amount
        );

        return true;
    }

    function pause() external onlyOwner {
        paused = true;
        emit Paused();
    }

    function unpause() external onlyOwner {
        paused = false;
        emit Unpaused();
    }

    function setFrozen(
        address account,
        bool shouldFreeze
    )
        external
        onlyOwner
    {
        require(
            account != address(0),
            "invalid account"
        );

        frozenAddress[account] = shouldFreeze;

        emit TransferBlocked(
            account,
            shouldFreeze
        );

        if (shouldFreeze) {
            emit Frozen(account);
        } else {
            emit Unfrozen(account);
        }
    }

    function setMaxWithdrawalPerTx(
        address account,
        uint256 maxAmount
    )
        external
        onlyOwner
    {
        maxWithdrawalPerTx[account] = maxAmount;

        emit WithdrawalLimitSet(
            account,
            maxAmount
        );
    }

    function setFee(
        uint256 feeBasisPoints,
        address recipient
    )
        external
        onlyOwner
    {
        require(
            feeBasisPoints <= 1000,
            "fee too high"
        );

        require(
            recipient != address(0),
            "invalid recipient"
        );

        transferFeeBasisPoints =
            feeBasisPoints;

        feeRecipient = recipient;

        emit FeeUpdated(
            feeBasisPoints,
            recipient
        );
    }

    function setMaxSupply(
        uint256 newMaxSupply
    )
        external
        onlyOwner
    {
        require(
            newMaxSupply >= totalSupply,
            "max below supply"
        );

        maxTotalSupply = newMaxSupply;

        emit MaxSupplyUpdated(
            newMaxSupply
        );
    }

    function transferOwnership(
        address newOwner
    )
        external
        onlyOwner
    {
        require(
            newOwner != address(0),
            "new owner is zero"
        );

        emit OwnershipTransferred(
            owner,
            newOwner
        );

        owner = newOwner;
    }

    function mint(
        address to,
        uint256 amount
    )
        external
        onlyOwner
    {
        require(
            to != address(0),
            "invalid recipient"
        );

        require(
            totalSupply + amount <= maxTotalSupply,
            "exceeds max supply"
        );

        totalSupply += amount;
        balanceOf[to] += amount;

        emit Mint(to, amount);

        emit Transfer(
            address(0),
            to,
            amount
        );
    }

    function burn(
        address from,
        uint256 amount
    )
        external
        onlyOwner
    {
        require(
            balanceOf[from] >= amount,
            "insufficient balance to burn"
        );

        balanceOf[from] -= amount;
        totalSupply -= amount;

        emit Burn(
            from,
            amount
        );

        emit Transfer(
            from,
            address(0),
            amount
        );
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    )
        private
    {
        require(
            to != address(0),
            "invalid recipient"
        );

        require(
            !frozenAddress[from],
            "sender frozen"
        );

        require(
            !frozenAddress[to],
            "recipient frozen"
        );

        uint256 fromBalance =
            balanceOf[from];

        uint256 maxAmount =
            maxWithdrawalPerTx[from];

        if (maxAmount > 0) {
            require(
                amount <= maxAmount,
                "withdrawal limit exceeded"
            );
        }

        require(
            fromBalance >= amount,
            "insufficient balance"
        );

        require(
            transferFeeBasisPoints <= 10000,
            "invalid fee setting"
        );

        uint256 fee =
            (amount * transferFeeBasisPoints) /
            10000;

        uint256 netAmount =
            amount - fee;

        unchecked {
            balanceOf[from] =
                fromBalance - amount;

            balanceOf[to] += netAmount;

            if (fee > 0) {
                balanceOf[feeRecipient] += fee;
            }
        }

        emit Transfer(
            from,
            to,
            netAmount
        );

        if (fee > 0) {
            emit Transfer(
                from,
                feeRecipient,
                fee
            );
        }
    }
}
