// SPDX-License-Identifier: <Licencia>

pragma solidity ^0.8.0;

contract EToken2 {
    function baseUnit(bytes32 _symbol) view returns (uint8);
    function name(bytes32 _symbol) view returns (string memory);
    function description(bytes32 _symbol) view returns (string memory);
    function owner(bytes32 _symbol) view returns (address);
    function isOwner(address _owner, bytes32 _symbol) view returns (bool);
    function totalSupply(bytes32 _symbol) view returns (uint);
    function balanceOf(address _holder, bytes32 _symbol) view returns (uint);
    function isLocked(bytes32 _symbol) view returns (bool);
    function proxyTransferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string memory _reference, address _sender) returns (bool);
    function proxyApprove(address _spender, uint _value, bytes32 _symbol, address _sender) returns (bool);
    function allowance(address _from, address _spender, bytes32 _symbol) view returns (uint);
    function proxyTransferFromWithReference(address _from, address _to, uint _value, bytes32 _symbol, string memory _reference, address _sender) returns (bool);
}

contract Asset {
    function _performTransferWithReference(address _to, uint _value, string memory _reference, address _sender) returns (bool);
    function _performTransferToICAPWithReference(bytes32 _icap, uint _value, string memory _reference, address _sender) returns (bool);
    function _performApprove(address _spender, uint _value, address _sender) returns (bool);    
    function _performTransferFromWithReference(address _from, address _to, uint _value, string memory _reference, address _sender) returns (bool);
    function _performTransferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string memory _reference, address _sender) returns (bool);
    function _performGeneric(bytes memory _data, address _sender) payable returns (bytes32) {
        revert();
    }
}

contract ERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed from, address indexed spender, uint256 value);

    function totalSupply() view returns (uint256 supply);
    function balanceOf(address _owner) view returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) view returns (uint256 remaining);
    function decimals() view returns (uint8);
}

contract AssetProxyInterface {
    function _forwardApprove(address _spender, uint _value, address _sender) returns (bool);    
    function _forwardTransferFromWithReference(address _from, address _to, uint _value, string memory _reference, address _sender) returns (bool);
    function _forwardTransferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string memory _reference, address _sender) returns (bool);
}

contract Bytes32 {
    function _bytes32(string memory _input) internal pure returns (bytes32 result) {
        assembly {
            result := mload(add(_input, 32))
        }
    }
}

contract AssetProxy is ERC20, AssetProxyInterface, Bytes32 {
    // Assigned EToken2, immutable.
    EToken2 public etoken2;

    // Assigned symbol, immutable.
    bytes32 public etoken2Symbol;

    // Assigned name, immutable. For UI.
    string public name;
    string public symbol;

    /**
     * Sets EToken2 address, assigns symbol and name.
     *
     * Can be set only once.
     *
     * @param _etoken2 EToken2 contract address.
     * @param _symbol assigned symbol.
     * @param _name assigned name.
     *
     * @return success.
     */
    function init(EToken2 _etoken2, string memory _symbol, string memory _name) returns (bool) {
        require(address(etoken2) == address(0), "Already initialized");
        etoken2 = _etoken2;
        etoken2Symbol = _bytes32(_symbol);
        name = _name;
        symbol = _symbol;
        return true;
    }

    /**
     * Only EToken2 is allowed to call.
     */
    modifier onlyEToken2() {
        require(msg.sender == address(etoken2), "Only EToken2 allowed");
        _;
    }

    /**
     * Only current asset owner is allowed to call.
     */
    modifier onlyAssetOwner() {
        require(etoken2.isOwner(msg.sender, etoken2Symbol), "Only asset owner allowed");
        _;
    }

    /**
     * Returns asset implementation contract for current caller.
     *
     * @return asset implementation contract.
     */
    function _getAsset() internal view returns (Asset) {
        return Asset(getVersionFor(msg.sender));
    }

    function recoverTokens(uint _value) onlyAssetOwner() returns (bool) {
        return this.transferWithReference(msg.sender, _value, 'Tokens recovery');
    }

    /**
     * Returns asset total supply.
     *
     * @return asset total supply.
     */
    function totalSupply() view returns (uint) {
        return etoken2.totalSupply(etoken2Symbol);
    }

    /**
     * Returns asset balance for a particular holder.
     *
     * @param _owner holder address.
     *
     * @return holder balance.
     */
    function balanceOf(address _owner) view returns (uint) {
        return etoken2.balanceOf(_owner, etoken2Symbol);
    }

    /**
     * Returns asset allowance from one holder to another.
     *
     * @param _from holder that allowed spending.
     * @param _spender holder that is allowed to spend.
     *
     * @return holder to spender allowance.
     */
    function allowance(address _from, address _spender) view returns (uint) {
        return etoken2.allowance(_from, _spender, etoken2Symbol);
    }

    /**
     * Returns asset decimals.
     *
     * @return asset decimals.
     */
    function decimals() view returns (uint8) {
        return etoken2.baseUnit(etoken2Symbol);
    }

    /**
     * Transfers asset balance from the caller to specified receiver.
     *
     * @param _to holder address to give to.
     * @param _value amount to transfer.
     *
     * @return success.
     */
    function transfer(address _to, uint _value) returns (bool) {
        return transferWithReference(_to, _value, '');
    }

    /**
     * Transfers asset balance from the caller to specified receiver adding specified comment.
     * Resolves asset implementation contract for the caller and forwards there arguments along with
     * the caller address.
     *
     * @param _to holder address to give to.
     * @param _value amount to transfer.
     * @param _reference transfer comment to be included in EToken2's Transfer event.
     *
     * @return success.
     */
    function transferWithReference(address _to, uint _value, string memory _reference) returns (bool) {
        return _getAsset()._performTransferWithReference(_to, _value, _reference, msg.sender);
    }

    /**
     * Transfers asset balance from the caller to specified ICAP.
     *
     * @param _icap recipient ICAP to give to.
     * @param _value amount to transfer.
     *
     * @return success.
     */
    function transferToICAP(bytes32 _icap, uint _value) returns (bool) {
        return transferToICAPWithReference(_icap, _value, '');
    }

    /**
     * Transfers asset balance from the caller to specified ICAP adding specified comment.
     * Resolves asset implementation contract for the caller and forwards there arguments along with
     * the caller address.
     *
     * @param _icap recipient ICAP to give to.
     * @param _value amount to transfer.
     * @param _reference transfer comment to be included in EToken2's Transfer event.
     *
     * @return success.
     */
    function transferToICAPWithReference(bytes32 _icap, uint _value, string memory _reference) returns (bool) {
        return _getAsset()._performTransferToICAPWithReference(_icap, _value, _reference, msg.sender);
    }

    /**
     * Prforms allowance transfer of asset balance between holders.
     *
     * @param _from holder address to take from.
     * @param _to holder address to give to.
     * @param _value amount to transfer.
     *
     * @return success.
     */
    function transferFrom(address _from, address _to, uint _value) returns (bool) {
        return transferFromWithReference(_from, _to, _value, '');
    }

    /**
     * Prforms allowance transfer of asset balance between holders adding specified comment.
     * Resolves asset implementation contract for the caller and forwards there arguments along with
     * the caller address.
     *
     * @param _from holder address to take from.
     * @param _to holder address to give to.
     * @param _value amount to transfer.
     * @param _reference transfer comment to be included in EToken2's Transfer event.
     *
     * @return success.
     */
    function transferFromWithReference(address _from, address _to, uint _value, string memory _reference) returns (bool) {
        return _getAsset()._performTransferFromWithReference(_from, _to, _value, _reference, msg.sender);
    }

    /**
     * Prforms allowance transfer of asset balance between holders.
     *
     * @param _from holder address to take from.
     * @param _icap recipient ICAP address to give to.
     * @param _value amount to transfer.
     *
     * @return success.
     */
    function transferFromToICAP(address _from, bytes32 _icap, uint _value) returns (bool) {
        return transferFromToICAPWithReference(_from, _icap, _value, '');
    }

    /**
     * Prforms allowance transfer of asset balance between holders adding specified comment.
     * Resolves asset implementation contract for the caller and forwards there arguments along with
     * the caller address.
     *
     * @param _from holder address to take from.
     * @param _icap recipient ICAP address to give to.
     * @param _value amount to transfer.
     * @param _reference transfer comment to be included in EToken2's Transfer event.
     *
     * @return success.
     */
    function transferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string memory _reference) returns (bool) {
        return _getAsset()._performTransferFromToICAPWithReference(_from, _icap, _value, _reference, msg.sender);
    }

    /**
     * Sets asset spending allowance for a specified spender.
     * Resolves asset implementation contract for the caller and forwards there arguments along with
     * the caller address.
     *
     * @param _spender holder address to set allowance to.
     * @param _value amount to allow.
     *
     * @return success.
     */
    function approve(address _spender, uint _value) returns (bool) {
        return _getAsset()._performApprove(_spender, _value, msg.sender);
    }

    /**
     * Performs transfer call on EToken2 by the name of specified sender.
     *
     * Can only be called by asset implementation contract assigned to sender.
     *
     * @param _from holder address to take from.
     * @param _to holder address to give to.
     * @param _value amount to transfer.
     * @param _reference transfer comment to be included in EToken2's Transfer event.
     * @param _sender initial caller.
     *
     * @return success.
     */
    function _forwardTransferFromWithReference(address _from, address _to, uint _value, string memory _reference, address _sender) onlyImplementationFor(_sender) returns (bool) {
        return etoken2.proxyTransferFromWithReference(_from, _to, _value, etoken2Symbol, _reference, _sender);
    }

    /**
     * Performs allowance transfer to ICAP call on EToken2 by the name of specified sender.
     *
     * Can only be called by asset implementation contract assigned to sender.
     *
     * @param _from holder address to take from.
     * @param _icap recipient ICAP address to give to.
     * @param _value amount to transfer.
     * @param _reference transfer comment to be included in EToken2's Transfer event.
     * @param _sender initial caller.
     *
     * @return success.
     */
    function _forwardTransferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string memory _reference, address _sender) onlyImplementationFor(_sender) returns (bool) {
        return etoken2.proxyTransferFromToICAPWithReference(_from, _icap, _value, _reference, _sender);
    }

    /**
     * Performs allowance setting call onEToken2 by the name of specified sender.
     *
     * Can only be called by asset implementation contract assigned to sender.
     *
     * @param _spender holder address to set allowance to.
     * @param _value amount to allow.
     * @param _sender initial caller.
     *
     * @return success.
     */
    function _forwardApprove(address _spender, uint _value, address _sender) onlyImplementationFor(_sender) returns (bool) {
        return etoken2.proxyApprove(_spender, _value, etoken2Symbol, _sender);
    }

    /**
     * Returns asset implementation contract address for the specified caller.
     *
     * @param _caller caller address.
     *
     * @return asset implementation contract address.
     */
    function getVersionFor(address _caller) view returns (address) {
        if (etoken2.isLocked(etoken2Symbol)) {
            return address(etoken2);
        }
        if (etoken2.isOwner(_caller, etoken2Symbol)) {
            return address(etoken2);
        }
        return address(this);
    }

    /**
     * Throws if called not by asset implementation contract assigned to caller address.
     */
    modifier onlyImplementationFor(address _caller) {
        require(getVersionFor(_caller) == msg.sender, "Invalid caller");
        _;
    }

    /**
     * Accepts asset transfer from other EToken2 contracts.
     *
     * Can only be called by assigned EToken2 contract.
     */
    function receiveEthers() payable onlyEToken2() {
    }

    /**
     * Performs default action when receiving ethers.
     *
     * Forwards received ethers to owner EToken2 contract.
     */
    fallback() payable onlyEToken2() {
        address(etoken2).transfer(msg.value);
    }
}
