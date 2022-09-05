%lang starknet

from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero

// TODO: ownership revoking

//
// # Events
//

@event
func OwnershipTransferred(previousOwner: felt, newOwner: felt) {
}

//
// # Storage
//

@storage_var
func Ownable_owner() -> (owner: felt) {
}

namespace Ownable {
    func initializer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner: felt) {
        _transfer_ownership(owner);
        return ();
    }

    func assert_only_owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
        let (owner) = Ownable.owner();
        let (caller) = get_caller_address();
        with_attr error_message("Ownable: caller is the zero address") {
            assert_not_zero(caller);
        }
        with_attr error_message("Ownable: caller is not the owner") {
            assert owner = caller;
        }
        return ();
    }

    func owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (owner: felt) {
        let (owner) = Ownable_owner.read();
        return (owner=owner);
    }

    func transfer_ownership{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        new_owner: felt
    ) {
        with_attr error_message("Ownable: new owner is the zero address") {
            assert_not_zero(new_owner);
        }
        assert_only_owner();
        _transfer_ownership(new_owner);
        return ();
    }

    func _transfer_ownership{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        new_owner: felt
    ) {
        let (previous_owner: felt) = Ownable.owner();
        Ownable_owner.write(new_owner);
        OwnershipTransferred.emit(previous_owner, new_owner);
        return ();
    }
}
