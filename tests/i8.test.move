#[test_only]
module move_int::i8_test {
    use move_int::i8::{as_u8, from, from_u8, neg_from, abs, add, sub, mul,
        div, wrapping_sub, pow, sign, cmp, min, max, eq, gte, lte,
        and, or, is_zero, is_neg, zero, mod
    };

    // Constants for testing
    const OVERFLOW: u64 = 0;
    const BITS_MIN_I8: u8 = 1 << 7;
    const BITS_MAX_I8: u8 = 0x7f;
    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    // === Construction Tests ===
    #[test]
    fun test_constructors() {
        // Test zero()
        let zero_val = zero();
        assert!(as_u8(zero_val) == 0, 0);
        assert!(sign(zero_val) == 0, 1);
        assert!(is_zero(zero_val), 2);

        // Test from()
        assert!(as_u8(from(0)) == 0, 3);
        assert!(as_u8(from(10)) == 10, 4);
        assert!(as_u8(from(BITS_MAX_I8)) == BITS_MAX_I8, 5);

        // Test from_u8()
        assert!(as_u8(from_u8(42)) == 42, 6);
        assert!(as_u8(from_u8(127)) == 127, 7);
        assert!(as_u8(from_u8(0)) == 0, 8);

        // Test neg_from()
        assert!(as_u8(neg_from(0)) == 0, 9);
        assert!(as_u8(neg_from(1)) == 0xff, 10);
        assert!(as_u8(neg_from(BITS_MAX_I8)) == 0x81, 11);
        assert!(as_u8(neg_from(BITS_MIN_I8)) == BITS_MIN_I8, 12);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i8)]
    fun test_from_overflow() {
        from(BITS_MAX_I8 + 1);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i8)]
    fun test_neg_from_overflow() {
        neg_from(BITS_MIN_I8 + 1);
    }

    // === Arithmetic Operation Tests ===
    #[test]
    fun test_basic_arithmetic() {
        // Test add/sub
        assert!(as_u8(add(from(1), from(2))) == 3, 0);
        assert!(
            as_u8(add(from(BITS_MAX_I8), from(0))) == BITS_MAX_I8,
            1
        );
        assert!(as_u8(add(neg_from(1), from(1))) == 0, 2);
        assert!(as_u8(sub(from(3), from(2))) == 1, 3);
        assert!(as_u8(sub(from(0), from(1))) == 0xff, 4);

        // Test wrapping operations
        assert!(
            as_u8(wrapping_sub(from(50), from(30))) == 20,
            5
        );
        assert!(
            as_u8(wrapping_sub(from(0), from(1))) == 255,
            6
        );
        assert!(
            as_u8(wrapping_sub(from(100), from(100))) == 0,
            7
        );

        // Test multiplication
        assert!(as_u8(mul(from(3), from(2))) == 6, 8);
        assert!(
            as_u8(mul(neg_from(4), from(2))) == 0xf8,
            9
        );
        assert!(
            as_u8(mul(neg_from(4), neg_from(2))) == 8,
            10
        );

        // Test division
        assert!(as_u8(div(from(6), from(2))) == 3, 11);
        assert!(
            as_u8(div(neg_from(6), from(2))) == 0xfd,
            12
        );
        assert!(
            as_u8(div(neg_from(6), neg_from(2))) == 3,
            13
        );

        // Test mod
        assert!(eq(mod(neg_from(3), from(3)), zero()), 14);
        assert!(eq(mod(neg_from(4), from(3)), neg_from(1)), 15);
        assert!(eq(mod(neg_from(5), from(3)), neg_from(2)), 16);
        assert!(eq(mod(neg_from(6), from(3)), zero()), 17);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i8)]
    fun test_add_overflow() {
        add(from(BITS_MAX_I8), from(1));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i8)]
    fun test_add_underflow() {
        add(neg_from(BITS_MIN_I8), neg_from(1));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i8)]
    fun test_sub_overflow() {
        sub(from(BITS_MAX_I8), neg_from(1));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i8)]
    fun test_sub_underflow() {
        sub(neg_from(BITS_MIN_I8), from(1));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i8)]
    fun test_mul_overflow() {
        mul(from(64), from(2));
    }

    #[test]
    #[expected_failure(abort_code = 1, location = move_int::i8)]
    fun test_div_by_zero() {
        div(from(1), from(0));
    }

    // === Advanced Math Operation Tests ===
    #[test]
    fun test_advanced_operations() {
        // Test pow
        assert!(eq(pow(from(2), 3), from(8)), 0);
        assert!(eq(pow(neg_from(2), 3), neg_from(8)), 1);
        assert!(eq(pow(from(2), 0), from(1)), 2);
        assert!(eq(pow(from(1), 127), from(1)), 3);
        assert!(eq(pow(neg_from(1), 127), neg_from(1)), 4);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i8)]
    fun test_pow_overflow() {
        pow(from(3), 4);
    }

    // === Comparison Tests ===
    #[test]
    fun test_comparisons() {
        // Test cmp with all sign combinations
        assert!(cmp(neg_from(2), neg_from(1)) == LT, 0);
        assert!(cmp(neg_from(1), neg_from(1)) == EQ, 1);
        assert!(cmp(neg_from(1), neg_from(2)) == GT, 2);
        assert!(cmp(neg_from(1), from(0)) == LT, 3);
        assert!(cmp(from(0), neg_from(1)) == GT, 4);
        assert!(
            cmp(neg_from(BITS_MIN_I8), from(BITS_MAX_I8)) == LT,
            5
        );

        // Test min with all branches
        assert!(
            eq(
                min(neg_from(2), neg_from(1)),
                neg_from(2)
            ),
            6
        );
        assert!(
            eq(min(neg_from(1), from(0)), neg_from(1)),
            7
        );
        assert!(
            eq(min(from(BITS_MAX_I8), from(0)), from(0)),
            8
        );
        assert!(
            eq(
                min(neg_from(BITS_MIN_I8), from(0)),
                neg_from(BITS_MIN_I8)
            ),
            9
        );

        // Test max with all branches
        assert!(
            eq(
                max(neg_from(2), neg_from(1)),
                neg_from(1)
            ),
            10
        );
        assert!(
            eq(max(from(0), neg_from(5)), from(0)),
            11
        );
        assert!(
            eq(
                max(from(BITS_MAX_I8), from(0)),
                from(BITS_MAX_I8)
            ),
            12
        );
        assert!(
            eq(
                max(neg_from(BITS_MIN_I8), from(0)),
                from(0)
            ),
            13
        );
    }

    // === Bitwise Operation Tests ===
    #[test]
    fun test_bitwise_ops() {
        // Test AND
        let a = from_u8(170); // 0b10101010
        let b = from_u8(240); // 0b11110000
        assert!(as_u8(and(a, b)) == 160, 0); // 0b10100000 = 160
        assert!(
            as_u8(and(from_u8(214), from_u8(0))) == 0,
            1
        );

        // Test OR
        let a = from_u8(170); // 0b10101010
        let b = from_u8(85); // 0b01010101
        assert!(as_u8(or(a, b)) == 255, 2); // 0b11111111 = 255
        assert!(
            as_u8(or(from_u8(192), from_u8(15))) == 207,
            3
        );
    }

    // === Helper Function Tests ===
    #[test]
    fun test_helper_functions() {
        // Test abs
        assert!(as_u8(abs(from(10))) == 10, 0);
        assert!(as_u8(abs(neg_from(10))) == 10, 1);
        assert!(as_u8(abs(neg_from(0))) == 0, 2);

        // Test sign and is_neg
        assert!(sign(neg_from(10)) == 1, 3);
        assert!(sign(from(10)) == 0, 4);
        assert!(is_neg(neg_from(1)), 5);
        assert!(!is_neg(from(1)), 6);
        assert!(!is_neg(from(0)), 7);

        // Test comparison helpers
        assert!(gte(from(50), from(30)), 8);
        assert!(lte(from(20), from(40)), 9);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i8)]
    fun test_abs_overflow() {
        abs(neg_from(BITS_MIN_I8));
    }
}
