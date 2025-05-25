#[test_only]
module move_int::i16_test {
    use move_int::i16::{as_u16, from, from_u16, neg_from, abs, add,
        sub, mul, div, wrapping_add, wrapping_sub, pow, sign, cmp,
        min, max, eq, gte, lte, and, or, is_zero, is_neg, zero, mod
    };

    // Constants for testing
    const OVERFLOW: u64 = 0;
    const BITS_MIN_I16: u16 = 1 << 15;
    const BITS_MAX_I16: u16 = 0x7fff;
    const LT: u8 = 0;
    const EQ: u8 = 1;
    const GT: u8 = 2;

    // === Construction Tests ===
    #[test]
    fun test_constructors() {
        // Test zero()
        let zero_val = zero();
        assert!(as_u16(zero_val) == 0, 0);
        assert!(sign(zero_val) == 0, 1);
        assert!(is_zero(zero_val), 2);

        // Test from()
        assert!(as_u16(from(0)) == 0, 3);
        assert!(as_u16(from(10)) == 10, 4);
        assert!(as_u16(from(BITS_MAX_I16)) == BITS_MAX_I16, 5);

        // Test from_u16()
        assert!(as_u16(from_u16(42)) == 42, 6);
        assert!(as_u16(from_u16(BITS_MIN_I16)) == BITS_MIN_I16, 7);
        assert!(sign(from_u16(BITS_MIN_I16)) == 1, 8);

        // Test neg_from()
        assert!(as_u16(neg_from(0)) == 0, 9);
        assert!(as_u16(neg_from(1)) == 0xffff, 10);
        assert!(as_u16(neg_from(BITS_MIN_I16)) == BITS_MIN_I16, 11);
        assert!(as_u16(neg_from(0x7fff)) == 0x8001, 12);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i16)]
    fun test_from_overflow() {
        from(BITS_MIN_I16);
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i16)]
    fun test_neg_from_overflow() {
        neg_from(0x8001);
    }

    // === Arithmetic Operation Tests ===
    #[test]
    fun test_basic_arithmetic() {
        // Test wrapping_add
        assert!(
            as_u16(wrapping_add(from(10), from(20))) == 30,
            0
        );
        assert!(
            as_u16(wrapping_add(from(BITS_MAX_I16), from(1))) == BITS_MIN_I16,
            1
        );
        assert!(
            as_u16(wrapping_add(neg_from(1), neg_from(0))) == 0xffff,
            2
        );
        assert!(
            as_u16(
                wrapping_add(from(10000), neg_from(9999))
            ) == 1,
            3
        );

        // Test wrapping_sub
        assert!(
            as_u16(wrapping_sub(from(20), from(10))) == 10,
            4
        );
        assert!(
            as_u16(wrapping_sub(from(0), from(1))) == as_u16(neg_from(1)),
            5
        );
        assert!(
            as_u16(wrapping_sub(from(1), neg_from(1))) == as_u16(from(2)),
            6
        );

        // Test add/sub without overflow
        assert!(as_u16(add(from(15), from(25))) == 40, 7);
        assert!(as_u16(sub(from(25), from(15))) == 10, 8);
        assert!(as_u16(add(neg_from(1), from(1))) == 0, 9);

        // Test multiplication
        assert!(as_u16(mul(from(10), from(10))) == 100, 10);
        assert!(
            as_u16(mul(neg_from(10), from(10))) == as_u16(neg_from(100)),
            11
        );
        assert!(
            as_u16(mul(from(BITS_MIN_I16 / 2), neg_from(2)))
                == as_u16(neg_from(BITS_MIN_I16)),
            12
        );

        // Test division
        assert!(as_u16(div(from(100), from(10))) == 10, 13);
        assert!(
            as_u16(div(from(10), neg_from(1))) == as_u16(neg_from(10)),
            14
        );
        assert!(
            as_u16(div(neg_from(10), neg_from(1))) == as_u16(from(10)),
            15
        );

        // Test mod
        assert!(eq(mod(neg_from(3), from(3)), zero()), 16);
        assert!(eq(mod(neg_from(4), from(3)), neg_from(1)), 17);
        assert!(eq(mod(neg_from(5), from(3)), neg_from(2)), 18);
        assert!(eq(mod(neg_from(6), from(3)), zero()), 19);
    }

    #[test]
    #[expected_failure]
    fun test_add_overflow() {
        add(from(BITS_MAX_I16), from(1));
    }

    #[test]
    #[expected_failure]
    fun test_add_underflow() {
        add(neg_from(BITS_MIN_I16), neg_from(1));
    }

    #[test]
    #[expected_failure]
    fun test_sub_overflow() {
        sub(from(BITS_MAX_I16), neg_from(1));
    }

    #[test]
    #[expected_failure]
    fun test_sub_underflow() {
        sub(neg_from(BITS_MIN_I16), from(1));
    }

    #[test]
    #[expected_failure]
    fun test_mul_overflow() {
        mul(from(256), from(256));
    }

    #[test]
    #[expected_failure(abort_code = 0, location = move_int::i16)]
    fun test_div_overflow() {
        div(neg_from(BITS_MIN_I16), neg_from(1));
    }

    // === Advanced Math Operation Tests ===
    #[test]
    fun test_advanced_operations() {
        // Test pow
        assert!(eq(pow(from(2), 3), from(8)), 0);
        assert!(eq(pow(neg_from(2), 3), neg_from(8)), 1);
        assert!(eq(pow(from(2), 0), from(1)), 2);
        assert!(eq(pow(neg_from(2), 2), from(4)), 3);
        assert!(eq(pow(from(1), 100), from(1)), 4);
        assert!(eq(pow(from(3), 3), from(27)), 5);
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

        // Test min with all branches
        assert!(
            eq(
                min(neg_from(2), neg_from(1)),
                neg_from(2)
            ),
            8
        );
        assert!(
            eq(min(neg_from(1), from(0)), neg_from(1)),
            9
        );
        assert!(
            eq(min(from(0), neg_from(1)), neg_from(1)),
            10
        );
        assert!(
            eq(min(from(BITS_MAX_I16), from(0)), from(0)),
            11
        );
        assert!(
            eq(
                min(neg_from(BITS_MIN_I16), from(0)),
                neg_from(BITS_MIN_I16)
            ),
            12
        );

        // Test max with all branches
        assert!(
            eq(
                max(neg_from(2), neg_from(1)),
                neg_from(1)
            ),
            13
        );
        assert!(
            eq(max(neg_from(1), from(0)), from(0)),
            14
        );
        assert!(
            eq(max(from(0), neg_from(1)), from(0)),
            15
        );
        assert!(
            eq(
                max(from(BITS_MAX_I16), from(0)),
                from(BITS_MAX_I16)
            ),
            16
        );
        assert!(
            eq(
                max(neg_from(BITS_MIN_I16), from(0)),
                from(0)
            ),
            17
        );
    }

    // === Bitwise Operation Tests ===
    #[test]
    fun test_bitwise_ops() {
        // Test AND
        let a = from_u16(21845); // 0101010101010101 in binary
        let b = from_u16(30000); // 0111010100110000 in binary
        assert!(as_u16(and(a, b)) == 21776, 0);
        assert!(
            as_u16(and(from_u16(21845), from_u16(0))) == 0,
            1
        );

        // Test OR
        let a = from_u16(21845); // 0101010101010101 in binary
        let b = from_u16(10922); // 0010101010101010 in binary
        assert!(as_u16(or(a, b)) == 32767, 2);
        assert!(
            as_u16(or(from_u16(24576), from_u16(255))) == 24831,
            3
        );
    }

    // === Helper Function Tests ===
    #[test]
    fun test_helper_functions() {
        // Test abs
        assert!(as_u16(abs(from(10))) == 10, 0);
        assert!(as_u16(abs(neg_from(10))) == 10, 1);
        assert!(as_u16(abs(neg_from(0))) == 0, 2);

        // Test comparison helpers
        assert!(gte(from(5000), from(3000)), 3);
        assert!(lte(from(2000), from(4000)), 4);
        assert!(is_neg(from_u16(49152)), 5); // negative number (MSB set)
        assert!(!is_neg(from(0)), 6);

        // Test edge cases
        assert!(as_u16(from_u16(BITS_MAX_I16)) == BITS_MAX_I16, 7);
        assert!(as_u16(from_u16(0)) == 0, 8);
    }

    #[test]
    #[expected_failure]
    fun test_abs_overflow() {
        abs(neg_from(BITS_MIN_I16));
    }
}
