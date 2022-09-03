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
func classMetadata(class_id : felt, metadata_id : felt) -> (classMetadata : ClassMetadata):
end

@storage_var
func classes(class_id : felt, metadata_id : felt) -> (class : Values):
end

@storage_var
func unitMetadata(class_id : felt, unit_id : felt, metadata_id : felt) -> (unitMetadata : UnitMetadata):
end

@storage_var
func units(class_id : felt, unit_id : felt, metadata_id : felt) -> (unit : Values):
end

@storage_var
func operator_approvals(owner : felt, operator : felt) -> (approved : felt):
end

@storage_var
func balances(address : felt, class_id : felt, unit_id : felt) -> (amount : felt):
end

@storage_var
func allowances(address : felt, class_id : felt, unit_id : felt, spender : felt) -> (amount : felt):
end

@storage_var
func name() -> (name : felt):
end

@storage_var
func asset() -> (asset : felt):
end


namespace OPTIO:
    #
    # Constructor
    #
    func initialize{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }(
            _name : felt,
            _asset : felt,
        ):
        name.write(_name)
        asset.write(_asset)
        return ()
    end

    func transfer_from{
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
        let (balance_sender) = balances.read(sender, transaction.class_id, transaction.unit_id)
        let (balance_recipient) = balances.read(recipient, transaction.class_id, transaction.unit_id)

        with_attr error_message("_transfer_from: not enough funds to transfer, got sender's balance {balance_sender}"):
            assert_le(balance_sender, transaction.amount)
        end

        balances.write(sender, transaction.class_id, transaction.unit_id, balance_sender - transaction.amount)
        balances.write(recipient, transaction.class_id, transaction.unit_id, balance_recipient + transaction.amount)

        transfer_from(
            sender=sender,
            recipient=recipient,
            transaction_index=transaction_index + 1,
            transactions_len=transactions_len,
            transactions=transactions
        )
        return ()
    end

    func transfer_allowance_from{
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
        let (balance_sender) = balances.read(sender, transaction.class_id, transaction.unit_id)
        let (balance_recipient) = balances.read(recipient, transaction.class_id, transaction.unit_id)

        with_attr error_message("_transfer_allowance_from: not enough funds to transfer, got sender's balance {balance_sender}"):
            assert_le(balance_sender, transaction.amount)
        end

        # reducing the caller's allowance and reflecting changes
        allowances.write(balance_sender, transaction.class_id, transaction.unit_id, recipient, balance_sender - transaction.amount)
        balances.write(sender, transaction.class_id, transaction.unit_id, balance_sender - transaction.amount)
        balances.write(recipient, transaction.class_id, transaction.unit_id, balance_recipient + transaction.amount)

        transfer_allowance_from(
            caller=caller,
            sender=sender,
            recipient=recipient,
            transaction_index=transaction_index + 1,
            transactions_len=transactions_len,
            transactions=transactions
        )
        return ()
    end

    func issue{
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
        let (balance_recipient) = balances.read(recipient, transaction.class_id, transaction.unit_id)
        balances.write(recipient, transaction.class_id, transaction.unit_id, balance_recipient + transaction.amount)

        issue(
            recipient=recipient,
            transaction_index=transaction_index + 1,
            transactions_len=transactions_len,
            transactions=transactions
        )
        return ()
    end

    func redeem{
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
        let (balance_sender) = balances.read(sender, transaction.class_id, transaction.unit_id)

        with_attr error_message("_redeem: not enough funds to redeem, got sender's balance {balance_sender}"):
            assert_le(balance_sender, transaction.amount)
        end
        balances.write(sender, transaction.class_id, transaction.unit_id, balance_sender - transaction.amount)

        redeem(
            sender=sender,
            transaction_index=transaction_index + 1,
            transactions_len=transactions_len,
            transactions=transactions
        )
        return ()
    end

    func burn{
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
        let (balance_sender) = balances.read(sender, transaction.class_id, transaction.unit_id)

        with_attr error_message("_burn: not enough funds, got sender's balance {balance_sender}"):
            assert_le(balance_sender, transaction.amount)
        end
        balances.write(sender, transaction.class_id, transaction.unit_id, balance_sender - transaction.amount)

        burn(
            sender=sender,
            transaction_index=transaction_index + 1,
            transactions_len=transactions_len,
            transactions=transactions
        )
        return ()
    end

    func balance_of{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }(
            account : felt,
            class_id : felt,
            unit_id : felt
        ) -> (balance : felt):
        # TODO class and unit checks
        let (balance) = balances.read(account, class_id, unit_id)
        return (balance)
    end

    func allowance{
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
        let (remaining) = allowances.read(owner, class_id, unit_id, spender)
        return (remaining)
    end

    func get_class_metadata{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }(
            class_id : felt,
            metadata_id : felt
        ) -> (classMetadata : ClassMetadata):
        let (res) = classMetadata.read(class_id, metadata_id)
        return (classMetadata=res)
    end

    func get_unit_metadata{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }(
            class_id : felt,
            unit_id : felt,
            metadata_id : felt
        ) -> (unitMetadata : UnitMetadata):
        let (res) = unitMetadata.read(class_id, unit_id, metadata_id)
        return (unitMetadata=res)
    end

    func get_class_data{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }(
            class_id : felt,
            metadata_id : felt
        ) -> (classData : Values):
        let (classData : Values) = classes.read(class_id, metadata_id)
        return (classData)
    end

    func get_unit_data{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }(
            class_id : felt,
            unit_id : felt,
            metadata_id : felt
        ) -> (unitData : Values):
        let (unitData : Values) = units.read(class_id, unit_id, metadata_id)
        return (unitData)
    end

    func approve{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }(
            owner : felt,
            spender : felt,
            transaction_index : felt,
            transactions_len : felt,
            transactions : Transaction*
        ):
        if transaction_index == transactions_len:
            return ()
        end

        tempvar tx = transactions[transaction_index]
        allowances.write(owner, tx.class_id, tx.unit_id, spender, tx.amount)

        approve(
            owner=owner,
            spender=spender,
            transaction_index=transaction_index + 1,
            transactions_len=transactions_len,
            transactions=transactions,
        )
        return ()
    end

    func set_approval_for{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }(
            owner : felt,
            operator : felt,
            approved : felt
        ):
        operator_approvals.write(owner, operator, approved)
        return ()
    end

    func total_supply{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }(
            caller : felt,
            class_id : felt,
            unit_id : felt
        ) -> (balance : felt):
        let (balance) = balances.read(caller, class_id, unit_id)
        return (balance)
    end

    func get_progress{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }(
            class_id : felt,
            unit_id : felt
        ) -> (progress : felt):
        let (progress) = get_block_timestamp()
        return (progress)
    end

    func is_approved_for{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }(
            owner : felt,
            operator : felt
        ) -> (approved : felt):
        let (approved) = operator_approvals.read(owner, operator)
        return (approved)
    end

    func create_class_metadata{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }(
            class_id : felt,
            metadata_id : felt,
            metadata : ClassMetadata
        ):
        classMetadata.write(class_id, metadata_id, metadata)
        return ()
    end

    func create_class_metadata_batch{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }(
            index : felt,
            class_ids_len : felt,
            class_ids : felt*,
            metadata_ids_len : felt,
            metadata_ids : felt*,
            metadata_array_len : felt,
            metadata_array : ClassMetadata*
        ):
        if index == metadata_array_len:
            return ()
        end

        with_attr error_message("create_class_metadata_batch: inputs lengths not equal"):
            assert class_ids_len = metadata_ids_len
            assert metadata_ids_len = metadata_array_len
        end

        tempvar class_id = class_ids[index]
        tempvar metadata_id = metadata_ids[index]
        tempvar metadata = metadata_array[index]
        classMetadata.write(class_id, metadata_id, metadata)

        create_class_metadata_batch(
            index=index + 1,
            class_ids_len=class_ids_len,
            class_ids=class_ids,
            metadata_ids_len=metadata_ids_len,
            metadata_ids=metadata_ids,
            metadata_array_len=metadata_array_len,
            metadata_array=metadata_array,
        )
        return ()
    end

    func create_unit_metadata{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }(
            class_id : felt,
            unit_id : felt,
            metadata_id : felt,
            metadata : UnitMetadata
        ):
        unitMetadata.write(class_id, unit_id, metadata_id, metadata)
        return ()
    end

    func create_unit_metadata_batch{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }(
            index : felt,
            class_ids_len : felt,
            class_ids : felt*,
            unit_ids_len : felt,
            unit_ids : felt*,
            metadata_ids_len : felt,
            metadata_ids : felt*,
            metadata_array_len : felt,
            metadata_array : UnitMetadata*
        ):
        if index == metadata_array_len:
            return ()
        end

        with_attr error_message("create_unit_metadata_batch: inputs lengths not equal"):
            assert class_ids_len = unit_ids_len
            assert unit_ids_len = metadata_ids_len
            assert metadata_ids_len = metadata_array_len
        end

        tempvar class_id = class_ids[index]
        tempvar unit_id = unit_ids[index]
        tempvar metadata_id = metadata_ids[index]
        tempvar metadata = metadata_array[index]
        unitMetadata.write(class_id, unit_id, metadata_id, metadata)

        create_unit_metadata_batch(
            index=index + 1,
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

    func create_class{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }(
            index : felt,
            class_id : felt,
            metadata_ids_len : felt,
            metadata_ids : felt*,
            values_len : felt,
            values : Values*
        ):
        if index == metadata_ids_len:
            return ()
        end

        with_attr error_message("create_class: inputs lengths not equal"):
            assert metadata_ids_len = values_len
        end

        tempvar metadata_id = metadata_ids[index]
        tempvar value = values[index]
        classes.write(class_id, metadata_id, value)

        create_class(
            index=index + 1,
            class_id=class_id,
            metadata_ids_len=metadata_ids_len,
            metadata_ids=metadata_ids,
            values_len=values_len,
            values=values,
        )
        return ()
    end

    func create_unit{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }(
            index : felt,
            class_id : felt,
            unit_id : felt,
            metadata_ids_len : felt,
            metadata_ids : felt*,
            values_len : felt,
            values : Values
        ):
        if index == metadata_ids_len:
            return ()
        end

        with_attr error_message("create_unit: inputs lengths not equal"):
            assert metadata_ids_len = values_len
        end

        tempvar metadata_id = metadata_ids[index]
        tempvar value = values[index]
        units.write(class_id, unit_id, metadata_id, value)

        create_unit(
            index=index + 1,
            class_id=class_id,
            unit_id=unit_id,
            metadata_ids_len=metadata_ids_len,
            metadata_ids=metadata_ids,
            values_len=values_len,
            values=values,
        )
        return ()
    end
end