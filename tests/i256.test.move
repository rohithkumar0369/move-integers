#[test_only]
module move_int::i256_test {
    use move_int::i256::{as_u256, from, neg_from, abs, add, sub, mul,
        div, wrapping_add, wrapping_sub, overflowing_add, overflowing_sub, pow, neg, sign,
        cmp, min, max, eq, gt, lt, gte, lte, and, or, is_zero, is_neg, zero
    };

    // Constants for testing
    const MIN_AS_U256: u256 = 1 << 255;
    const MAX_AS_U256: u256 =
        0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    // === Construction Tests ===
    #[test]
    fun test_constructors() {
        // Test zero()
        let zero_val = zero();
        assert!(as_u256(zero_val) == 0, 0);
        assert!(sign(zero_val) == 0, 1);
        assert!(is_zero(zero_val), 2);

        // Test from()
        assert!(as_u256(from(0)) == 0, 3);
        assert!(as_u256(from(10)) == 10, 4);
        assert!(as_u256(from(MAX_AS_U256)) == MAX_AS_U256, 5);

        // Test neg_from()
        assert!(as_u256(neg_from(0)) == 0, 6);
        assert!(
            as_u256(neg_from(1))
                ==
                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff,
            7
        );
        assert!(as_u256(neg_from(MIN_AS_U256)) == MIN_AS_U256, 8);

        // Test neg()
        assert!(eq(neg(from(5)), neg_from(5)), 9);
        assert!(eq(neg(neg_from(5)), from(5)), 10);
        assert!(eq(neg(zero()), zero()), 11);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i256)]
    fun test_from_overflow() {
        from(MIN_AS_U256);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i256)]
    fun test_neg_from_overflow() {
        neg_from(
            0x8000000000000000000000000000000000000000000000000000000000000001
        );
    }

    // === Arithmetic Operation Tests ===
    #[test]
    fun test_basic_arithmetic() {
        // Test wrapping operations
        assert!(
            as_u256(wrapping_add(from(10), from(20))) == 30,
            0
        );
        assert!(
            as_u256(
                wrapping_add(from(MAX_AS_U256), from(1))
            ) == MIN_AS_U256,
            1
        );
        assert!(
            as_u256(wrapping_sub(from(20), from(10))) == 10,
            2
        );
        assert!(
            as_u256(wrapping_sub(from(0), from(1))) == as_u256(neg_from(1)),
            3
        );

        // Test overflowing operations
        let (result, overflow) = overflowing_add(
            from(MAX_AS_U256), neg_from(1)
        );
        assert!(
            !overflow && as_u256(result) == MAX_AS_U256 - 1,
            4
        );
        let (_, overflow) = overflowing_add(from(MAX_AS_U256), from(1));
        assert!(overflow, 5);

        let (result, overflow) = overflowing_sub(from(MAX_AS_U256), from(1));
        assert!(
            !overflow && as_u256(result) == MAX_AS_U256 - 1,
            6
        );
        let (_, overflow) = overflowing_sub(neg_from(MIN_AS_U256), from(1));
        assert!(overflow, 7);

        // Test standard operations
        assert!(as_u256(add(from(15), from(25))) == 40, 8);
        assert!(as_u256(sub(from(25), from(15))) == 10, 9);
    }

    // === Multiplication and Division Tests ===
    #[test]
    fun test_mul_div() {
        // Test multiplication with different signs
        assert!(as_u256(mul(from(10), from(10))) == 100, 0);
        assert!(
            as_u256(mul(neg_from(10), from(10))) == as_u256(neg_from(100)),
            1
        );
        assert!(
            as_u256(mul(from(10), neg_from(10))) == as_u256(neg_from(100)),
            2
        );

        // Test multiplication edge cases
        assert!(as_u256(mul(from(0), from(10))) == 0, 3);
        assert!(as_u256(mul(from(10), from(0))) == 0, 4);
        assert!(
            as_u256(mul(from(MIN_AS_U256 / 2), neg_from(2)))
                == as_u256(neg_from(MIN_AS_U256)),
            5
        );

        // Test division with different signs
        assert!(as_u256(div(from(100), from(10))) == 10, 6);
        assert!(
            as_u256(div(from(100), neg_from(10))) == as_u256(neg_from(10)),
            7
        );
        assert!(
            as_u256(div(neg_from(100), neg_from(10))) == as_u256(from(10)),
            8
        );
        assert!(
            as_u256(div(neg_from(MIN_AS_U256), from(1))) == MIN_AS_U256,
            9
        );
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i256)]
    fun test_mul_overflow() {
        mul(from(MIN_AS_U256 / 2), from(3));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i256)]
    fun test_mul_overflow_negative() {
        mul(neg_from(MIN_AS_U256 / 2), neg_from(2));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i256)]
    fun test_div_overflow() {
        div(neg_from(MIN_AS_U256), neg_from(1));
    }

    // === Overflow Tests ===
    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i256)]
    fun test_add_overflow() {
        add(from(MAX_AS_U256), from(1));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i256)]
    fun test_add_underflow() {
        add(neg_from(MIN_AS_U256), neg_from(1));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i256)]
    fun test_sub_overflow() {
        sub(from(MAX_AS_U256), neg_from(1));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i256)]
    fun test_sub_underflow() {
        sub(neg_from(MIN_AS_U256), from(1));
    }

    // === Comparison Tests ===
    #[test]
    fun test_comparisons() {
        // Test cmp with all sign combinations
        assert!(cmp(neg_from(2), neg_from(1)) == LT, 0); // neg vs neg
        assert!(cmp(neg_from(1), neg_from(1)) == EQ, 1); // neg equal
        assert!(cmp(neg_from(1), neg_from(2)) == GT, 2); // neg vs neg
        assert!(cmp(neg_from(1), from(0)) == LT, 3); // neg vs pos
        assert!(cmp(from(0), neg_from(1)) == GT, 4); // pos vs neg
        assert!(cmp(from(1), from(2)) == LT, 5); // pos vs pos
        assert!(cmp(from(2), from(2)) == EQ, 6); // pos equal
        assert!(cmp(from(2), from(1)) == GT, 7); // pos vs pos

        // Test comparison operators
        assert!(gt(from(6), from(5)), 8);
        assert!(!gt(from(5), from(5)), 9);
        assert!(lt(from(4), from(5)), 10);
        assert!(!lt(from(5), from(5)), 11);
        assert!(gte(from(5), from(5)), 12);
        assert!(lte(from(5), from(5)), 13);
        assert!(gte(from(6), from(5)), 14);
        assert!(lte(from(4), from(5)), 15);
    }

    // === Min/Max Tests ===
    #[test]
    fun test_min_max() {
        // Test min with all branches
        assert!(
            eq(
                min(neg_from(2), neg_from(1)),
                neg_from(2)
            ),
            0
        );
        assert!(
            eq(min(neg_from(1), from(0)), neg_from(1)),
            1
        );
        assert!(
            eq(min(from(0), neg_from(1)), neg_from(1)),
            2
        );
        assert!(eq(min(from(1), from(2)), from(1)), 3);
        assert!(
            eq(min(from(MAX_AS_U256), from(0)), from(0)),
            4
        );
        assert!(
            eq(
                min(neg_from(MIN_AS_U256), from(0)),
                neg_from(MIN_AS_U256)
            ),
            5
        );

        // Test max with all branches
        assert!(
            eq(
                max(neg_from(2), neg_from(1)),
                neg_from(1)
            ),
            6
        );
        assert!(eq(max(neg_from(1), from(0)), from(0)), 7);
        assert!(eq(max(from(0), neg_from(1)), from(0)), 8);
        assert!(eq(max(from(1), from(2)), from(2)), 9);
        assert!(
            eq(
                max(from(MAX_AS_U256), from(0)),
                from(MAX_AS_U256)
            ),
            10
        );
        assert!(eq(max(from(5), from(5)), from(5)), 11);
    }

    // === Bitwise Operation Tests ===
    #[test]
    fun test_bitwise_ops() {
        // Test AND
        assert!(
            as_u256(and(from(0x0F), from(0xFF))) == 0x0F,
            0
        );
        assert!(
            as_u256(and(neg_from(1), from(0xFF))) == 0xFF,
            1
        );
        assert!(as_u256(and(from(0), from(0xFF))) == 0, 2);

        // Test OR
        assert!(
            as_u256(or(from(0x0F), from(0xF0))) == 0xFF,
            3
        );
        assert!(
            as_u256(or(from(0), neg_from(1)))
                ==
                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff,
            4
        );
        assert!(
            as_u256(or(from(MAX_AS_U256), from(0))) == MAX_AS_U256,
            5
        );
    }

    // === Helper Function Tests ===
    #[test]
    fun test_helper_functions() {
        // Test abs/abs_u256
        assert!(as_u256(abs(from(10))) == 10, 0);
        assert!(as_u256(abs(neg_from(10))) == 10, 1);

        // Test sign and is_neg
        assert!(sign(neg_from(10)) == 1, 2);
        assert!(sign(from(10)) == 0, 3);
        assert!(sign(from(0)) == 0, 4);
        assert!(is_neg(neg_from(1)), 5);
        assert!(!is_neg(from(1)), 6);
        assert!(!is_neg(zero()), 7);

        // Test power function
        assert!(eq(pow(from(2), 10), from(1024)), 8);
        assert!(eq(pow(from(3), 4), from(81)), 9);
        assert!(eq(pow(neg_from(2), 3), neg_from(8)), 10);
        assert!(eq(pow(neg_from(2), 4), from(16)), 11);
        assert!(eq(pow(from(1), 1000000), from(1)), 12); // Large exponent
        assert!(eq(pow(from(0), 5), from(0)), 13); // Zero base
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i256)]
    fun test_abs_overflow() {
        abs(neg_from(MIN_AS_U256));
    }
}
