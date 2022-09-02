%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import (
    assert_not_zero,
    assert_not_equal,
    assert_le
)
from starkware.starknet.common.syscalls import (
    get_block_timestamp,
    get_caller_address,
    get_contract_address,
)

from contracts.utils.structs import (
    ClassMetadata,
    UnitMetadata,
    Values,
    Class,
    Unit,
    Transaction
)


#
## Storage
#

@storage_var
func _classMetadata(class_id : felt, metadata_id : felt) -> (classMetadata : ClassMetadata):
end

@storage_var
func _classes(class_id : felt, metadata_id : felt) -> (class : Values):
end

@storage_var
func _unitMetadata(class_id : felt, unit_id : felt, metadata_id : felt) -> (unitMetadata : UnitMetadata):
end

@storage_var
func _units(class_id : felt, unit_id : felt, metadata_id : felt) -> (unit : Values):
end

@storage_var
func _operator_approvals(address : felt, operator : felt) -> (approved : felt):
end

@storage_var
func _balances(address : felt, class_id : felt, unit_id : felt) -> (amount : felt):
end

@storage_var
func _allowances(address : felt, class_id : felt, unit_id : felt, spender : felt) -> (amount : felt):
end


#
## Internals
#

func _transfer_from{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        sender : felt,
        recipient : felt,
        transaction_index : felt,
        transactions_len : felt,
        transactions : Transaction*
    ):
    if transaction_index == transactions_len:
        return ()
    end

    tempvar transaction = transactions[transaction_index]
    let (balance_sender) = _balances.read(sender, transaction.class_id, transaction.unit_id)
    let (balance_recipient) = _balances.read(recipient, transaction.class_id, transaction.unit_id)

    with_attr error_message("_transfer_from: not enough funds to transfer, got sender's balance {balance_sender}"):
        assert_le(balance_sender, transaction.amount)
    end

    _balances.write(sender, transaction.class_id, transaction.unit_id, balance_sender - transaction.amount)
    _balances.write(recipient, transaction.class_id, transaction.unit_id, balance_recipient + transaction.amount)

    _transfer_from(
        sender=sender,
        recipient=recipient,
        transaction_index=transaction_index + 1,
        transactions_len=transactions_len,
        transactions=transactions
    )
    return ()
end

func _transfer_allowance_from{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        caller : felt,
        sender : felt,
        recipient : felt,
        transaction_index : felt,
        transactions_len : felt,
        transactions : Transaction*
    ):
    if transaction_index == transactions_len:
        return ()
    end

    tempvar transaction = transactions[transaction_index]
    let (balance_sender) = _balances.read(sender, transaction.class_id, transaction.unit_id)
    let (balance_recipient) = _balances.read(recipient, transaction.class_id, transaction.unit_id)

    with_attr error_message("_transfer_allowance_from: not enough funds to transfer, got sender's balance {balance_sender}"):
        assert_le(balance_sender, transaction.amount)
    end

    # reducing the caller's allowance and reflecting changes
    _allowances.write(balance_sender, transaction.class_id, transaction.unit_id, recipient, balance_sender - transaction.amount)
    _balances.write(sender, transaction.class_id, transaction.unit_id, balance_sender - transaction.amount)
    _balances.write(recipient, transaction.class_id, transaction.unit_id, balance_recipient + transaction.amount)

    _transfer_allowance_from(
        caller=caller,
        sender=sender,
        recipient=recipient,
        transaction_index=transaction_index + 1,
        transactions_len=transactions_len,
        transactions=transactions
    )
    return ()
end

func _issue{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        recipient : felt,
        transaction_index : felt,
        transactions_len : felt,
        transactions : Transaction*
    ):
    if transaction_index == transactions_len:
        return ()
    end

    tempvar transaction = transactions[transaction_index]
    let (balance_recipient) = _balances.read(recipient, transaction.class_id, transaction.unit_id)
    _balances.write(recipient, transaction.class_id, transaction.unit_id, balance_recipient + transaction.amount)

    _issue(
        recipient=recipient,
        transaction_index=transaction_index + 1,
        transactions_len=transactions_len,
        transactions=transactions
    )
    return ()
end

func _redeem{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        sender : felt,
        transaction_index : felt,
        transactions_len : felt,
        transactions : Transaction*
    ):
    if transaction_index == transactions_len:
        return ()
    end

    tempvar transaction = transactions[transaction_index]
    let (balance_sender) = _balances.read(sender, transaction.class_id, transaction.unit_id)

    with_attr error_message("_redeem: not enough funds to redeem, got sender's balance {balance_sender}"):
        assert_le(balance_sender, transaction.amount)
    end
    _balances.write(sender, transaction.class_id, transaction.unit_id, balance_sender - transaction.amount)

    _redeem(
        sender=sender,
        transaction_index=transaction_index + 1,
        transactions_len=transactions_len,
        transactions=transactions
    )
    return ()
end

func _burn{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        sender : felt,
        transaction_index : felt,
        transactions_len : felt,
        transactions : Transaction*
    ):
    if transaction_index == transactions_len:
        return ()
    end

    tempvar transaction = transactions[transaction_index]
    let (balance_sender) = _balances.read(sender, transaction.class_id, transaction.unit_id)

    with_attr error_message("_burn: not enough funds, got sender's balance {balance_sender}"):
        assert_le(balance_sender, transaction.amount)
    end
    _balances.write(sender, transaction.class_id, transaction.unit_id, balance_sender - transaction.amount)

    _burn(
        sender=sender,
        transaction_index=transaction_index + 1,
        transactions_len=transactions_len,
        transactions=transactions
    )
    return ()
end


func _balance_of{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        account : felt,
        class_id : felt,
        unit_id : felt
    ) -> (balance : felt):
    # TODO class and unit checks
    let (balance) = _balances.read(account, class_id, unit_id)
    return (balance)
end

func _allowance{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        owner : felt,
        spender : felt,
        class_id : felt,
        unit_id : felt,
    ) -> (remaining : felt):
    # TODO class and unit checks
    let (remaining) = _allowances.read(owner, class_id, unit_id, spender)
    return (remaining)
end

func _get_class_metadata{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        class_id : felt,
        metadata_id : felt
    ) -> (classMetadata : ClassMetadata):
    let (classMetadata) = _classMetadata.read(class_id, metadata_id)
    return (classMetadata)
end

func _get_unit_metadata{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        class_id : felt,
        unit_id : felt,
        metadata_id : felt
    ) -> (unitMetadata : UnitMetadata):
    let (unitMetadata) = _unitMetadata.read(class_id, unit_id, metadata_id)
    return (unitMetadata)
end

func _get_class_data{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        class_id : felt,
        metadata_id : felt
    ) -> (classData : Values):
    let (classData : Values) = _classes.read(class_id, metadata_id)
    return (classData)
end

func _get_unit_data{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        class_id : felt,
        unit_id : felt,
        metadata_id : felt
    ) -> (unitData : Values):
    let (unitData : Values) = _units.read(class_id, unit_id, metadata_id)
    return (unitData)
end