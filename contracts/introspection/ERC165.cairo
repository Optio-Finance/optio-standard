%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.math import assert_not_equal
from starkware.cairo.common.bool import TRUE

from contracts.utils.constants import INVALID_ID, IERC165_ID

@storage_var
func ERC165_supported_interfaces(interface_id: felt) -> (is_supported: felt) {
}

func ERC165_supports_interface{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    interface_id: felt
) -> (success: felt) {
    if (interface_id == IERC165_ID) {
        return (TRUE,);
    }

    let (is_supported) = ERC165_supported_interfaces.read(interface_id);
    return (is_supported,);
}

func ERC165_register_interface{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    interface_id: felt
) {
    with_attr error_message("ERC165: invalid interface id") {
        assert_not_equal(interface_id, INVALID_ID);
    }
    ERC165_supported_interfaces.write(interface_id, TRUE);
    return ();
}
