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
    Transaction
)
from contracts.standard.library import (
    _transfer_from,
    _transfer_allowance_from,
    _issue,
    _redeem,
    _burn
)


#
## Events
#

@event
func Transfer(caller : felt, _from : felt, _to : felt, _transactions_len : felt, _transactions : felt*):
end

@event
func Issue(caller : felt, _to : felt, _transactions_len : felt, _transactions : felt*):
end

@event
func Redeem(caller : felt, _from : felt, _transactions_len : felt, _transactions : felt*):
end

@event
func Burn(caller : felt, _from : felt, _transactions_len : felt, _transactions : felt*):
end


#
## Externals
#

@external
func transferFrom{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _from : felt,
        _to : felt,
        _transactions_len : felt,
        _transactions : Transaction*
    ):
    alloc_locals
    with_attr error_message("transferFrom: can't transfer from zero address, got _from={_from}"):
        assert_not_zero(_from)
    end

    with_attr error_message("transferFrom: use burn() instead, got _to={_to}"):
        assert_not_zero(_to)
    end

    let (caller) = get_caller_address()
    _transfer_from(
        sender=_from,
        recipient=_to,
        transaction_index=0,
        transactions_len=_transactions_len,
        transactions=_transactions
    )
    Transfer.emit(caller, _from, _to, _transactions_len, _transactions)

    return ()
end

@external
func transferAllowanceFrom{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _from : felt,
        _to : felt,
        _transactions_len : felt,
        _transactions : Transaction*
    ):
    alloc_locals
    with_attr error_message("transferAllowanceFrom: can't transfer allowance from zero address, got _from={_from}"):
        assert_not_zero(_from)
    end

    with_attr error_message("transferAllowanceFrom: use burn() instead, got _to={_to}"):
        assert_not_zero(_to)
    end

    let (local caller) = get_caller_address()
    _transfer_allowance_from(
        caller=caller,
        sender=_from,
        recipient=_to,
        transaction_index=0,
        transactions_len=_transactions_len,
        transactions=_transactions
    )
    Transfer.emit(caller, _from, _to, _transactions_len, _transactions)

    return ()
end

@external
func issue{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _to: felt,
        _transactions_len : felt,
        _transactions : Transaction*
    ):
    alloc_locals
    with_attr error_message("issue: can't issue to zero address, got _to={_to}"):
        assert_not_zero(_to)
    end

    _issue(
        recipient=_to,
        transaction_index=0,
        transactions_len=_transactions_len,
        transactions=_transactions
    )
    let (caller) = get_caller_address()
    Issue.emit(caller, _to, _transactions_len, _transactions)

    return ()
end

@external
func redeem{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _from: felt,
        _transactions_len : felt,
        _transactions : Transaction*
    ):
    alloc_locals
    with_attr error_message("redeem: can't redeem from zero address, got _from={_from}"):
        assert_not_zero(_from)
    end

    _redeem(
        sender=_from,
        transaction_index=0,
        transactions_len=_transactions_len,
        transactions=_transactions
    )
    let (caller) = get_caller_address()
    Redeem.emit(caller, _from, _transactions_len, _transactions)

    return ()
end

@external
func burn{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        _from: felt,
        _transactions_len : felt,
        _transactions : Transaction*
    ):
    alloc_locals
    let (local caller) = get_caller_address()
    with_attr error_message("burn: caller is not owner, got _from={_from}"):
        assert caller = _from
    end

    _burn(
        sender=_from,
        transaction_index=0,
        transactions_len=_transactions_len,
        transactions=_transactions
    )
    Burn.emit(caller, _from, _transactions_len, _transactions)

    return ()
end