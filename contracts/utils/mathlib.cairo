%lang starknet

from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_mul,
    uint256_sub,
    uint256_eq,
    uint256_unsigned_div_rem
)


func mulDivDown{range_check_ptr}(
        x : Uint256,
        y : Uint256,
        denominator : Uint256
    ) -> (z : Uint256):
    alloc_locals
    let ZERO = Uint256(0, 0)

    let (local prod, carry) = uint256_mul(x, y)
    let (no_overflow) = uint256_eq(carry, ZERO)
    assert no_overflow = 1

    let (local x_iszero) = uint256_eq(x, ZERO)
    let (q1, _) = uint256_unsigned_div_rem(prod, x)
    let (q1_is_y) = uint256_eq(q1, y)
    let or = x_iszero + q1_is_y
    assert_not_zero(or)

    let (local denominator_iszero) = uint256_eq(denominator, ZERO)
    assert denominator_iszero = 0

    let (q2, _) = uint256_unsigned_div_rem(prod, denominator)
    return (q2)
end

func mulDivUp{range_check_ptr}(
        x : Uint256,
        y : Uint256,
        denominator : Uint256
    ) -> (z : Uint256):
    alloc_locals
    let ZERO = Uint256(0, 0)
    let ONE = Uint256(1, 0)

    let (local prod, carry) = uint256_mul(x, y)
    let (no_overflow) = uint256_eq(carry, ZERO)
    assert no_overflow = 1

    let (local x_iszero) = uint256_eq(x, ZERO)
    let (q1, _) = uint256_unsigned_div_rem(prod, x)
    let (q1_is_y) = uint256_eq(q1, y)
    let or = x_iszero + q1_is_y
    assert_not_zero(or)

    let (local denominator_iszero) = uint256_eq(denominator, ZERO)
    assert denominator_iszero = 0

    let (local prod_iszero) = uint256_eq(prod, ZERO)
    if prod_iszero == 1:
        return (ZERO)
    end

    let (local dec_prod) = uint256_sub(prod, ONE)
    let (q2, _) = uint256_unsigned_div_rem(dec_prod, denominator)
    let (local inc_q2, _) = uint256_add(q2, ONE)
    return (inc_q2)
end
