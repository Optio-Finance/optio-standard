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
from contracts.standard.library import OPTIO


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

@event
func ApprovalFor(caller : felt, operator : felt, approved : felt):
end


#
## Constructor
#

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        name : felt, asset : felt):
    OPTIO.initialize(name, asset)
    return ()
end


#
## Externals
#

@external
func transferFrom{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
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
    OPTIO.transfer_from(
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
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
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
    OPTIO.transfer_allowance_from(
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
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        _to : felt,
        _transactions_len : felt,
        _transactions : Transaction*
    ):
    alloc_locals
    with_attr error_message("issue: can't issue to zero address, got _to={_to}"):
        assert_not_zero(_to)
    end

    OPTIO.issue(
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
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        _from : felt,
        _transactions_len : felt,
        _transactions : Transaction*
    ):
    alloc_locals
    with_attr error_message("redeem: can't redeem from zero address, got _from={_from}"):
        assert_not_zero(_from)
    end

    OPTIO.redeem(
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
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        _from : felt,
        _transactions_len : felt,
        _transactions : Transaction*
    ):
    alloc_locals
    let (local caller) = get_caller_address()
    with_attr error_message("burn: caller is not owner, got _from={_from}"):
        assert caller = _from
    end

    OPTIO.burn(
        sender=_from,
        transaction_index=0,
        transactions_len=_transactions_len,
        transactions=_transactions
    )
    Burn.emit(caller, _from, _transactions_len, _transactions)

    return ()
end


#
## Getters
#

@view
func balanceOf{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        account : felt,
        class_id : felt,
        unit_id : felt
    ) -> (balance : felt):
    with_attr error_message("balanceOf: balance query for zero address"):
        assert_not_zero(account)
    end

    let (balance : felt) = OPTIO.balance_of(
        account=account,
        class_id=class_id,
        unit_id=unit_id
    )
    return (balance)
end

@view
func allowance{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        owner : felt,
        spender : felt,
        class_id : felt,
        unit_id : felt
    ) -> (remaining : felt):
    with_attr error_message("allowance: query for zero address"):
        assert_not_zero(owner)
        assert_not_zero(spender)
    end

    let (remaining : felt) = OPTIO.allowance(
        owner=owner,
        spender=spender,
        class_id=class_id,
        unit_id=unit_id
    )
    return (remaining)
end

@view
func getClassMetadata{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        class_id : felt,
        metadata_id : felt,
    ) -> (classMetadata : ClassMetadata):
    # TODO check if classMetadata exists
    let (classMetadata : ClassMetadata) = OPTIO.get_class_metadata(class_id, metadata_id)
    return (classMetadata)
end

@view
func getUnitMetadata{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        class_id : felt,
        unit_id : felt,
        metadata_id : felt
    ) -> (unitMetadata : UnitMetadata):
    # TODO check if unitMetadata exists
    let (unitMetadata : UnitMetadata) = OPTIO.get_unit_metadata(class_id, unit_id, metadata_id)
    return (unitMetadata)
end

@external
func getClassData{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        class_id : felt,
        metadata_id : felt
    ) -> (classData : Values):
    # TODO check if class exists
    let (classData : Values) = OPTIO.get_class_data(class_id, metadata_id)
    return (classData)
end

@external
func getUnitData{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        class_id : felt,
        unit_id : felt,
        metadata_id : felt
    ) -> (unitData : Values):
    # TODO check if class and unit exist
    let (unitData : Values) = OPTIO.get_unit_data(class_id, unit_id, metadata_id)
    return (unitData)
end

@external
func approve{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        owner : felt,
        spender : felt,
        transactions_len : felt,
        transactions : Transaction*
    ):
    alloc_locals
    with_attr error_message("approve: zero address, got owner={owner}, spender={spender}"):
        assert_not_zero(owner)
        assert_not_zero(spender)
    end

    let (local caller) = get_caller_address()
    with_attr error_message("approve: can't approve own, got owner={owner}, spender={spender}"):
        assert_not_equal(owner, spender)
        assert_not_equal(caller, spender)
    end

    OPTIO.approve(
        owner=owner,
        spender=spender,
        transaction_index=0,
        transactions_len=transactions_len,
        transactions=transactions
    )
    return ()
end

@external
func setApprovalFor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        operator : felt,
        approved : felt,
    ):
    alloc_locals
    let (local owner) = get_caller_address()
    with_attr error_message("setApprovalFor: zero address, got operator={operator}"):
        assert_not_zero(operator)
    end

    OPTIO.set_approval_for(owner, operator, approved)
    ApprovalFor.emit(owner, operator, approved)
    return ()
end

@view
func totalSupply{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        class_id : felt,
        unit_id : felt,
    ) -> (balance : felt):
    alloc_locals
    let (caller) = get_caller_address()

    let (balance) = OPTIO.total_supply(caller, class_id, unit_id)
    return (balance)
end

@view
func getProgress{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        class_id : felt,
        unit_id : felt
    ) -> (progress : felt):
    let (progress) = OPTIO.get_progress(class_id, unit_id)
    return (progress)
end

@view
func isApprovedFor{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        owner : felt,
        operator : felt
    ) -> (approved : felt):
    let (approved) = OPTIO.is_approved_for(owner, operator)
    return (approved)
end

@external
func createClassMetadata{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        class_id : felt,
        metadata_id : felt,
        metadata : ClassMetadata
    ):
    OPTIO.create_class_metadata(class_id, metadata_id, metadata)
    return ()
end

@external
func createClassMetadataBatch{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        class_ids_len : felt,
        class_ids : felt*,
        metadata_ids_len : felt,
        metadata_ids : felt*,
        metadata_array_len : felt,
        metadata_array : ClassMetadata*
    ):
    with_attr error_message("createClassMetadataBatch: got zero inputs lengths"):
        assert_not_zero(class_ids_len)
        assert_not_zero(metadata_ids_len)
    end
    OPTIO.create_class_metadata_batch(
        index=0,
        class_ids_len=class_ids_len,
        class_ids=class_ids,
        metadata_ids_len=metadata_ids_len,
        metadata_ids=metadata_ids,
        metadata_array_len=metadata_array_len,
        metadata_array=metadata_array,
    )
    return ()
end

@external
func createUnitMetadata{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        class_id : felt,
        unit_id : felt,
        metadata_id : felt,
        metadata : UnitMetadata
    ):
    OPTIO.create_unit_metadata(class_id, unit_id, metadata_id, metadata)
    return ()
end

@external
func createUnitMetadataBatch{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        class_ids_len : felt,
        class_ids : felt*,
        unit_ids_len : felt,
        unit_ids : felt*,
        metadata_ids_len : felt,
        metadata_ids : felt*,
        metadata_array_len : felt,
        metadata_array : UnitMetadata*
    ):
    with_attr error_message("createClassMetadataBatch: got zero inputs lengths"):
        assert_not_zero(class_ids_len)
        assert_not_zero(unit_ids_len)
        assert_not_zero(metadata_ids_len)
        assert_not_zero(metadata_array_len)
    end
    OPTIO.create_unit_metadata_batch(
        index=0,
        class_ids_len=class_ids_len,
        class_ids=class_ids,
        unit_ids_len=unit_ids_len,
        unit_ids=unit_ids,
        metadata_ids_len=metadata_ids_len,
        metadata_ids=metadata_ids,
        metadata_array_len=metadata_array_len,
        metadata_array=metadata_array,
    )
    return ()
end

@external
func createClass{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        class_id : felt,
        metadata_ids_len : felt,
        metadata_ids : felt*,
        values_len : felt,
        values : Values*
    ):
    with_attr error_message("createClass: got zero inputs lengths"):
        assert_not_zero(metadata_ids_len)
        assert_not_zero(values_len)
    end
    OPTIO.create_class(
        index=0,
        class_id=class_id,
        metadata_ids_len=metadata_ids_len,
        metadata_ids=metadata_ids,
        values_len=values_len,
        values=values,
    )
    return ()
end